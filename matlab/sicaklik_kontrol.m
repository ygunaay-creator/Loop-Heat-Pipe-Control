function kayit = sicaklik_kontrol(cfg)
%SICAKLIK_KONTROL  Isıtıcı gücünü ayarlayarak TEST YÜZEYİNİ hedef sıcaklıkta tutar.
%
%   sicaklik_kontrol()                     varsayılan: TUSAŞ senaryosu, PI, yüzey +5 °C
%   cfg = sicaklik_kontrol_ayar();         ayarları al, değiştir, çalıştır:
%   cfg.kontrol = "ACKAPA";  sicaklik_kontrol(cfg)
%
%   SENARYO (TUSAŞ, docs/tusas-buzlanma-kosullari.md):
%     Soğuk taraf −10 °C. 10. dakikada 13,4 dk sürecek bir "bulut" başlar; bu sürede
%     yüzeyden 0,67 W/cm² ısı çekilir. Yüzey 0 °C'nin altına düşmemelidir.
%
%   ŞU AN: Sensör yok. Sıcaklıklar iki düğümlü bir SANAL DÜZENEK ile üretilir:
%     ısıtıcı -> evaporatör -> LHP -> test yüzeyi -> soğuk taraf
%   İLERİDE: cfg.kaynak = "labchart" ve cfg.cikis = "gpp" ile aynı algoritma gerçek
%   düzenekte çalışır (sicaklik_oku ve guc_uygula fonksiyonları).
%
%   Kontrol yöntemleri:
%     "PI"     : Isıtıcı gücünü 0–Pmax arasında sürekli ayarlar (önerilen)
%     "ACKAPA" : Termostat gibi, ya tam güç ya kapalı (histerezisli)
%
%   Güvenlik:
%     - Evaporatör cfg.T_limit'i aşarsa veya sensör okunamazsa ısıtıcı kapanır, döngü durur.
%     - Ctrl+C ile durdurulursa da ısıtıcı kapanır.
%     - Bulut sırasında yüzey cfg.T_buz'un altına düşerse BUZ UYARISI kaydedilir (ısıtıcı kapanmaz).

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

    % ---------- Sanal düzenek ve kontrolcü başlangıcı ----------
    sim = sanal_duzenek_baslat(cfg);
    ks.integral = 0;
    ks.isitici_acik = false;

    % ---------- Kayıt ve grafik ----------
    N = ceil(cfg.sure_s / cfg.dt);
    adlar = ["time_s", "T_hedef", "T_yuzey_olc", "T_ev_olc", "P_W", "T_yuzey", "T_ev", "bulut", "buz_uyari"];
    kayit = table('Size', [N numel(adlar)], 'VariableTypes', repmat("double", 1, numel(adlar)), ...
                  'VariableNames', adlar);
    g = grafik_hazirla(cfg);

    fprintf("Başladı: %s kontrol, yüzey hedefi %.1f °C, soğuk taraf %.0f °C, bulut %.1f–%.1f dk\n", ...
            cfg.kontrol, cfg.T_hedef, cfg.tusas.T_soguk, cfg.tusas.t_bulut_bas / 60, ...
            (cfg.tusas.t_bulut_bas + cfg.tusas.t_bulut_sure) / 60);

    n = 0;
    uyari_basladi = false;
    for k = 1:N
        t = (k - 1) * cfg.dt;
        bulut = bulut_var_mi(cfg, t);

        % 1) Sıcaklıkları oku: yüzey (kontrol edilen) ve evaporatör (güvenlik)
        [T_yuzey, T_ev] = sicaklik_oku(cfg, sim);

        % 2) Güvenlik
        if isnan(T_yuzey) || isnan(T_ev)
            warning("Sensör okunamadı (t = %.0f s). Isıtıcı kapatıldı.", t);
            break
        end
        if T_ev > cfg.T_limit
            warning("Evaporatör %.1f °C > %.1f °C güvenlik sınırı! Isıtıcı kapatıldı.", T_ev, cfg.T_limit);
            break
        end
        buz_uyari = bulut && T_yuzey < cfg.T_buz;
        if buz_uyari && ~uyari_basladi
            fprintf("!! BUZ UYARISI (%.1f dk): yüzey %.2f °C\n", t / 60, T_yuzey);
        end
        uyari_basladi = buz_uyari;

        % 3) Kontrol kararı ve 4) gücü uygula
        [P, ks] = kontrolcu(cfg, ks, T_yuzey);
        guc_uygula(cfg, gpp, P);

        % 5) Sanal düzeneği bir adım ilerlet (yalnızca simülasyonda)
        sim = sanal_duzenek_adim(cfg, sim, P, bulut);

        % 6) Kaydet ve çiz
        n = k;
        kayit(n, :) = {t, cfg.T_hedef, T_yuzey, T_ev, P, sim.T_yuzey, sim.T_ev, bulut, buz_uyari};
        addpoints(g.yuzey, t / 60, T_yuzey);
        addpoints(g.ev, t / 60, T_ev);
        addpoints(g.guc, t / 60, P);
        if mod(k, 10) == 0, drawnow limitrate; end
        if mod(k, 60) == 0
            fprintf("%5.1f dk | yüzey %6.2f °C | evap. %6.2f °C | P %5.1f W%s\n", ...
                    t / 60, T_yuzey, T_ev, P, string(ifelse(bulut, "  [BULUT]", "")));
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

