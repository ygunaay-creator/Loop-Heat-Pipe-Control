function lhp_kontrol_modeli_olustur()
%LHP_KONTROL_MODELI_OLUSTUR  lhp_kontrol.slx Simulink modelini sıfırdan kurar ve kaydeder.
%
%   Bu klasörde komut penceresine yazın:
%       lhp_kontrol_modeli_olustur
%   Model kurulur, bu klasöre lhp_kontrol.slx olarak kaydedilir ve açılır.
%   (Eski lhp_kontrol.slx varsa üzerine yazılır.)
%   Sonra çalıştırmak için:  lhp_kontrol_calistir
%
%   Amaç: TEST YÜZEYİNİ +5 °C'de tutmak (TUSAŞ buzlanma senaryosu,
%   docs/tusas-buzlanma-kosullari.md).
%
%   Model yapısı (üst seviye):
%
%     Hedef ─▶ Hata ─▶ PI_Kontrolcu ─▶ Guvenlik ─▶ Duzenek_SANAL ─┬─▶ T_yuzey_olc
%               ▲                       ▲  ▲  ▲  ▲                 ├─▶ T_ev_olc
%               └───────────────────────┘  │  │  │                 │
%                       T_ev_olc ──────────┘  │  │                 │
%                       Harici_Stop ──────────┘  │                 │
%                       Senaryo_TUSAS (bulut) ───┴─────────────────┘
%
%   PI_Kontrolcu  : Discrete PID bloğu, PI modu, 0–P_max sınırı, clamping anti-windup.
%                   Kontrol edilen: test yüzeyi sıcaklığı.
%   Guvenlik      : Evaporatör > T_limit, sensör arızası (< -50 °C) veya harici stop -> güç 0
%                   (mandal: simülasyon sonuna kadar kapalı kalır).
%                   Bulut varken yüzey < T_buz -> buz_uyari (ısıtıcı kapanmaz).
%   Senaryo_TUSAS : t_bulut_bas anında başlayan, t_bulut_sure (13,4 dk) süren bulut sinyali (0/1).
%   Duzenek_SANAL : İki düğümlü ısıl model: ısıtıcı -> evaporatör -> LHP -> yüzey -> soğuk taraf.
%                   Gerçek sistemde bu blok, güç kaynağına yazan ve DAQ'tan okuyan bir blokla
%                   değiştirilecek. Giriş (P_W) ve çıkışlar (T_yuzey_olc, T_ev_olc) aynı kalacak.
%   Harici_Stop   : Şimdilik 0. İleride Stewart Platformu'nun acil stop sinyali buraya bağlanır.

    mdl = 'lhp_kontrol';
    klasor = fileparts(mfilename('fullpath'));
    addpath(klasor);
    evalin('base', 'lhp_kontrol_parametreler');

    if bdIsLoaded(mdl), close_system(mdl, 0); end
    dosya = fullfile(klasor, [mdl '.slx']);
    if isfile(dosya), delete(dosya); end

    new_system(mdl);
    set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'ode4', 'FixedStep', 'dt', ...
                   'StopTime', 'sure_s', 'SolverMode', 'SingleTasking', ...
                   'PreLoadFcn', 'lhp_kontrol_parametreler');
    try  % Simulation Pacing: simülasyonu gerçek zamana göre yavaşlatır (R2018a+)
        set_param(mdl, 'EnablePacing', 'on', 'PacingRate', num2str(evalin('base', 'hiz')));
    catch
        warning('Simulation Pacing ayarlanamadı; simülasyon olabildiğince hızlı koşacak.');
    end

    % ================= ÜST SEVİYE BLOKLAR =================
    blok('simulink/Sources/Constant', 'Hedef', [40 90 100 120], 'Value', 'T_hedef');
    blok('simulink/Math Operations/Sum', 'Hata', [150 90 170 130], 'Inputs', '|+-', 'IconShape', 'round');
    blok('simulink/Discrete/Discrete PID Controller', 'PI_Kontrolcu', [220 85 320 135], ...
        'Controller', 'PI', 'P', 'Kp', 'I', 'Ki', 'SampleTime', 'dt', ...
        'LimitOutput', 'on', 'UpperSaturationLimit', 'P_max', 'LowerSaturationLimit', '0', ...
        'AntiWindupMode', 'clamping');
    blok('simulink/Sources/Constant', 'Harici_Stop', [220 230 280 260], 'Value', '0');

    senaryo_kur([mdl '/Senaryo_TUSAS'], [220 300 320 340]);
    guvenlik_kur([mdl '/Guvenlik'], [380 80 500 260]);
    duzenek_kur([mdl '/Duzenek_SANAL'], [560 90 690 200]);

    % Kayıt ve grafik
    blok('simulink/Signal Routing/Mux', 'Mux_Yuzey', [760 30 765 110], 'Inputs', '3');
    blok('simulink/Sinks/Scope', 'Yuzey_Sicakligi', [800 50 840 90]);
    blok('simulink/Sinks/Scope', 'Evaporator', [800 130 840 170]);
    blok('simulink/Signal Routing/Mux', 'Mux_Guc', [760 220 765 280], 'Inputs', '2');
    blok('simulink/Math Operations/Gain', 'Bulut_Goster', [690 260 730 290], 'Gain', 'P_max');
    blok('simulink/Sinks/Scope', 'Guc', [800 230 840 270]);
    blok('simulink/Signal Routing/Mux', 'Mux_Kayit', [760 320 765 480], 'Inputs', '8');
    blok('simulink/Sinks/To Workspace', 'Kayit', [800 385 880 415], ...
        'VariableName', 'kayit', 'SaveFormat', 'Structure With Time');

    % ================= BAĞLANTILAR =================
    hat('Hedef/1', 'Hata/1');
    hat('Duzenek_SANAL/1', 'Hata/2');
    hat('Hata/1', 'PI_Kontrolcu/1');
    hat('PI_Kontrolcu/1', 'Guvenlik/1');
    hat('Duzenek_SANAL/1', 'Guvenlik/2');
    hat('Duzenek_SANAL/2', 'Guvenlik/3');
    hat('Harici_Stop/1', 'Guvenlik/4');
    hat('Senaryo_TUSAS/1', 'Guvenlik/5');
    hat('Guvenlik/1', 'Duzenek_SANAL/1');
    hat('Senaryo_TUSAS/1', 'Duzenek_SANAL/2');

    % Scope'lar: yüzey (hedef, ölçülen, 0 °C çizgisi yerine buz sınırı sabiti), evaporatör, güç + bulut
    blok('simulink/Sources/Constant', 'Buz_Siniri', [690 60 730 80], 'Value', 'T_buz');
    hat('Hedef/1', 'Mux_Yuzey/1');
    hat('Duzenek_SANAL/1', 'Mux_Yuzey/2');
    hat('Buz_Siniri/1', 'Mux_Yuzey/3');
    hat('Mux_Yuzey/1', 'Yuzey_Sicakligi/1');
    hat('Duzenek_SANAL/2', 'Evaporator/1');
    hat('Guvenlik/1', 'Mux_Guc/1');
    hat('Senaryo_TUSAS/1', 'Bulut_Goster/1');
    hat('Bulut_Goster/1', 'Mux_Guc/2');
    hat('Mux_Guc/1', 'Guc/1');

    % kayit.signals.values sütunları:
    %  1 T_hedef | 2 T_yuzey_olc | 3 P_W | 4 T_yuzey | 5 T_ev | 6 alarm | 7 buz_uyari | 8 bulut
    hat('Hedef/1', 'Mux_Kayit/1');
    hat('Duzenek_SANAL/1', 'Mux_Kayit/2');
    hat('Guvenlik/1', 'Mux_Kayit/3');
    hat('Duzenek_SANAL/3', 'Mux_Kayit/4');
    hat('Duzenek_SANAL/4', 'Mux_Kayit/5');
    hat('Guvenlik/2', 'Mux_Kayit/6');
    hat('Guvenlik/3', 'Mux_Kayit/7');
    hat('Senaryo_TUSAS/1', 'Mux_Kayit/8');

    % Sinyal adları
    sinyal_adi('Duzenek_SANAL', 1, 'T_yuzey_olc');
    sinyal_adi('Duzenek_SANAL', 2, 'T_ev_olc');
    sinyal_adi('Duzenek_SANAL', 3, 'T_yuzey');
    sinyal_adi('Duzenek_SANAL', 4, 'T_ev');
    sinyal_adi('Guvenlik', 1, 'P_W');
    sinyal_adi('Guvenlik', 2, 'alarm');
    sinyal_adi('Guvenlik', 3, 'buz_uyari');
    sinyal_adi('PI_Kontrolcu', 1, 'P_komut');
    sinyal_adi('Senaryo_TUSAS', 1, 'bulut');

    try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end

    try
        nt = Simulink.Annotation([mdl '/not']);
        nt.Text = sprintf(['LHP test yüzeyi sıcaklık kontrolü – TUSAŞ buzlanma senaryosu (sanal düzenek)\n' ...
            'Hedef: yüzey +5 °C | Soğuk taraf −10 °C | Bulut: 10. dk, 13,4 dk, 0,67 W/cm²\n' ...
            'Parametreler: lhp_kontrol_parametreler.m   Çalıştırma: lhp_kontrol_calistir\n' ...
            'Gerçek sistemde Duzenek_SANAL yerine güç kaynağı + DAQ bloğu gelecek.']);
        nt.Position = [40 -70 640 -10];
    catch
    end

    save_system(mdl, dosya);
    open_system(mdl);
    fprintf('Model kaydedildi: %s\nÇalıştırmak için: lhp_kontrol_calistir\n', dosya);

    % ---------- yardımcılar ----------
    function blok(kaynak, ad, konum, varargin)
        add_block(kaynak, [mdl '/' ad], 'Position', konum, varargin{:});
    end
    function hat(a, b)
        add_line(mdl, a, b, 'autorouting', 'on');
    end
    function sinyal_adi(ad, port, isim)
        ph = get_param([mdl '/' ad], 'PortHandles');
        set_param(ph.Outport(port), 'Name', isim);
    end
