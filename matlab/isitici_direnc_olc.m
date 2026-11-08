function R = isitici_direnc_olc(gpp, kanal)
%ISITICI_DIRENC_OLC  Isıtıcının direncini düşük güçle, güvenli şekilde ölçer.
%
%   R = isitici_direnc_olc(gpp)      CH1 için
%   R = isitici_direnc_olc(gpp, 2)   CH2 için
%
%   2 V ve en fazla 1 A ile ölçer (en fazla 2 W). Ölçümden sonra çıkışı kapatır.
%   Laboratuvar ölçümü (6 Kasım 2026): mevcut kartuş ısıtıcı ≈ 5,33 Ω.

    if nargin < 2, kanal = 1; end
    temizlik = onCleanup(@() writeline(gpp, sprintf(":OUTPut%d:STATe OFF", kanal))); %#ok<NASGU>

    writeline(gpp, sprintf("ISET%d:1", kanal));
    writeline(gpp, sprintf("VSET%d:2", kanal));
    writeline(gpp, sprintf(":OUTPut%d:STATe ON", kanal));
    pause(1.5)
    [V, I] = gpp_oku(gpp, kanal);

    if I >= 0.98
        warning("Akım sınırına (1 A) ulaşıldı: direnç 2 Ω'dan küçük olabilir, ölçüm güvenilir değil.");
    elseif I < 0.005
        warning("Akım neredeyse sıfır: ısıtıcı bağlı değil ya da bağlantı kopuk.");
    end

    R = V / I;
    fprintf("V = %.3f V   I = %.4f A   R = %.3f ohm\n", V, I, R);
    fprintf("Bu dirençle CH1'in 3 A sınırında en yüksek güç ≈ %.0f W\n", 9 * R);
end
