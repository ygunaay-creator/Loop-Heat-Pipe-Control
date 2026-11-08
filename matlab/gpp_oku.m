function [V, I, P] = gpp_oku(gpp, kanal)
%GPP_OKU  GPP-3323'ün bir kanalının gerçek gerilim ve akımını okur.
%
%   [V, I, P] = gpp_oku(gpp, 1)
%
%   Cihaz cevabı "5.001V" / "0.939A" biçimindedir; birimler atılıp sayıya çevrilir.

    if nargin < 2, kanal = 1; end
    writeline(gpp, sprintf("VOUT%d?", kanal));  V = sayi(readline(gpp));
    writeline(gpp, sprintf("IOUT%d?", kanal));  I = sayi(readline(gpp));
    P = V * I;
end

function x = sayi(metin)
    x = str2double(regexprep(string(metin), "[^0-9eE\.\+\-]", ""));
end
