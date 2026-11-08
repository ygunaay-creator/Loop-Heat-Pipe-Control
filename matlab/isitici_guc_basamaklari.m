function dosya = isitici_guc_basamaklari(gpp, gucler, sure_s, R0, kanal)
%ISITICI_GUC_BASAMAKLARI  Isıtıcıyı güç basamaklarıyla çalıştırır, kaydeder, sonunda kapatır.
%
%   isitici_guc_basamaklari(gpp, [10 20 30], 180)
%   isitici_guc_basamaklari(gpp, gucler, sure_s, R0, kanal)
%
%   gucler : hedef güçler (W), sırayla uygulanır
%   sure_s : her basamağın süresi (s)
%   R0     : ısıtıcı direnci (ohm), varsayılan 5.33 (ilk tahmin için)
%   kanal  : GPP-3323 kanalı, varsayılan 1
%
%   Sabit güç: Her saniye ölçülen V/I'dan direnç yeniden hesaplanır ve gerilim
%   P = V^2/R olacak şekilde düzeltilir (ısındıkça direnç değişse de güç sabit kalır).
%
%   Güvenlik:
%     - Akım sınırı 3 A (CH1/CH2'nin üst sınırı), OVP 30 V, OCP 3,3 A
%     - Ctrl+C, hata veya bitişte çıkış onCleanup ile KAPATILIR
%     - Sıcaklık henüz okunmuyor: başında durun, yanık kokusu/dumanda Ctrl+C
%
%   Kayıt: data/raw/YYYYMMDD_HHMMSS_guc-basamaklari.csv

    if nargin < 4 || isempty(R0),    R0 = 5.33; end
    if nargin < 5 || isempty(kanal), kanal = 1;  end
    Imax = 3;  Vmax = 32;

    % --- Korumalar
    writeline(gpp, sprintf(":OUTPut%d:OVP 30", kanal));
    writeline(gpp, sprintf(":OUTPut%d:OVP:STATe ON", kanal));
    writeline(gpp, sprintf(":OUTPut%d:OCP 3.3", kanal));
    writeline(gpp, sprintf(":OUTPut%d:OCP:STATe ON", kanal));
    writeline(gpp, sprintf("ISET%d:%.3f", kanal, Imax));

    % --- Kayıt dosyası
    kok = fileparts(fileparts(mfilename("fullpath")));
    klasor = fullfile(kok, "data", "raw");
    if ~isfolder(klasor), mkdir(klasor); end
    dosya = fullfile(klasor, string(datetime("now", "Format", "yyyyMMdd_HHmmss")) + "_guc-basamaklari.csv");
    fid = fopen(dosya, "w");
    fprintf(fid, "# deney: guc-basamaklari\n# tarih: %s\n# isitici_direnci_ohm: %.3f\n# gucler_W: %s\n# basamak_suresi_s: %d\n", ...
        string(datetime("now")), R0, mat2str(gucler), sure_s);
    fprintf(fid, "time_s,timestamp,HTR_SET,HTR_V,HTR_I,HTR_P\n");

    temizlik = onCleanup(@() kapat(gpp, kanal, fid, dosya)); %#ok<NASGU>

    % --- Çalıştır
    R = R0;
    writeline(gpp, sprintf("VSET%d:%.3f", kanal, min(sqrt(gucler(1) * R), Vmax)));
    writeline(gpp, sprintf(":OUTPut%d:STATe ON", kanal));
    t0 = tic;

    for P_hedef = gucler
        if sqrt(P_hedef * R) / R > Imax
            warning("%g W bu dirençte 3 A sınırını aşıyor; en fazla ≈ %.0f W verilebilir.", P_hedef, Imax^2 * R);
        end
        for k = 1:sure_s
            [V, I, P] = gpp_oku(gpp, kanal);
            if I > 0.05
                R = V / I;                                    % güncel direnç
            end
            Vset = min(sqrt(P_hedef * R), Vmax);
            writeline(gpp, sprintf("VSET%d:%.3f", kanal, Vset));

            t = toc(t0);
            zaman = string(datetime("now", "Format", "yyyy-MM-dd'T'HH:mm:ss"));
            fprintf(fid, "%.1f,%s,%.2f,%.4f,%.4f,%.3f\n", t, zaman, P_hedef, V, I, P);
            if mod(k, 10) == 0
                fprintf("Hedef %5.1f W | %4d s | V=%6.2f V  I=%5.2f A  P=%6.2f W  R=%.2f ohm\n", ...
                    P_hedef, k, V, I, P, R);
            end
            pause(1)
        end
    end
end

function kapat(gpp, kanal, fid, dosya)
    try
        writeline(gpp, sprintf(":OUTPut%d:STATe OFF", kanal));
        disp("Isıtıcı kapatıldı.")
    catch
        warning("Isıtıcı KAPATILAMADI! Cihazın ön panelinden kapatın.");
    end
    try, fclose(fid); catch, end
    fprintf("Kayıt: %s\n", dosya);
end
