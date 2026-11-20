%LHP_KONTROL_CALISTIR  lhp_kontrol.slx modelini çalıştırır, özet yazar, grafik çizer, CSV kaydeder.
%
%   Komut penceresine:   lhp_kontrol_calistir
%   Parametre değiştirmek için önce yazın, örn:  T_hedef = 60;  Kp = 5;
%   (Parametreleri varsayılana döndürmek için:  lhp_kontrol_parametreler)
%
%   Bu bir betiktir; komut penceresindeki değişkenleri kullanır.

mdl = 'lhp_kontrol';
if ~exist('T_hedef', 'var'), lhp_kontrol_parametreler; end
if ~bdIsLoaded(mdl), load_system(mdl); end
try, set_param(mdl, 'PacingRate', num2str(hiz)); catch, end

fprintf('Simülasyon başladı: hedef %.1f °C, Kp = %g, Ki = %g, hız x%g\n', T_hedef, Kp, Ki, hiz);
sonuc = sim(mdl);

k  = sonuc.get('kayit');
t  = k.time;
v  = k.signals.values;
% MATLAB sürümüne göre veri N×5 ya da 5×1×N gelebilir; her durumda N×5'e çevir
v  = squeeze(v);
if size(v, 1) ~= numel(t), v = v.'; end
if size(v, 2) ~= 5
    error('Beklenen 5 sinyal, gelen veri boyutu: %s', mat2str(size(k.signals.values)));
end
sonuc_tablo = table(t, v(:,1), v(:,2), v(:,3), v(:,4), v(:,5), 'VariableNames', ...
    {'time_s', 'T_hedef', 'T_olculen', 'P_W', 'T_gercek', 'alarm'});

% ----- Özet -----
T = sonuc_tablo.T_olculen;
fprintf('\n----- Özet -----\n');
i = find(T >= T_hedef - 1, 1);
if ~isempty(i), fprintf('Hedefin 1 °C yakınına ulaşma süresi : %.1f dk\n', t(i) / 60); end
fprintf('En yüksek sıcaklık                 : %.2f °C\n', max(T));
son = t >= t(end) - 300;
fprintf('Son 5 dakika ortalama / sapma      : %.2f °C / ±%.2f °C\n', mean(T(son)), std(T(son)));
fprintf('Son 5 dakika ortalama güç          : %.1f W\n', mean(sonuc_tablo.P_W(son)));
if any(sonuc_tablo.alarm)
    fprintf('ALARM: %.0f. saniyede güvenlik devreye girdi, ısıtıcı kapatıldı.\n', ...
        t(find(sonuc_tablo.alarm, 1)));
end

% ----- Grafik -----
figure('Name', 'LHP Simulink kontrolü', 'Color', 'w');
subplot(2, 1, 1); hold on; grid on;
plot(t / 60, sonuc_tablo.T_olculen, 'Color', [0 0.45 0.74]);
plot(t / 60, sonuc_tablo.T_gercek, 'Color', [0.5 0.5 0.5], 'LineStyle', ':');
yline(T_hedef, '--', 'Hedef', 'Color', [0.85 0.33 0.10]);
yline(T_limit, ':', 'Güvenlik sınırı', 'Color', [0.6 0 0]);
xline(t_bozucu / 60, ':', 'Soğutma arttı');
ylabel('Sıcaklık (°C)'); legend('Ölçülen', 'Gerçek', 'Location', 'southeast');
title('Simulink PI kontrolü (sanal düzenek)');
subplot(2, 1, 2); grid on;
plot(t / 60, sonuc_tablo.P_W, 'Color', [0.85 0.33 0.10]);
ylabel('Isıtıcı gücü (W)'); xlabel('Zaman (dk)'); ylim([0 P_max * 1.1]);

% ----- Kayıt -----
dosya = "simulink_kontrol_" + string(datetime('now', 'Format', 'yyyyMMdd_HHmmss')) + ".csv";
writetable(sonuc_tablo, dosya);
fprintf('Kayıt: %s\n', fullfile(pwd, dosya));
