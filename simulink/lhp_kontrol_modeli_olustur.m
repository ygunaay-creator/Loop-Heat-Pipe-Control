function lhp_kontrol_modeli_olustur()
%LHP_KONTROL_MODELI_OLUSTUR  lhp_kontrol.slx Simulink modelini sıfırdan kurar ve kaydeder.
%
%   Bu klasörde komut penceresine yazın:
%       lhp_kontrol_modeli_olustur
%   Model kurulur, bu klasöre lhp_kontrol.slx olarak kaydedilir ve açılır.
%   Sonra çalıştırmak için:  lhp_kontrol_calistir
%
%   Model yapısı (üst seviye):
%
%     Hedef ──▶ Hata ──▶ PI_Kontrolcu ──▶ Guvenlik ──▶ Duzenek_SANAL ──┬──▶ T_olculen
%                ▲                          ▲   ▲                       │
%                └──────────────────────────┼───┴───────────────────────┘
%                              Harici_Stop ─┘
%
%   PI_Kontrolcu : Simulink Discrete PID bloğu, PI modu, 0–P_max sınırı, clamping anti-windup
%   Guvenlik     : T > T_limit, sensör arızası (T < -50 °C) veya harici stop -> güç 0.
%                  Alarm bir kez oluşursa simülasyon sonuna kadar kalır (mandal).
%   Duzenek_SANAL: C·dT/dt = P - (T - T_ortam)/R_th, sensör gecikmesi ve gürültüsü.
%                  Gerçek sistemde bu blok, güç kaynağına yazan ve DAQ'tan okuyan
%                  bir blokla değiştirilecek. Giriş (P_W) ve çıkışlar aynı kalacak.
%   Harici_Stop  : Şimdilik 0. İleride Stewart Platformu'nun acil stop sinyali buraya bağlanır.

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
    blok('simulink/Sources/Constant', 'Harici_Stop', [220 190 280 220], 'Value', '0');

    guvenlik_kur([mdl '/Guvenlik'], [380 80 500 200]);
    duzenek_kur([mdl '/Duzenek_SANAL'], [560 90 680 170]);

    % Kayıt ve grafik
    blok('simulink/Signal Routing/Mux', 'Mux_Sicaklik', [760 40 765 100], 'Inputs', '2');
    blok('simulink/Sinks/Scope', 'Sicaklik', [800 50 840 90]);
    blok('simulink/Sinks/Scope', 'Guc', [800 250 840 290]);
    blok('simulink/Signal Routing/Mux', 'Mux_Kayit', [760 320 765 420], 'Inputs', '5');
    blok('simulink/Sinks/To Workspace', 'Kayit', [800 355 880 385], ...
        'VariableName', 'kayit', 'SaveFormat', 'Structure With Time');

    % ================= BAĞLANTILAR =================
    hat('Hedef/1', 'Hata/1');
    hat('Duzenek_SANAL/2', 'Hata/2');
    hat('Hata/1', 'PI_Kontrolcu/1');
    hat('PI_Kontrolcu/1', 'Guvenlik/1');
    hat('Duzenek_SANAL/2', 'Guvenlik/2');
    hat('Harici_Stop/1', 'Guvenlik/3');
    hat('Guvenlik/1', 'Duzenek_SANAL/1');

    hat('Hedef/1', 'Mux_Sicaklik/1');
    hat('Duzenek_SANAL/2', 'Mux_Sicaklik/2');
    hat('Mux_Sicaklik/1', 'Sicaklik/1');
    hat('Guvenlik/1', 'Guc/1');

    % kayit.signals.values sütunları: 1 T_hedef | 2 T_olculen | 3 P_W | 4 T_gercek | 5 alarm
    hat('Hedef/1', 'Mux_Kayit/1');
    hat('Duzenek_SANAL/2', 'Mux_Kayit/2');
    hat('Guvenlik/1', 'Mux_Kayit/3');
    hat('Duzenek_SANAL/1', 'Mux_Kayit/4');
    hat('Guvenlik/2', 'Mux_Kayit/5');

    % Sinyal adları (grafiklerde ve hatlarda görünür)
    sinyal_adi('Duzenek_SANAL', 2, 'T_olculen');
    sinyal_adi('Duzenek_SANAL', 1, 'T_gercek');
    sinyal_adi('Guvenlik', 1, 'P_W');
    sinyal_adi('Guvenlik', 2, 'alarm');
    sinyal_adi('PI_Kontrolcu', 1, 'P_komut');

    % Düzen
    try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end

    try
        nt = Simulink.Annotation([mdl '/not']);
        nt.Text = sprintf(['LHP sıcaklık kontrolü (sanal düzenek)\n' ...
            'Parametreler: lhp_kontrol_parametreler.m   Çalıştırma: lhp_kontrol_calistir\n' ...
            'Gerçek sistemde Duzenek_SANAL yerine güç kaynağı + DAQ bloğu gelecek.\n' ...
            'Harici_Stop: ileride Stewart Platformu acil stop sinyali.']);
        nt.Position = [40 -60 600 -10];
    catch
    end

    save_system(mdl, dosya);
    open_system(mdl);
    fprintf('Model kaydedildi: %s\nÇalıştırmak için: lhp_kontrol_calistir\n', dosya);

    % ---------- yardımcılar (mdl'ye erişsin diye iç içe) ----------
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

%% ======================= GÜVENLİK ALT SİSTEMİ =======================
function guvenlik_kur(yol, konum)
    add_block('simulink/Ports & Subsystems/Subsystem', yol, 'Position', konum);
    Simulink.SubSystem.deleteContents(yol);

    b = @(kaynak, ad, k, varargin) add_block(kaynak, [yol '/' ad], 'Position', k, varargin{:});
    b('simulink/Sources/In1',  'P_komut',     [20  40  50  54]);
    b('simulink/Sources/In1',  'T_olculen',   [20 120  50 134]);
    b('simulink/Sources/In1',  'harici_stop', [20 260  50 274]);

    b('simulink/Sources/Constant', 'T_limit', [90 150 130 170], 'Value', 'T_limit');
    b('simulink/Logic and Bit Operations/Relational Operator', 'Asiri_Sicak', [170 115 210 155], 'Operator', '>');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Sensor_Ariza', [170 190 230 220], ...
        'relop', '<', 'const', '-50');
    b('simulink/Logic and Bit Operations/Compare To Constant', 'Stop_Var', [170 255 230 285], ...
        'relop', '>', 'const', '0');
    b('simulink/Logic and Bit Operations/Logical Operator', 'VEYA', [290 120 320 290], ...
        'Operator', 'OR', 'Inputs', '4');
    b('simulink/Discrete/Unit Delay', 'Alarm_Mandal', [300 330 340 360], ...
        'InitialCondition', '0', 'SampleTime', 'dt');
    b('simulink/Sources/Constant', 'Sifir', [290 20 320 40], 'Value', '0');
    b('simulink/Signal Routing/Switch', 'Guc_Kes', [400 30 440 110], 'Criteria', 'u2 ~= 0');
    b('simulink/Signal Attributes/Data Type Conversion', 'Double', [380 190 430 220], ...
        'OutDataTypeStr', 'double');
    b('simulink/Sinks/Out1', 'P_uygula', [500 63 530 77]);
    b('simulink/Sinks/Out1', 'alarm',    [500 198 530 212]);

    h = @(a, c) add_line(yol, a, c, 'autorouting', 'on');
    h('T_olculen/1', 'Asiri_Sicak/1');
    h('T_limit/1', 'Asiri_Sicak/2');
    h('T_olculen/1', 'Sensor_Ariza/1');
    h('harici_stop/1', 'Stop_Var/1');
    h('Asiri_Sicak/1', 'VEYA/1');
    h('Sensor_Ariza/1', 'VEYA/2');
    h('Stop_Var/1', 'VEYA/3');
    h('Alarm_Mandal/1', 'VEYA/4');
    h('VEYA/1', 'Alarm_Mandal/1');
    % Switch: girişler 1 = alarm varken (0 W), 2 = kontrol (alarm), 3 = alarm yokken (P_komut)
    h('Sifir/1', 'Guc_Kes/1');
    h('VEYA/1', 'Guc_Kes/2');
    h('P_komut/1', 'Guc_Kes/3');
    h('Guc_Kes/1', 'P_uygula/1');
    h('VEYA/1', 'Double/1');
    h('Double/1', 'alarm/1');
    try, Simulink.BlockDiagram.arrangeSystem(yol); catch, end
