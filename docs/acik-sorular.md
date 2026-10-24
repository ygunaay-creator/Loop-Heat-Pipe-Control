# Açık Sorular

Cevaplandıkça ilgili belgeleri güncelleyin ve soruyu "Cevaplananlar" bölümüne taşıyın.

## Donanım
- [ ] Veri toplama cihazının marka ve modeli nedir? LabVIEW sürücüsü var mı?
- [ ] 20 girişli kart hangi sinyal tiplerini destekliyor (termokupl, gerilim, akım)?
- [ ] Cihazda ısıtıcı ve fanları sürmek için **çıkış** kanalı (röle, analog çıkış, PWM) var mı? Yoksa hangi ek modül kullanılacak?
- [ ] Sıcaklık sensörlerinin tipi nedir (K/T/J termokupl, RTD)?
- [ ] Dijital basınç sensörlerinin modeli ve haberleşme tipi nedir (4–20 mA, RS-485/Modbus, USB)?
- [ ] Isıtıcının gücü ve nasıl beslendiği (programlanabilir güç kaynağı mı)?
- [ ] Kaç fan olacak ve nasıl sürülecek?

## Yazılım
- [ ] Kullanılacak LabVIEW sürümü?
- [ ] Origin sürümü ve lisansı?
- [ ] İstenen örnekleme hızı?

## Stewart Platformu
- [ ] Simulink modeli hangi ortamda çalışıyor (Desktop Real-Time, Speedgoat vb.)?
- [ ] Platformun serbestlik derecesi, hareket sınırları, maksimum hız/ivme?
- [ ] Simulink modeline UDP blokları eklenebilir mi? Kim onaylayacak?
- [ ] LabVIEW ve Simulink aynı bilgisayarda mı çalışacak?

## Deney
- [ ] Hangi ısı girdileri ve hareket profilleri test edilecek?
- [ ] Sensörlerin düzenek üzerindeki kesin konumları?
- [ ] Gerçek düzenek ne zaman hazır olacak?

## Cevaplananlar
- LHP düzeneği İTÜ'de kurulacak; dinamik testler Türk-Alman Üniversitesi'ndeki Stewart Platformu'nda yapılacak.
- Beklenen sensörler: ~12 sıcaklık, 2 dijital basınç. Veri toplama cihazında 20 giriş kanalı var.
- Ana yazılım LabVIEW; analiz Origin; platform Simulink ile çalışıyor.
