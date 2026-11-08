function edu = edu_baglan(adres)
%EDU_BAGLAN  Keysight EDU36311A'ya USB (VISA) üzerinden bağlanır.
%
%   edu = edu_baglan()          laboratuvardaki cihazın adresini kullanır
%   edu = edu_baglan(adres)     başka bir VISA adresi
%
%   Gerekenler: Instrument Control Toolbox, NI-VISA (veya Keysight IO Libraries).
%   Kablo cihazın ARKA panelindeki USB-B girişine takılmalı.
%
%   Aynı cihaza açık kalmış eski bir bağlantı varsa önce onu kapatır
%   ("Creating a second device ... is not supported" hatasını önler).

    if nargin < 1
        adres = "USB0::0x2A8D::0x8F01::CN64470294::0::INSTR";
    end

    try
        eski = visadevfind("ResourceName", adres);
        if ~isempty(eski)
            delete(eski);
        end
    catch
    end

    edu = visadev(adres);
    edu.Timeout = 3;
    writeline(edu, "*IDN?");
    idn = readline(edu);
    fprintf("Bağlandı: %s\n", strtrim(idn));
end
