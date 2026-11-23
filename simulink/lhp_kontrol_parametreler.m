%LHP_KONTROL_PARAMETRELER  lhp_kontrol.slx modelinin kullandığı tüm sayılar (TUSAŞ senaryosu).
%
%   Model açılırken bu betik otomatik çalışır (PreLoadFcn).
%   Bir değeri değiştirmek için komut penceresine yazın, sonra modeli çalıştırın:
%       T_hedef = 8;
%       lhp_kontrol_calistir
%
%   Değerler matlab/sicaklik_kontrol_ayar.m ile aynıdır.
%   Kaynaklar ve varsayımlar: docs/tusas-buzlanma-kosullari.md

% ----- Hedef, güvenlik, süre -----
T_hedef  = 5;       % test yüzeyi hedef sıcaklığı (°C): 0 °C + 5 °C güvenlik payı
T_buz    = 0;       % bulut sırasında yüzey bunun altına düşerse buz uyarısı (°C)
T_limit  = 90;      % evaporatör bunu aşarsa ısıtıcı kapanır ve kapalı kalır (°C)
dt       = 1;       % kontrol aralığı / adım süresi (s)
sure_s   = 2400;    % simülasyon süresi (s): 10 dk ısınma + 13,4 dk bulut + bulut sonrası
hiz      = 60;      % simülasyon hızı: 60 -> 40 dk 40 saniyede biter. GERÇEK SİSTEMDE 1 OLMALI

% ----- Kontrolcü (PI) -----
Kp    = 10;         % oransal kazanç (W/°C)
Ki    = 0.05;       % integral kazancı (W/(°C·s))
P_max = 48;         % en yüksek ısıtıcı gücü (W). GPP CH1 + 5,33 ohm ısıtıcı ile ≈ 48 W

% ----- TUSAŞ buzlanma koşulları -----
T_soguk      = -10;   % ortam / soğuk taraf sıcaklığı (°C)
q_buz        = 0.67;  % buzlanmada gereken ısı akısı (W/cm²)
t_bulut_bas  = 600;   % bulutun başladığı an (s)
t_bulut_sure = 804;   % bulut süresi (s) = 13,4 dk

% ----- Sanal düzenek (iki düğümlü ısıl model), VARSAYIMLAR -----
A_yuzey    = 50;    % test yüzeyi alanı (cm²). 48 W ısıtıcı için %30 paylı
T_lab      = 25;    % evaporatör tarafındaki oda sıcaklığı (°C)
C_ev       = 300;   % evaporatör + ısıtıcı bloğu ısıl kapasitesi (J/°C)
C_yuzey    = 150;   % test yüzeyi ısıl kapasitesi (J/°C)
R_lhp      = 1.0;   % LHP ısıl direnci, evaporatör -> yüzey (°C/W)
R_ev_kayip = 10;    % evaporatörden odaya kayıp direnci (°C/W)
h_kuru     = 150;   % bulut dışında yüzeyin soğuma katsayısı (W/m²K)
tau_sensor = 5;     % sensör gecikmesi (s)
gurultu    = 0.2;   % sensör gürültüsü, standart sapma (°C)
