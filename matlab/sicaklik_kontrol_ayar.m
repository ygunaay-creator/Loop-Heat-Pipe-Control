function cfg = sicaklik_kontrol_ayar()
%SICAKLIK_KONTROL_AYAR  sicaklik_kontrol için varsayılan ayarlar.
%
%   cfg = sicaklik_kontrol_ayar();
%   cfg.T_hedef = 60;          % örnek: hedefi değiştir
%   sicaklik_kontrol(cfg);

    % ----- Hedef ve süre -----
    cfg.T_hedef  = 80;        % hedef sıcaklık (°C)
    cfg.T_limit  = 100;       % bu sıcaklık aşılırsa ısıtıcı kapanır, döngü durur (°C)
    cfg.dt       = 1;         % kontrol aralığı (s)
    cfg.sure_s   = 3600;      % toplam süre (s)
    cfg.hiz      = 60;        % simülasyon hızı: 60 -> 1 saat 1 dakikada biter. GERÇEK SİSTEMDE 1 OLMALI

    % ----- Kontrol -----
    cfg.kontrol    = "PI";    % "PI" veya "ACKAPA"
    cfg.P_max      = 48;      % en yüksek ısıtıcı gücü (W). GPP CH1 + 5,33 Ω ısıtıcı ile ≈ 48 W
    cfg.Kp         = 8;       % oransal kazanç (W/°C): 1 °C hata için kaç W
    cfg.Ki         = 0.04;    % integral kazancı (W/(°C·s)): kalıcı hatayı yok eder
    cfg.histerezis = 1;       % aç-kapa için ±°C bant

    % ----- Giriş/çıkış -----
    cfg.kaynak    = "sim";    % "sim" (sanal düzenek) | "labchart" (ileride)
    cfg.cikis     = "sim";    % "sim" | "gpp" (gerçek ısıtıcı)
    cfg.gpp_port  = "";       % "" = otomatik bul, ya da "COM3"
    cfg.gpp_kanal = 1;
    cfg.R_isitici = 5.33;     % ısıtıcı direnci (ohm), gpp modunda gerilim hesabı için

    % ----- Sanal düzenek (yalnızca kaynak = "sim") -----
    cfg.sim.T_ortam        = 25;    % °C
    cfg.sim.C              = 300;   % ısıl kapasite (J/°C). ≈ 0,8 kg bakır
    cfg.sim.R_th           = 2.0;   % çevreye ısıl direnç (°C/W). 80 °C için ≈ 27 W gerekir
    cfg.sim.R_th_bozucu    = 1.4;   % bozucu: fan hızlanıyor. 80 °C için ≈ 39 W gerekir
    cfg.sim.bozucu_zaman_s = 1800;  % bozucunun başladığı an (s)
    cfg.sim.tau_sensor     = 5;     % sensör gecikmesi (s)
    cfg.sim.gurultu        = 0.2;   % sensör gürültüsü, standart sapma (°C)
end