end

%% ======================= SANAL DÜZENEK ALT SİSTEMİ =======================
% C·dT/dt = P - (T - T_ortam)/R_th      (R_th, t_bozucu anında R_th_bozucu olur)
% dTs/dt  = (T - Ts)/tau_sensor         (sensör gecikmesi)
% T_olculen = Ts + gürültü
function duzenek_kur(yol, konum)
    add_block('simulink/Ports & Subsystems/Subsystem', yol, 'Position', konum);
    Simulink.SubSystem.deleteContents(yol);

    b = @(kaynak, ad, k, varargin) add_block(kaynak, [yol '/' ad], 'Position', k, varargin{:});
    b('simulink/Sources/In1', 'P_W', [20 40 50 54]);
    b('simulink/Math Operations/Sum', 'Isi_Dengesi', [110 35 130 75], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_C', [170 40 220 70], 'Gain', '1/C');
    b('simulink/Continuous/Integrator', 'T_blok', [260 40 290 70], 'InitialCondition', 'T_ortam');

    b('simulink/Sources/Constant', 'T_ortam', [260 120 300 140], 'Value', 'T_ortam');
    b('simulink/Math Operations/Sum', 'Fark', [340 100 360 140], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Sources/Step', 'R_th', [340 170 370 200], ...
        'Time', 't_bozucu', 'Before', 'R_th', 'After', 'R_th_bozucu', 'SampleTime', '0');
    b('simulink/Math Operations/Product', 'Kayip_W', [410 110 440 190], 'Inputs', '*/');

    b('simulink/Math Operations/Sum', 'Sensor_Fark', [360 250 380 290], 'Inputs', '|+-', 'IconShape', 'round');
    b('simulink/Math Operations/Gain', 'Bolu_tau', [410 255 460 285], 'Gain', '1/tau_sensor');
    b('simulink/Continuous/Integrator', 'T_sensor', [500 255 530 285], 'InitialCondition', 'T_ortam');
    b('simulink/Sources/Random Number', 'Gurultu', [500 320 530 350], ...
        'Mean', '0', 'Variance', 'gurultu^2', 'Seed', '1', 'SampleTime', 'dt');
    b('simulink/Math Operations/Sum', 'Gurultu_Ekle', [580 270 600 310], 'Inputs', '|++', 'IconShape', 'round');

    b('simulink/Sinks/Out1', 'T_gercek',  [660 48 690 62]);
    b('simulink/Sinks/Out1', 'T_olculen', [660 283 690 297]);

    h = @(a, c) add_line(yol, a, c, 'autorouting', 'on');
    h('P_W/1', 'Isi_Dengesi/1');
    h('Isi_Dengesi/1', 'Bolu_C/1');
    h('Bolu_C/1', 'T_blok/1');
    h('T_blok/1', 'Fark/1');
    h('T_ortam/1', 'Fark/2');
    h('Fark/1', 'Kayip_W/1');
    h('R_th/1', 'Kayip_W/2');
    h('Kayip_W/1', 'Isi_Dengesi/2');
    h('T_blok/1', 'T_gercek/1');
    h('T_blok/1', 'Sensor_Fark/1');
    h('T_sensor/1', 'Sensor_Fark/2');
    h('Sensor_Fark/1', 'Bolu_tau/1');
    h('Bolu_tau/1', 'T_sensor/1');
    h('T_sensor/1', 'Gurultu_Ekle/1');
    h('Gurultu/1', 'Gurultu_Ekle/2');
    h('Gurultu_Ekle/1', 'T_olculen/1');
    try, Simulink.BlockDiagram.arrangeSystem(yol); catch, end
end
