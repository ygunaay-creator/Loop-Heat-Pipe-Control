function cfg = sicaklik_kontrol_ayar()
%SICAKLIK_KONTROL_AYAR  sicaklik_kontrol için varsayılan ayarlar (TUSAŞ buzlanma senaryosu).
%
%   cfg = sicaklik_kontrol_ayar();
%   cfg.T_hedef = 8;           % örnek: hedefi değiştir
%   sicaklik_kontrol(cfg);
%
%   Değerlerin kaynağı ve varsayımlar: docs/tusas-buzlanma-kosullari.md

    % ----- Hedef, güvenlik, süre -----
    cfg.T_hedef  = 5;         % test yüzeyi hedef sıcaklığı (°C): 0 °C + 5 °C güvenlik payı
    cfg.T_buz    = 0;         % yüzey bunun altına düşerse buz uyarısı (°C)
    cfg.T_limit  = 90;        % evaporatör/ısıtıcı bunu aşarsa ısıtıcı kapanır, döngü durur (°C)
    cfg.dt       = 1;         % kontrol aralığı (s)
    cfg.sure_s   = 2400;      % toplam süre (s): 10 dk ısınma + 13,4 dk bulut + bulut sonrası
    cfg.hiz      = 60;        % simülasyon hızı: 60 -> 40 dk 40 saniyede biter. GERÇEK SİSTEMDE 1 OLMALI

    % ----- Kontrol -----
    cfg.kontrol    = "PI";    % "PI" veya "ACKAPA"
    cfg.P_max      = 48;      % en yüksek ısıtıcı gücü (W). GPP CH1 + 5,33 Ω ısıtıcı ile ≈ 48 W
    cfg.Kp         = 10;      % oransal kazanç (W/°C)
    cfg.Ki         = 0.05;    % integral kazancı (W/(°C·s))
    cfg.histerezis = 1;       % aç-kapa için ±°C bant

    % ----- Giriş/çıkış -----
    cfg.kaynak    = "sim";    % "sim" (sanal düzenek) | "labchart" (ileride)
    cfg.cikis     = "sim";    % "sim" | "gpp" (gerçek ısıtıcı)
    cfg.gpp_port  = "";       % "" = otomatik bul, ya da "COM3"
    cfg.gpp_kanal = 1;
    cfg.R_isitici = 5.33;     % ısıtıcı direnci (ohm), gpp modunda gerilim hesabı için

    % ----- TUSAŞ buzlanma koşulları -----
    cfg.tusas.T_soguk      = -10;   % ortam / soğuk taraf sıcaklığı (°C)
    cfg.tusas.q_buz        = 0.67;  % buzlanmada gereken ısı akısı (W/cm²)
    cfg.tusas.t_bulut_bas  = 600;   % bulutun başladığı an (s)
    cfg.tusas.t_bulut_sure = 804;   % bulut süresi (s) = 13,4 dk

    % ----- Sanal düzenek (yalnızca kaynak = "sim"), VARSAYIMLAR -----
    cfg.sim.A_yuzey    = 50;    % test yüzeyi alanı (cm²). 48 W ısıtıcı için %30 paylı
    cfg.sim.T_lab      = 25;    % evaporatör tarafındaki oda sıcaklığı (°C)
    cfg.sim.C_ev       = 300;   % evaporatör + ısıtıcı bloğu ısıl kapasitesi (J/°C)
    cfg.sim.C_yuzey    = 150;   % test yüzeyi ısıl kapasitesi (J/°C)
    cfg.sim.R_lhp      = 1.0;   % LHP ısıl direnci, evaporatör -> yüzey (°C/W)
    cfg.sim.R_ev_kayip = 10;    % evaporatörden odaya kayıp direnci (°C/W)
    cfg.sim.h_kuru     = 150;   % bulut dışında yüzeyin soğuma katsayısı (W/m²K)
    cfg.sim.tau_sensor = 5;     % sensör gecikmesi (s)
    cfg.sim.gurultu    = 0.2;   % sensör gürültüsü, standart sapma (°C)
end
