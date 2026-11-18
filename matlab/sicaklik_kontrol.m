function kayit = sicaklik_kontrol(cfg)
%SICAKLIK_KONTROL  Isıtıcıyı açıp kapatarak/ayarlayarak sıcaklığı hedefte tutar.
%
%   sicaklik_kontrol()                     varsayılan: simülasyon, PI, 80 °C
%   cfg = sicaklik_kontrol_ayar();         ayarları al, değiştir, çalıştır:
%   cfg.kontrol = "ACKAPA";  sicaklik_kontrol(cfg)
%
%   ŞU AN: Sensör yok. Sıcaklık, ısıtıcıya tepki veren basit bir SANAL DÜZENEK
%   (ısıl model) ile üretilir ve üzerine rastgele sensör gürültüsü eklenir.
%   İLERİDE: cfg.kaynak = "labchart" ve cfg.cikis = "gpp" yapılarak aynı kontrol
%   algoritması gerçek düzenekte çalışır (sicaklik_oku ve guc_uygula fonksiyonları).
%
%   Kontrol yöntemleri:
%     "PI"     : Isıtıcı gücünü 0–Pmax arasında sürekli ayarlar (önerilen)
%     "ACKAPA" : Termostat gibi, ya tam güç ya kapalı (histerezisli)
%
%   Güvenlik: Sıcaklık cfg.T_limit'i aşarsa veya sensör okunamazsa ısıtıcı kapatılır
%   ve döngü durur. Ctrl+C ile durdurulursa da ısıtıcı kapatılır.

    if nargin < 1, cfg = sicaklik_kontrol_ayar(); end

    % ---------- Bağlantılar (gerçek mod) ----------
    gpp = [];
    if cfg.cikis == "gpp"
        gpp = gpp_baglan(cfg.gpp_port);
        writeline(gpp, sprintf("ISET%d:3", cfg.gpp_kanal));
        writeline(gpp, sprintf("VSET%d:0", cfg.gpp_kanal));
        writeline(gpp, sprintf(":OUTPut%d:STATe ON", cfg.gpp_kanal));
    end
    temizlik = onCleanup(@() guc_kes(gpp, cfg)); %#ok<NASGU>

    % ---------- Sanal düzenek başlangıcı ----------
    sim = sanal_duzenek_baslat(cfg);

    % ---------- Kontrolcü durumu ----------
    ks.integral = 0;
    ks.isitici_acik = false;

    % ---------- Kayıt ve grafik ----------
    N = ceil(cfg.sure_s / cfg.dt);
    kayit = table('Size', [N 5], 'VariableTypes', repmat("double", 1, 5), ...
                  'VariableNames', ["time_s", "T_hedef", "T_olculen", "P_W", "T_gercek"]);
    [cizgiT, cizgiP] = grafik_hazirla(cfg);

    fprintf("Başladı: %s kontrol, hedef %.1f °C, kaynak=%s, çıkış=%s\n", ...
            cfg.kontrol, cfg.T_hedef, cfg.kaynak, cfg.cikis);

    n = 0;                                 % doldurulan kayıt satırı sayısı
    for k = 1:N
        t = (k - 1) * cfg.dt;

        % 1) Sıcaklığı oku
        T_olc = sicaklik_oku(cfg, sim);

        % 2) Güvenlik kontrolü
        if isnan(T_olc)
            warning("Sensör okunamadı (t = %.0f s). Isıtıcı kapatıldı.", t);
            break
        end
        if T_olc > cfg.T_limit
            warning("Sıcaklık %.1f °C > %.1f °C güvenlik sınırı! Isıtıcı kapatıldı.", T_olc, cfg.T_limit);
            break
        end

        % 3) Kontrol kararı: kaç watt verilecek?
        [P, ks] = kontrolcu(cfg, ks, T_olc);

        % 4) Gücü uygula
        guc_uygula(cfg, gpp, P);

        % 5) Sanal düzeneği bir adım ilerlet (yalnızca simülasyonda)
        sim = sanal_duzenek_adim(cfg, sim, P, t);

        % 6) Kaydet ve çiz
        n = k;
        kayit(n, :) = {t, cfg.T_hedef, T_olc, P, sim.T};
        addpoints(cizgiT, t / 60, T_olc);
        addpoints(cizgiP, t / 60, P);
        if mod(k, 10) == 0, drawnow limitrate; end
        if mod(k, 60) == 0
            fprintf("%6.1f dk | T = %6.2f °C | P = %5.1f W\n", t / 60, T_olc, P);
        end

        pause(cfg.dt / cfg.hiz);
    end

    kayit = kayit(1:n, :);
    if n == 0, return, end
    ozet_yazdir(cfg, kayit);
    dosya = "sicaklik_kontrol_" + string(datetime("now", "Format", "yyyyMMdd_HHmmss")) + ".csv";
    writetable(kayit, dosya);
    fprintf("Kayıt: %s\n", fullfile(pwd, dosya));
end