%% ======================= SENARYO =======================
function b = bulut_var_mi(cfg, t)
    b = t >= cfg.tusas.t_bulut_bas && t < cfg.tusas.t_bulut_bas + cfg.tusas.t_bulut_sure;
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
function [T_yuzey, T_ev] = sicaklik_oku(cfg, sim)
    switch cfg.kaynak
        case "sim"
            % Sanal sensörler: gecikmeli sıcaklık + rastgele gürültü
            T_yuzey = sim.Ts_yuzey + cfg.sim.gurultu * randn;
            T_ev    = sim.Ts_ev    + cfg.sim.gurultu * randn;

        case "labchart"
            % TODO: Cihaz netleşince doldurun.
            %   T_yuzey = min(T_SURF_01 … T_SURF_05)   (en soğuk yüzey noktası)
            %   T_ev    = T_HTR veya T_EV_01           (ısıtıcı / evaporatör)
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
% İki düğümlü ısıl model:
%   C_ev    · dT_ev/dt    = P − Q_lhp − (T_ev − T_lab)/R_ev_kayip
%   C_yuzey · dT_yuzey/dt = Q_lhp − h_kuru·A·(T_yuzey − T_soguk) − bulut·P_su
%   Q_lhp = max(T_ev − T_yuzey, 0) / R_lhp        (LHP ısıyı yalnızca evaporatörden yüzeye taşır)
%   P_su  : bulut sırasında su damlalarının getirdiği ek yük. Yüzey hedefteyken
%           toplam yük = q_buz·A olacak şekilde hesaplanır (TUSAŞ 0,67 W/cm²).
% Sensörler birinci dereceden gecikmeyle (tau_sensor) gerçek sıcaklığı izler.
function sim = sanal_duzenek_baslat(cfg)
    sim.T_ev     = cfg.sim.T_lab;          % evaporatör odada
    sim.T_yuzey  = cfg.tusas.T_soguk;      % yüzey soğuk başlar
    sim.Ts_ev    = sim.T_ev;
    sim.Ts_yuzey = sim.T_yuzey;
end

function sim = sanal_duzenek_adim(cfg, sim, P, bulut)
    if cfg.kaynak ~= "sim", return, end
    s = cfg.sim;  A = s.A_yuzey * 1e-4;                                  % m²
    P_su = (cfg.tusas.q_buz * 1e4 - s.h_kuru * (cfg.T_hedef - cfg.tusas.T_soguk)) * A;

    alt = 10;  h = cfg.dt / alt;                                         % kararlılık için alt adımlar
    for i = 1:alt
        Q_lhp = max(sim.T_ev - sim.T_yuzey, 0) / s.R_lhp;
        dTev = (P - Q_lhp - (sim.T_ev - s.T_lab) / s.R_ev_kayip) / s.C_ev;
        dTyz = (Q_lhp - s.h_kuru * A * (sim.T_yuzey - cfg.tusas.T_soguk) - bulut * P_su) / s.C_yuzey;
        sim.T_ev    = sim.T_ev + dTev * h;
        sim.T_yuzey = sim.T_yuzey + dTyz * h;
        sim.Ts_ev    = sim.Ts_ev    + (sim.T_ev    - sim.Ts_ev)    * h / s.tau_sensor;
        sim.Ts_yuzey = sim.Ts_yuzey + (sim.T_yuzey - sim.Ts_yuzey) * h / s.tau_sensor;
    end
