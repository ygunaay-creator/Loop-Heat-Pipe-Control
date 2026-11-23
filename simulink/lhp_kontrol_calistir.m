%LHP_KONTROL_CALISTIR  lhp_kontrol.slx modelini çalıştırır, özet yazar, grafik çizer, CSV kaydeder.
%
%   Komut penceresine:   lhp_kontrol_calistir
%   Parametre değiştirmek için önce yazın, örn:  T_hedef = 8;  Kp = 15;
%   (Parametreleri varsayılana döndürmek için:  lhp_kontrol_parametreler)
%
%   Bu bir betiktir; komut penceresindeki değişkenleri kullanır.

mdl = 'lhp_kontrol';
if ~exist('T_soguk', 'var'), lhp_kontrol_parametreler; end   % eski sürüm parametreleri kalmışsa yenilerini yükle
if ~bdIsLoaded(mdl), load_system(mdl); end
try, set_param(mdl, 'PacingRate', num2str(hiz)); catch, end

fprintf('Simülasyon başladı: yüzey hedefi %.1f °C, soğuk taraf %.0f °C, bulut %.1f–%.1f dk, Kp = %g, Ki = %g, hız x%g\n', ...
    T_hedef, T_soguk, t_bulut_bas / 60, (t_bulut_bas + t_bulut_sure) / 60, Kp, Ki, hiz);
sonuc = sim(mdl);

k = sonuc.get('kayit');
t = k.time(:);
v = squeeze(k.signals.values);          % MATLAB sürümüne göre N×8 ya da 8×1×N gelebilir
if size(v, 1) ~= numel(t), v = v.'; end
if size(v, 2) ~= 8
    error('Beklenen 8 sinyal, gelen veri boyutu: %s. lhp_kontrol_modeli_olustur ile modeli yeniden kurun.', ...
        mat2str(size(k.signals.values)));
end
sonuc_tablo = array2table([t v], 'VariableNames', ...
    {'time_s', 'T_hedef', 'T_yuzey_olc', 'P_W', 'T_yuzey', 'T_ev', 'alarm', 'buz_uyari', 'bulut'});

% ----- Özet -----
T = sonuc_tablo.T_yuzey_olc;  b = sonuc_tablo.bulut > 0.5;
fprintf('\n----- Özet -----\n');
i = find(T >= T_hedef - 1, 1);
if ~isempty(i), fprintf('Yüzeyin hedefe (1 °C yakınına) ulaşma süresi : %.1f dk\n', t(i) / 60); end
if any(b)
    fprintf('Bulut sırasında en düşük yüzey sıcaklığı     : %.2f °C\n', min(T(b)));
    fprintf('Bulut sırasında 0 °C altında kalma süresi     : %.0f s\n', sum(sonuc_tablo.buz_uyari > 0.5) * dt);
    fprintf('Bulut sırasında ortalama / en yüksek güç      : %.1f W / %.1f W\n', ...
        mean(sonuc_tablo.P_W(b)), max(sonuc_tablo.P_W(b)));
end
fprintf('En yüksek evaporatör sıcaklığı               : %.1f °C\n', max(sonuc_tablo.T_ev));
son = t >= t(end) - 300;
fprintf('Son 5 dakika yüzey ortalama / sapma          : %.2f °C / ±%.2f °C\n', mean(T(son)), std(T(son)));
if any(sonuc_tablo.alarm > 0.5)
    fprintf('ALARM: %.0f. saniyede güvenlik devreye girdi, ısıtıcı kapatıldı.\n', ...
        t(find(sonuc_tablo.alarm > 0.5, 1)));
end

% ----- Grafik -----
dk = t / 60;  t1 = t_bulut_bas / 60;  t2 = (t_bulut_bas + t_bulut_sure) / 60;
golge = @(y) patch([t1 t2 t2 t1], [y(1) y(1) y(2) y(2)], [0.85 0.9 1], ...
                   'EdgeColor', 'none', 'FaceAlpha', 0.6, 'HandleVisibility', 'off');
figure('Name', 'LHP Simulink kontrolü – TUSAŞ senaryosu', 'Color', 'w');

subplot(3, 1, 1); hold on; grid on; golge([-15 20]);
plot(dk, sonuc_tablo.T_yuzey_olc, 'Color', [0 0.45 0.74]);
plot(dk, sonuc_tablo.T_yuzey, ':', 'Color', [0.3 0.3 0.3]);
yline(T_hedef, '--', 'Hedef', 'Color', [0.85 0.33 0.10], 'HandleVisibility', 'off');
yline(T_buz, '-', '0 °C', 'Color', [0 0.6 0.9], 'HandleVisibility', 'off');
ylabel('Yüzey (°C)'); ylim([-15 20]); legend('Ölçülen', 'Gerçek', 'Location', 'southeast');
title('Test yüzeyi sıcaklığı (gölgeli bölge: 13,4 dk bulut)');

subplot(3, 1, 2); hold on; grid on; golge([0 T_limit + 10]);
plot(dk, sonuc_tablo.T_ev, 'Color', [0.47 0.67 0.19]);
yline(T_limit, ':', 'Güvenlik sınırı', 'Color', [0.6 0 0]);
ylabel('Evaporatör (°C)'); ylim([0 T_limit + 10]);

subplot(3, 1, 3); hold on; grid on; golge([0 P_max * 1.1]);
plot(dk, sonuc_tablo.P_W, 'Color', [0.85 0.33 0.10]);
ylabel('Isıtıcı gücü (W)'); xlabel('Zaman (dk)'); ylim([0 P_max * 1.1]);

% ----- Kayıt -----
dosya = "simulink_kontrol_" + string(datetime('now', 'Format', 'yyyyMMdd_HHmmss')) + ".csv";
writetable(sonuc_tablo, dosya);
fprintf('Kayıt: %s\n', fullfile(pwd, dosya));
