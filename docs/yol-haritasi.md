# Yol Haritası

Gerçek LHP düzeneği kurulmadan önce kendi laboratuvarımızda sensörlerle çalışıp altyapıyı hazırlıyoruz. Düzenek hazır olduğunda sistemin gerçek sisteme doğrudan bağlanabilmesi hedefleniyor.

## Aşama 0 – Hazırlık
- [ ] Veri toplama cihazının marka/modelini öğrenmek
- [ ] LabVIEW sürücüsünü kurmak, cihazı bilgisayarda görmek
- [ ] Sensör tiplerini (termokupl tipi, basınç sensörü modeli) netleştirmek
- [ ] LabVIEW ve Origin lisanslarını ayarlamak

## Aşama 1 – Tek kanal
- [ ] Tek sıcaklık sensörünü okuyup canlı grafikte göstermek

## Aşama 2 – Çok kanal ve kayıt
- [ ] 12 sıcaklık kanalını eş zamanlı okumak
- [ ] Basınç sensörlerini okumak
- [ ] Zaman damgalı CSV kaydı ([veri-formati.md](veri-formati.md))

## Aşama 3 – Doğrulama
- [ ] Sensörleri referans termometreyle karşılaştırmak (kalibrasyon)
- [ ] Basit bir ısıtma deneyi yapmak ve veriyi Origin'de işlemek

## Aşama 4 – Kontrol
- [ ] Isıtıcı kontrolü (sabit güç, sıcaklık hedefli / PID)
- [ ] Fan kontrolü
- [ ] Güvenlik limitleri ve alarmlar

## Aşama 5 – Stewart Platformu entegrasyonu
- [ ] Simulink modelini ve çalıştığı ortamı öğrenmek
- [ ] LabVIEW ↔ Simulink UDP haberleşmesini platform olmadan (simülasyonla) test etmek
- [ ] Hareket profillerini LabVIEW'dan göndermek
- [ ] Platform durumunu sensör verileriyle birlikte kaydetmek

## Aşama 6 – Gerçek sisteme entegrasyon
- [ ] İTÜ'deki LHP düzeneğine bağlanmak, statik testler
- [ ] Türk-Alman Üniversitesi'nde Stewart Platformu üzerinde dinamik testler
- [ ] Sonuçların Origin'de analizi ve raporlanması