end

%% ======================= SENARYO ALT SİSTEMİ =======================
% bulut = 1, t_bulut_bas <= t < t_bulut_bas + t_bulut_sure ; değilse 0
function senaryo_kur(yol, konum)
    add_block('simulink/Ports & Subsystems/Subsystem', yol, 'Position', konum);
    Simulink.SubSystem.deleteContents(yol);
    b = @(kaynak, ad, k, varargin) add_block(kaynak, [yol '/' ad], 'Position', k, varargin{:});
    b('simulink/Sources/Step', 'Bulut_Basliyor', [40 30 70 60], ...
        'Time', 't_bulut_bas', 'Before', '0', 'After', '1', 'SampleTime', '0');
    b('simulink/Sources/Step', 'Bulut_Bitiyor', [40 100 70 130], ...
        'Time', 't_bulut_bas + t_bulut_sure', 'Before', '0', 'After', '1', 'SampleTime', '0');
    b('simulink/Math Operations/Sum', 'Fark', [120 60 140 100], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Sinks/Out1', 'bulut', [190 73 220 87]);
    h = @(a, c) add_line(yol, a, c, 'autorouting', 'on');
    h('Bulut_Basliyor/1', 'Fark/1');
    h('Bulut_Bitiyor/1', 'Fark/2');
    h('Fark/1', 'bulut/1');
end

%% ======================= GÜVENLİK ALT SİSTEMİ =======================
function guvenlik_kur(yol, konum)
    add_block('simulink/Ports & Subsystems/Subsystem', yol, 'Position', konum);
    Simulink.SubSystem.deleteContents(yol);

    b = @(kaynak, ad, k, varargin) add_block(kaynak, [yol '/' ad], 'Position', k, varargin{:});
    b('simulink/Sources/In1',  'P_komut',     [20  40  50  54]);
    b('simulink/Sources/In1',  'T_yuzey_olc', [20 120  50 134]);
    b('simulink/Sources/In1',  'T_ev_olc',    [20 200  50 214]);
    b('simulink/Sources/In1',  'harici_stop', [20 280  50 294]);
    b('simulink/Sources/In1',  'bulut',       [20 360  50 374]);

    % --- Isıtıcıyı kesen durumlar ---
    b('simulink/Sources/Constant', 'T_limit', [90 230 130 250], 'Value', 'T_limit');
    b('simulink/Logic and Bit Operations/Relational Operator', 'Asiri_Sicak', [170 195 210 235], 'Operator', '>');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Yuzey_Sensor_Ariza', [170 115 230 145], ...
        'relop', '<', 'const', '-50');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Ev_Sensor_Ariza', [170 255 230 285], ...
        'relop', '<', 'const', '-50');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Stop_Var', [170 290 230 320], ...
        'relop', '>', 'const', '0');
    b('simulink/Logic and Bit Operations/Logical Operator', 'VEYA', [290 110 320 330], ...
        'Operator', 'OR', 'Inputs', '5');
    b('simulink/Discrete/Unit Delay', 'Alarm_Mandal', [300 350 340 380], ...
        'InitialCondition', '0', 'SampleTime', 'dt');
    b('simulink/Sources/Constant', 'Sifir', [290 20 320 40], 'Value', '0');
    b('simulink/Signal Routing/Switch', 'Guc_Kes', [400 30 440 110], 'Criteria', 'u2 ~= 0');
    b('simulink/Signal Attributes/Data Type Conversion', 'Alarm_Double', [380 200 430 230], ...
        'OutDataTypeStr', 'double');

    % --- Buz uyarısı: bulut varken yüzey < T_buz ---
    b('simulink/Sources/Constant', 'T_buz', [90 420 130 440], 'Value', 'T_buz');
    b('simulink/Logic and Bit Operations/Relational Operator', 'Yuzey_Donuyor', [170 400 210 440], 'Operator', '<');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Bulut_Var', [170 460 230 490], ...
        'relop', '>', 'const', '0.5');
    b('simulink/Logic and Bit Operations/Logical Operator', 'VE', [290 420 320 480], ...
        'Operator', 'AND', 'Inputs', '2');
    b('simulink/Signal Attributes/Data Type Conversion', 'Buz_Double', [380 435 430 465], ...
        'OutDataTypeStr', 'double');

    b('simulink/Sinks/Out1', 'P_uygula',  [500  63 530  77]);
    b('simulink/Sinks/Out1', 'alarm',     [500 208 530 222]);
    b('simulink/Sinks/Out1', 'buz_uyari', [500 443 530 457]);

    h = @(a, c) add_line(yol, a, c, 'autorouting', 'on');
    h('T_ev_olc/1', 'Asiri_Sicak/1');
    h('T_limit/1', 'Asiri_Sicak/2');
    h('T_yuzey_olc/1', 'Yuzey_Sensor_Ariza/1');
    h('T_ev_olc/1', 'Ev_Sensor_Ariza/1');
    h('harici_stop/1', 'Stop_Var/1');
    h('Asiri_Sicak/1', 'VEYA/1');
    h('Yuzey_Sensor_Ariza/1', 'VEYA/2');
    h('Ev_Sensor_Ariza/1', 'VEYA/3');
    h('Stop_Var/1', 'VEYA/4');
    h('Alarm_Mandal/1', 'VEYA/5');
    h('VEYA/1', 'Alarm_Mandal/1');
    % Switch: girişler 1 = alarm varken (0 W), 2 = kontrol (alarm), 3 = alarm yokken (P_komut)
    h('Sifir/1', 'Guc_Kes/1');
    h('VEYA/1', 'Guc_Kes/2');
    h('P_komut/1', 'Guc_Kes/3');
    h('Guc_Kes/1', 'P_uygula/1');
    h('VEYA/1', 'Alarm_Double/1');
    h('Alarm_Double/1', 'alarm/1');

    h('T_yuzey_olc/1', 'Yuzey_Donuyor/1');
    h('T_buz/1', 'Yuzey_Donuyor/2');
    h('bulut/1', 'Bulut_Var/1');
    h('Yuzey_Donuyor/1', 'VE/1');
    h('Bulut_Var/1', 'VE/2');
    h('VE/1', 'Buz_Double/1');
    h('Buz_Double/1', 'buz_uyari/1');
    try, Simulink.BlockDiagram.arrangeSystem(yol); catch, end
