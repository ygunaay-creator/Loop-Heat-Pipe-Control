# Yol Haritası (kontrol ve veri toplama)

Gerçek LHP düzeneği kurulmadan önce kendi laboratuvarımızda ekipmanlarla çalışıp altyapıyı hazırlıyoruz. Düzenek hazır olduğunda yazılımın gerçek sisteme doğrudan bağlanması hedefleniyor. Hocanın iş adımlarıyla ilişkisi: [gorevler.md](gorevler.md)

## Aşama 0 – Hazırlık
- [x] Ekipmanların belirlenmesi ([ekipman.md](ekipman.md))
- [ ] LabVIEW, NI-VISA, Keysight IO Libraries Suite ve Origin kurulumu
- [ ] Tüm cihazları USB ile bağlayıp VISA'da görmek (`*IDN?` sorgusu)
- [ ] BenchVue DAQ ile DAQ973A'yı ilk kez denemek
- [ ] Termokupl tipini ve basınç sensörü aralığını netleştirmek

## Aşama 1 – Tek cihaz, tek kanal
- [ ] DAQ973A'dan tek termokuplu LabVIEW'da okumak (SCPI)
- [ ] GPP-3323'e gerilim ayarlayıp V/I geri okumak
- [ ] EDU36311A'ya gerilim ayarlamak
- [ ] Huber CC-415 ile haberleşmeyi kurmak (komut seti kılavuzdan)

## Aşama 2 – Çok kanal ve kayıt
- [ ] 20 termokupl kanalını tarama listesiyle okumak
- [ ] Basınç transmitterlerini 24 V döngüyle 121–122'den okumak ve bar'a ölçeklemek
- [ ] Tüm cihazları tek zaman ekseninde CSV'ye kaydetmek ([veri-formati.md](veri-formati.md))

## Aşama 3 – Doğrulama ve kalibrasyon
- [ ] Termokuplları referans termometre / Huber banyosu ile birkaç sıcaklıkta karşılaştırmak
- [ ] Basit ısıtma deneyi (ısıtıcı + bir metal blok) ve verinin Origin'de işlenmesi

## Aşama 4 – Kontrol ve güvenlik
- [ ] Isıtıcı sabit güç modu (V·I geri beslemesiyle)
- [ ] Sıcaklık hedefli PID modu
- [ ] Fan kontrolü
- [ ] Soğutucu hedef sıcaklık kontrolü
- [ ] Limitler, alarmlar, haberleşme kopmasında ısıtıcıyı kapatma
- [ ] Otomatik deney senaryoları (güç basamakları)

## Aşama 5 – Stewart Platformu entegrasyonu
- [ ] Simulink modelini ve çalıştığı ortamı öğrenmek
- [ ] LabVIEW ↔ Simulink UDP haberleşmesini platform olmadan test etmek
- [ ] Hareket profillerini LabVIEW'dan göndermek
- [ ] Platform durumunu sensör verileriyle birlikte kaydetmek

## Aşama 6 – Gerçek sisteme entegrasyon
- [ ] İTÜ'deki LHP düzeneğine bağlanmak, ön testler (adım 6)
- [ ] Sabit konum ve parametrik deneyler (adım 7–8)
- [ ] Türk-Alman Üniversitesi'nde dinamik testler (adım 9)
- [ ] Origin'de analiz, belirsizlik ve raporlama (adım 10)
