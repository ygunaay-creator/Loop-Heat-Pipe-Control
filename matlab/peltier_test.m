function peltier_test(edu, kanal, akim_A, sure_s)
%PELTIER_TEST  TEC1-12715 peltieri EDU36311A ile kısa süre çalıştırır, sonunda kapatır.
%
%   peltier_test(edu)              CH1, 3 A, 20 s
%   peltier_test(edu, 1, 5, 10)    CH1, 5 A, 10 s   (≈ 20–25 W, soğutucusuz en fazla 10 s)
%   peltier_test(edu, 2, 1, 30)    CH2, 1 A, 30 s   (≈ 1 W, yavaş ısınır)
%
%   Kanal sınırları: CH1 6 V / 5 A, CH2 ve CH3 30 V / 1 A.
%   Kutup önemli: kırmızı +, siyah −. Ters bağlanırsa sıcak/soğuk yüz yer değiştirir.
%   Soğutucu olmadan uzun süre ve yüksek akımda çalıştırmayın.

    if nargin < 2 || isempty(kanal),  kanal = 1;  end
    if nargin < 3 || isempty(akim_A), akim_A = 3; end
    if nargin < 4 || isempty(sure_s), sure_s = 20; end

    if kanal == 1
        akim_A = min(akim_A, 5);  Vset = 6;
    else
        akim_A = min(akim_A, 1);  Vset = 4;
    end

    temizlik = onCleanup(@() kapat(edu, kanal)); %#ok<NASGU>

    writeline(edu, sprintf("APPL CH%d,%.2f,%.3f", kanal, Vset, akim_A));
    writeline(edu, sprintf("OUTP ON,(@%d)", kanal));

    for t = 1:sure_s
        writeline(edu, sprintf("MEAS:VOLT? CH%d", kanal)); v = str2double(readline(edu));
        writeline(edu, sprintf("MEAS:CURR? CH%d", kanal)); i = str2double(readline(edu));
        fprintf("%3d s  V=%.2f V  I=%.2f A  P=%.1f W\n", t, v, i, v * i);
        if t == 2 && i < 0.01
            warning("Akım sıfır: peltier bu kanala bağlı değil.");
        end
        pause(1)
    end
end

function kapat(edu, kanal)
    writeline(edu, sprintf("OUTP OFF,(@%d)", kanal));
    disp("Peltier kapatıldı.")
end
