%TUM_CIKISLARI_KAPAT  Çalışma alanındaki gpp, edu ve n57 bağlantılarının tüm çıkışlarını kapatır.
%
%   Acil durumda veya iş bitiminde komut penceresine yazın:
%       tum_cikislari_kapat
%
%   Bu bir betiktir (fonksiyon değil), bu yüzden komut penceresindeki değişkenleri görür.
%   Bağlantıları da kapatmak için ardından:  clear gpp edu n57

if exist("gpp", "var")
    try
        writeline(gpp, ":ALLOUTOFF");
        disp("GPP-3323: tüm çıkışlar kapatıldı.")
    catch
        warning("GPP-3323'e ulaşılamadı, ön panelden kapatın.")
    end
end

if exist("edu", "var")
    try
        writeline(edu, "OUTP OFF,(@1:3)");
        disp("EDU36311A: tüm çıkışlar kapatıldı.")
    catch
        warning("EDU36311A'ya ulaşılamadı, ön panelden kapatın.")
    end
end

if exist("n57", "var")
    try
        writeline(n57, "OUTP OFF");
        disp("N5765A: çıkış kapatıldı.")
    catch
        warning("N5765A'ya ulaşılamadı, ön panelden kapatın.")
    end
end
