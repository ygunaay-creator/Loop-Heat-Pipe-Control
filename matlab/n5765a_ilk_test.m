%N5765A_ILK_TEST  Keysight N5765A (30 V / 50 A / 1500 W) için ilk bağlantı testi.
%
%   HENÜZ LABORATUVARDA TEST EDİLMEDİ. Komutlar Keysight'ın standart SCPI yapısına göre yazıldı.
%
%   Başlamadan önce:
%     - AC bağlantısı (L, N, toprak) yetkili kişi tarafından yapılmış/kontrol edilmiş olmalı
%     - Arka paneldeki sense konnektörü (local sense köprüleri) takılı olmalı
%     - Çıkış baralarına HİÇBİR ŞEY BAĞLI OLMAMALI
%     - USB kablosu takılı olmalı
%
%   Komut penceresinde:  n5765a_ilk_test

liste = visadevlist;
disp(liste)
satir = find(contains(string(liste.Model), "N576"), 1);
if isempty(satir)
    error("N5765A listede yok. Kablo, cihazın açık olması ve Instrument Control Toolbox kontrol edilmeli.");
end
adres = liste.ResourceName(satir);

n57 = visadev(adres);
n57.Timeout = 3;
writeline(n57, "*IDN?");   disp(readline(n57))

writeline(n57, "OUTP OFF");
writeline(n57, "VOLT:PROT:LEV 10");   % aşırı gerilim koruması 10 V
writeline(n57, "CURR 1");             % akım sınırı 1 A
writeline(n57, "VOLT 5");             % 5 V
writeline(n57, "OUTP ON");
pause(1)
writeline(n57, "MEAS:VOLT?");  fprintf("Gerilim: %s\n", readline(n57));
writeline(n57, "MEAS:CURR?");  fprintf("Akım   : %s\n", readline(n57));
writeline(n57, "OUTP OFF");
writeline(n57, "SYST:ERR?");   fprintf("Hata durumu: %s\n", readline(n57));

disp("Test bitti, çıkış kapalı. Beklenen: ≈5 V, ≈0 A, '+0,""No error""'.")