end

%% ======================= GRAFİK VE ÖZET =======================
function g = grafik_hazirla(cfg)
    figure("Name", "Sıcaklık kontrolü – TUSAŞ senaryosu", "Color", "w");
    t1 = cfg.tusas.t_bulut_bas / 60;  t2 = t1 + cfg.tusas.t_bulut_sure / 60;  tson = cfg.sure_s / 60;

    subplot(3, 1, 1); hold on; grid on;
    bulut_golge(t1, t2, [-15 20]);
    yline(cfg.T_hedef, "--", "Hedef", "Color", [0.85 0.33 0.10]);
    yline(cfg.T_buz, "-", "0 °C", "Color", [0 0.6 0.9]);
    g.yuzey = animatedline("Color", [0 0.45 0.74], "LineWidth", 1.2);
    ylabel("Yüzey (°C)"); title("Test yüzeyi (" + cfg.kontrol + ")"); xlim([0 tson]); ylim([-15 20]);

    subplot(3, 1, 2); hold on; grid on;
    bulut_golge(t1, t2, [0 cfg.T_limit + 10]);
    yline(cfg.T_limit, ":", "Güvenlik sınırı", "Color", [0.6 0 0]);
    g.ev = animatedline("Color", [0.47 0.67 0.19], "LineWidth", 1.2);
    ylabel("Evaporatör (°C)"); xlim([0 tson]); ylim([0 cfg.T_limit + 10]);

    subplot(3, 1, 3); hold on; grid on;
    bulut_golge(t1, t2, [0 cfg.P_max * 1.1]);
    g.guc = animatedline("Color", [0.85 0.33 0.10], "LineWidth", 1.2);
    ylabel("Isıtıcı gücü (W)"); xlabel("Zaman (dk)"); xlim([0 tson]); ylim([0 cfg.P_max * 1.1]);
end

function bulut_golge(t1, t2, y)
    patch([t1 t2 t2 t1], [y(1) y(1) y(2) y(2)], [0.85 0.9 1], ...
          "EdgeColor", "none", "FaceAlpha", 0.6, "HandleVisibility", "off");
    text(t1 + 0.2, y(2), "bulut", "VerticalAlignment", "top", "Color", [0.3 0.4 0.6]);
end

function ozet_yazdir(cfg, kayit)
    T = kayit.T_yuzey_olc;  t = kayit.time_s;  b = kayit.bulut == 1;
    fprintf("\n----- Özet -----\n");
    i = find(T >= cfg.T_hedef - 1, 1);
    if ~isempty(i), fprintf("Yüzeyin hedefe (1 °C yakınına) ulaşma süresi : %.1f dk\n", t(i) / 60); end
    if any(b)
        fprintf("Bulut sırasında en düşük yüzey sıcaklığı     : %.2f °C\n", min(T(b)));
        fprintf("Bulut sırasında 0 °C altında kalma süresi     : %.0f s\n", sum(kayit.buz_uyari) * cfg.dt);
        fprintf("Bulut sırasında ortalama / en yüksek güç      : %.1f W / %.1f W\n", mean(kayit.P_W(b)), max(kayit.P_W(b)));
    end
    fprintf("En yüksek evaporatör sıcaklığı               : %.1f °C\n", max(kayit.T_ev_olc));
    son = t >= t(end) - 300;
    fprintf("Son 5 dakika yüzey ortalama / sapma          : %.2f °C / ±%.2f °C\n", mean(T(son)), std(T(son)));
end

function c = ifelse(kosul, a, b)
    if kosul, c = a; else, c = b; end
end