end

%% ======================= SANAL DÜZENEK ALT SİSTEMİ =======================
% İki düğümlü ısıl model:
%   C_ev    · dT_ev/dt    = P − Q_lhp − (T_ev − T_lab)/R_ev_kayip
%   C_yuzey · dT_yuzey/dt = Q_lhp − h_kuru·A·(T_yuzey − T_soguk) − bulut·P_su
%   Q_lhp = max(T_ev − T_yuzey, 0) / R_lhp
%   P_su  = (q_buz·1e4 − h_kuru·(T_hedef − T_soguk))·A   -> yüzey hedefteyken toplam yük = q_buz·A
% Sensörler: dTs/dt = (T − Ts)/tau_sensor, üzerine gürültü.
% Çıkışlar: 1 T_yuzey_olc | 2 T_ev_olc | 3 T_yuzey (gerçek) | 4 T_ev (gerçek)
function duzenek_kur(yol, konum)
    add_block('simulink/Ports & Subsystems/Subsystem', yol, 'Position', konum);
    Simulink.SubSystem.deleteContents(yol);

    b = @(kaynak, ad, k, varargin) add_block(kaynak, [yol '/' ad], 'Position', k, varargin{:});
    b('simulink/Sources/In1', 'P_W',   [20  40  50  54]);
    b('simulink/Sources/In1', 'bulut', [20 400  50 414]);

    % --- Evaporatör düğümü ---
    b('simulink/Math Operations/Sum', 'Ev_Denge', [100 30 120 90], 'Inputs', '|+--', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_C_ev', [150 45 200 75], 'Gain', '1/C_ev');
    b('simulink/Continuous/Integrator', 'T_evaporator', [230 45 260 75], 'InitialCondition', 'T_lab');
    b('simulink/Sources/Constant', 'T_lab', [230 120 270 140], 'Value', 'T_lab');
    b('simulink/Math Operations/Sum', 'Ev_Oda_Fark', [300 110 320 150], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Ev_Kayip_W', [350 115 400 145], 'Gain', '1/R_ev_kayip');

    % --- LHP: yalnızca evaporatörden yüzeye ---
    b('simulink/Math Operations/Sum', 'LHP_Fark', [300 190 320 230], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Discontinuities/Saturation', 'Tek_Yon', [350 195 390 225], ...
        'UpperLimit', 'inf', 'LowerLimit', '0');
    b('simulink/Math Operations/Gain', 'Q_LHP_W', [420 195 470 225], 'Gain', '1/R_lhp');

    % --- Yüzey düğümü ---
    b('simulink/Math Operations/Sum', 'Yuzey_Denge', [500 250 520 310], 'Inputs', '|+--', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_C_yuzey', [550 265 600 295], 'Gain', '1/C_yuzey');
    b('simulink/Continuous/Integrator', 'T_test_yuzeyi', [630 265 660 295], 'InitialCondition', 'T_soguk');
    b('simulink/Sources/Constant', 'T_soguk', [630 330 670 350], 'Value', 'T_soguk');
    b('simulink/Math Operations/Sum', 'Yuzey_Soguk_Fark', [700 320 720 360], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Kuru_Kayip_W', [750 325 820 355], 'Gain', 'h_kuru*A_yuzey*1e-4');
    b('simulink/Math Operations/Gain', 'Su_Yuku_W', [100 390 220 420], ...
        'Gain', '(q_buz*1e4 - h_kuru*(T_hedef - T_soguk))*A_yuzey*1e-4');

    % --- Sensörler ---
    b('simulink/Math Operations/Sum', 'Sensor_Yuzey_Fark', [700 440 720 480], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_tau_1', [750 445 800 475], 'Gain', '1/tau_sensor');
    b('simulink/Continuous/Integrator', 'Sensor_Yuzey', [830 445 860 475], 'InitialCondition', 'T_soguk');
    b('simulink/Sources/Random Number', 'Gurultu_1', [830 500 860 530], ...
        'Mean', '0', 'Variance', 'gurultu^2', 'Seed', '1', 'SampleTime', 'dt');
    b('simulink/Math Operations/Sum', 'Gurultu_Ekle_1', [900 460 920 500], 'Inputs', '|++', 'IconShape', 'round');

    b('simulink/Math Operations/Sum', 'Sensor_Ev_Fark', [700 560 720 600], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_tau_2', [750 565 800 595], 'Gain', '1/tau_sensor');
    b('simulink/Continuous/Integrator', 'Sensor_Ev', [830 565 860 595], 'InitialCondition', 'T_lab');
    b('simulink/Sources/Random Number', 'Gurultu_2', [830 620 860 650], ...
        'Mean', '0', 'Variance', 'gurultu^2', 'Seed', '2', 'SampleTime', 'dt');
    b('simulink/Math Operations/Sum', 'Gurultu_Ekle_2', [900 580 920 620], 'Inputs', '|++', 'IconShape', 'round');

    b('simulink/Sinks/Out1', 'T_yuzey_olc', [980 473 1010 487]);
    b('simulink/Sinks/Out1', 'T_ev_olc',    [980 593 1010 607]);
    b('simulink/Sinks/Out1', 'T_yuzey',     [980 273 1010 287]);
    b('simulink/Sinks/Out1', 'T_ev',        [980  53 1010  67]);

    h = @(a, c) add_line(yol, a, c, 'autorouting', 'on');
    % evaporatör
    h('P_W/1', 'Ev_Denge/1');
    h('Q_LHP_W/1', 'Ev_Denge/2');
    h('Ev_Kayip_W/1', 'Ev_Denge/3');
    h('Ev_Denge/1', 'Bolu_C_ev/1');
    h('Bolu_C_ev/1', 'T_evaporator/1');
    h('T_evaporator/1', 'Ev_Oda_Fark/1');
    h('T_lab/1', 'Ev_Oda_Fark/2');
    h('Ev_Oda_Fark/1', 'Ev_Kayip_W/1');
    % LHP
    h('T_evaporator/1', 'LHP_Fark/1');
    h('T_test_yuzeyi/1', 'LHP_Fark/2');
    h('LHP_Fark/1', 'Tek_Yon/1');
    h('Tek_Yon/1', 'Q_LHP_W/1');
    % yüzey
    h('Q_LHP_W/1', 'Yuzey_Denge/1');
    h('Kuru_Kayip_W/1', 'Yuzey_Denge/2');
    h('Su_Yuku_W/1', 'Yuzey_Denge/3');
    h('Yuzey_Denge/1', 'Bolu_C_yuzey/1');
    h('Bolu_C_yuzey/1', 'T_test_yuzeyi/1');
    h('T_test_yuzeyi/1', 'Yuzey_Soguk_Fark/1');
    h('T_soguk/1', 'Yuzey_Soguk_Fark/2');
    h('Yuzey_Soguk_Fark/1', 'Kuru_Kayip_W/1');
    h('bulut/1', 'Su_Yuku_W/1');
    % sensörler
    h('T_test_yuzeyi/1', 'Sensor_Yuzey_Fark/1');
    h('Sensor_Yuzey/1', 'Sensor_Yuzey_Fark/2');
    h('Sensor_Yuzey_Fark/1', 'Bolu_tau_1/1');
    h('Bolu_tau_1/1', 'Sensor_Yuzey/1');
    h('Sensor_Yuzey/1', 'Gurultu_Ekle_1/1');
    h('Gurultu_1/1', 'Gurultu_Ekle_1/2');
    h('Gurultu_Ekle_1/1', 'T_yuzey_olc/1');
    h('T_evaporator/1', 'Sensor_Ev_Fark/1');
    h('Sensor_Ev/1', 'Sensor_Ev_Fark/2');
    h('Sensor_Ev_Fark/1', 'Bolu_tau_2/1');
    h('Bolu_tau_2/1', 'Sensor_Ev/1');
    h('Sensor_Ev/1', 'Gurultu_Ekle_2/1');
    h('Gurultu_2/1', 'Gurultu_Ekle_2/2');
    h('Gurultu_Ekle_2/1', 'T_ev_olc/1');
    % gerçek değerler
    h('T_test_yuzeyi/1', 'T_yuzey/1');
    h('T_evaporator/1', 'T_ev/1');
    try, Simulink.BlockDiagram.arrangeSystem(yol); catch, end
end
