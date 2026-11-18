%LHP_KONTROL_PARAMETRELER  lhp_kontrol.slx modelinin kullandığı tüm sayılar.
%
%   Model açılırken bu betik otomatik çalışır (PreLoadFcn).
%   Bir değeri değiştirmek için komut penceresine yazın, sonra modeli çalıştırın:
%       T_hedef = 60;
%       lhp_kontrol_calistir
%
%   Değerler matlab/sicaklik_kontrol_ayar.m ile aynıdır.

% ----- Hedef ve süre -----
T_hedef  = 80;      % hedef sıcaklık (°C)
T_limit  = 100;     % bu sıcaklık aşılırsa ısıtıcı kapanır ve kapalı kalır (°C)
dt       = 1;       % kontrol aralığı / adım süresi (s)
sure_s   = 3600;    % simülasyon süresi (s)
hiz      = 60;      % simülasyon hızı: 60 -> 1 saat 1 dakikada biter. GERÇEK SİSTEMDE 1 OLMALI

% ----- Kontrolcü (PI) -----
Kp    = 8;          % oransal kazanç (W/°C)
Ki    = 0.04;       % integral kazancı (W/(°C·s))
P_max = 48;         % en yüksek ısıtıcı gücü (W). GPP CH1 + 5,33 ohm ısıtıcı ile ≈ 48 W

% ----- Sanal düzenek (ısıl model) -----
T_ortam     = 25;   % ortam sıcaklığı (°C)
C           = 300;  % ısıl kapasite (J/°C), ≈ 0,8 kg bakır
R_th        = 2.0;  % çevreye ısıl direnç (°C/W). 80 °C için ≈ 27 W gerekir
R_th_bozucu = 1.4;  % bozucu: soğutma artıyor. 80 °C için ≈ 39 W gerekir
t_bozucu    = 1800; % bozucunun başladığı an (s)
tau_sensor  = 5;    % sensör gecikmesi (s)
gurultu     = 0.2;  % sensör gürültüsü, standart sapma (°C)
