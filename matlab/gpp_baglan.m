function gpp = gpp_baglan(port)
%GPP_BAGLAN  GW Instek GPP-3323'e USB (sanal COM) üzerinden bağlanır.
%
%   gpp = gpp_baglan("COM3")   belirtilen porta bağlanır
%   gpp = gpp_baglan()         boştaki portları dener, GPP'yi kendisi bulur
%
%   Gerekenler:
%     - GW Instek USB sürücüsü ("GPP Serial")
%     - Cihazda System -> F1 (Interface) -> F2 (USB), baud 115200
%
%   Aynı porta açık kalmış eski bir bağlantı varsa önce onu kapatır.

    baud = 115200;

    if nargin < 1 || strlength(string(port)) == 0
        adaylar = serialportlist("available");
        if isempty(adaylar)
            error("Boşta seri port yok. Kablo takılı mı, cihaz açık mı, sürücü kurulu mu?");
        end
    else
        adaylar = string(port);
        eskiyiKapat(adaylar);
    end

    for p = adaylar
        try
            s = serialport(p, baud, "Timeout", 2);
            configureTerminator(s, "LF");
            flush(s);
            writeline(s, "*IDN?");
            idn = readline(s);
            if contains(upper(idn), "GPP")
                fprintf("Bağlandı: %s  (%s)\n", strtrim(idn), p);
                gpp = s;
                return
            end
            clear s
        catch
            % bu port GPP değil ya da açılamadı, sıradakini dene
        end
    end

    error(['GPP-3323 bulunamadı. Kontrol edin: Interface = USB, baud = 115200, ' ...
           'port başka bir programda (LabVIEW, GW yazılımı, başka MATLAB) açık değil.']);
end

function eskiyiKapat(port)
    try
        eski = serialportfind("Port", port);
        if ~isempty(eski)
            delete(eski);
        end
    catch
    end
end
