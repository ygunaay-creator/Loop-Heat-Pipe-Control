function fan_ayarla(edu, V, kanal)
%FAN_AYARLA  EDU36311A üzerinden fan hızını gerilimle ayarlar.
%
%   fan_ayarla(edu, 12)     tam hız (12 V)
%   fan_ayarla(edu, 8)      orta hız
%   fan_ayarla(edu, 0)      fanı kapatır
%   fan_ayarla(edu, V, 3)   CH3'teki fan için
%
%   12 V DC fan için: 6–7 V altında genelde durur, 12 V'u aşmayın.
%   Akım sınırı 0,6 A. OCP AÇILMAZ: Keysight'ta OCP, kalkış akımında kanalı kapatır.

    if nargin < 3, kanal = 2; end
    if kanal == 1
        error("CH1 en fazla 6 V verir; 12 V fan için CH2 veya CH3 kullanın.");
    end

    if V <= 0
        writeline(edu, sprintf("OUTP OFF,(@%d)", kanal));
        disp("Fan kapatıldı.")
        return
    end

    V = min(V, 12);
    if V < 6
        warning("%.1f V çoğu 12 V fan için düşük; fan dönmeyebilir.", V);
    end

    writeline(edu, sprintf("VOLT:PROT 13,(@%d)", kanal));
    writeline(edu, sprintf("APPL CH%d,%.2f,0.6", kanal, V));
    writeline(edu, sprintf("OUTP ON,(@%d)", kanal));
    pause(2)

    writeline(edu, sprintf("MEAS:VOLT? CH%d", kanal));  v = str2double(readline(edu));
    writeline(edu, sprintf("MEAS:CURR? CH%d", kanal));  i = str2double(readline(edu));
    fprintf("Fan (CH%d): V = %.2f V   I = %.3f A\n", kanal, v, i);

    if i < 0.01
        warning("Akım neredeyse sıfır: fan bağlı değil ya da klemens teması yok.");
    elseif i > 0.55
        warning("Akım sınıra yakın: fan sıkışmış ya da kısa devre olabilir. Kontrol edin.");
    end
end