%% ======================= KONTROLCÜ =======================
function [P, ks] = kontrolcu(cfg, ks, T_olc)
    e = cfg.T_hedef - T_olc;               % hata: + ise ısıtmak gerekiyor

    switch cfg.kontrol
        case "PI"
            % Oransal + integral. Integral, çıkış sınırdayken büyümez (anti-windup).
            u = cfg.Kp * e + ks.integral;
            doyumda = (u >= cfg.P_max && e > 0) || (u <= 0 && e < 0);
            if ~doyumda
                ks.integral = ks.integral + cfg.Ki * e * cfg.dt;
            end
            P = min(max(cfg.Kp * e + ks.integral, 0), cfg.P_max);

        case "ACKAPA"
            % Termostat: hedef - h altında aç, hedef + h üstünde kapat.
            if T_olc < cfg.T_hedef - cfg.histerezis
                ks.isitici_acik = true;
            elseif T_olc > cfg.T_hedef + cfg.histerezis
                ks.isitici_acik = false;
            end
            P = cfg.P_max * ks.isitici_acik;

        otherwise
            error("Bilinmeyen kontrol: %s", cfg.kontrol);
    end
end

%% ======================= SENSÖR =======================
function T = sicaklik_oku(cfg, sim)
    switch cfg.kaynak
        case "sim"
            % Sanal sensör: gerçek sıcaklık + rastgele gürültü
            T = sim.T_sensor + cfg.sim.gurultu * randn;

        case "labchart"
            % TODO: LabChart'tan ilgili kanalın son değerini okuyun.
            % Cihaz/yazılım netleşince bu satırı doldurun. Şimdilik hata verir.
            error("LabChart okuma henüz yazılmadı. cfg.kaynak = ""sim"" kullanın.");

        otherwise
            error("Bilinmeyen kaynak: %s", cfg.kaynak);
    end
end

%% ======================= AKTÜATÖR =======================
function guc_uygula(cfg, gpp, P)
    switch cfg.cikis
        case "sim"
            % Simülasyonda yapılacak bir şey yok, güç modele veriliyor.
        case "gpp"
            % P = V^2 / R  ->  V = sqrt(P * R)
            V = min(sqrt(P * cfg.R_isitici), 32);
            writeline(gpp, sprintf("VSET%d:%.3f", cfg.gpp_kanal, V));
        otherwise
            error("Bilinmeyen çıkış: %s", cfg.cikis);
    end
end

function guc_kes(gpp, cfg)
    if ~isempty(gpp)
        try
            writeline(gpp, sprintf(":OUTPut%d:STATe OFF", cfg.gpp_kanal));
            disp("Isıtıcı kapatıldı.")
        catch
            warning("Isıtıcı KAPATILAMADI! Güç kaynağının ön panelinden kapatın.");
        end
    end
end

%% ======================= SANAL DÜZENEK =======================
% Isıl model:  C * dT/dt = P - (T - T_ortam) / R_th
%   C    : ısıl kapasite (J/°C)  – ısıtılan blok ne kadar "ağır"
%   R_th : ısıl direnç (°C/W)   – blok çevreye ne kadar kolay ısı veriyor (fan, soğutucu)
% Sensör de birinci dereceden gecikmeyle (tau_sensor) gerçek sıcaklığı izler.
function sim = sanal_duzenek_baslat(cfg)
    sim.T = cfg.sim.T_ortam;
    sim.T_sensor = cfg.sim.T_ortam;
    sim.R_th = cfg.sim.R_th;
end

function sim = sanal_duzenek_adim(cfg, sim, P, t)
    if cfg.kaynak ~= "sim", return, end
    % Bozucu etki: belirli bir anda fan hızlanıyor (soğutma artıyor)
    if t >= cfg.sim.bozucu_zaman_s
        sim.R_th = cfg.sim.R_th_bozucu;
    end
    dT = (P - (sim.T - cfg.sim.T_ortam) / sim.R_th) / cfg.sim.C;
    sim.T = sim.T + dT * cfg.dt;
    sim.T_sensor = sim.T_sensor + (sim.T - sim.T_sensor) * cfg.dt / cfg.sim.tau_sensor;
end

%% ======================= GRAFİK VE ÖZET =======================
function [cizgiT, cizgiP] = grafik_hazirla(cfg)
    figure("Name", "Sıcaklık kontrolü", "Color", "w");
    subplot(2, 1, 1); hold on; grid on;
    yline(cfg.T_hedef, "--", "Hedef", "Color", [0.85 0.33 0.10]);
    yline(cfg.T_limit, ":", "Güvenlik sınırı", "Color", [0.6 0 0]);
    cizgiT = animatedline("Color", [0 0.45 0.74], "LineWidth", 1.2);
    ylabel("Sıcaklık (°C)"); title("Ölçülen sıcaklık (" + cfg.kontrol + ")");
    xlim([0 cfg.sure_s / 60]);
    subplot(2, 1, 2); hold on; grid on;
    cizgiP = animatedline("Color", [0.85 0.33 0.10], "LineWidth", 1.2);
    ylabel("Isıtıcı gücü (W)"); xlabel("Zaman (dk)");
    xlim([0 cfg.sure_s / 60]); ylim([0 cfg.P_max * 1.1]);
end

function ozet_yazdir(cfg, kayit)
    T = kayit.T_olculen;  t = kayit.time_s;
    i = find(T >= cfg.T_hedef - 1, 1);
    fprintf("\n----- Özet -----\n");
    if ~isempty(i)
        fprintf("Hedefin 1 °C yakınına ulaşma süresi : %.1f dk\n", t(i) / 60);
    end
    fprintf("En yüksek sıcaklık                 : %.2f °C\n", max(T));
    son = t >= t(end) - 300;
    fprintf("Son 5 dakika ortalama / sapma      : %.2f °C / ±%.2f °C\n", mean(T(son)), std(T(son)));
    fprintf("Son 5 dakika ortalama güç          : %.1f W\n", mean(kayit.P_W(son)));
end
