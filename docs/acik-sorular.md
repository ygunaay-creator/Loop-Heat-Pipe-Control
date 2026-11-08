# Açık Sorular

Cevaplandıkça ilgili belgeleri güncelleyin ve soruyu "Cevaplananlar" bölümüne taşıyın.

## Veri toplama (öncelikli)
- [ ] **Yeni veri toplama cihazının tam adı ve modeli nedir?** ("Lab…" ile başlıyor: LabJack mı, ADInstruments PowerLab/LabChart mı?)
- [ ] Cihazda 23 termokupl için yeterli kanal ve dahili soğuk uç kompanzasyonu var mı? Yoksa ek modül gerekiyor mu?
- [ ] 4–20 mA akım girişi var mı? Yoksa basınç sensörleri için şönt direnç (250 Ω) kullanılacak.
- [ ] MATLAB'dan nasıl okunuyor? (Üreticinin MATLAB kütüphanesi, toolbox, dosya aktarımı)
- [ ] Örnekleme hızı ve doğruluğu?

## Donanım
- [ ] Basınç transmitterlerinin aralığı nedir (1 / 2 / 4 bar)? Akışkana göre yeterli mi?
- [ ] Projedeki asıl LHP ısıtıcısı mevcut kartuş ısıtıcı mı (5,33 Ω)? Gereken güç 48 W'ı aşarsa N5765A mı kullanılacak?
- [ ] Kaç fan olacak?
- [ ] **Huber CC-415 test yüzeyini soğutmak için mi kullanılacak?** (Bu bir varsayım.) "Exclusive" lisansı var mı? Uzaktan kontrol kılavuzu?
- [ ] Soğutucu debisi için debimetre temin edilecek mi?
- [ ] N5765A'nın AC bağlantısını kim yapacak / kontrol edecek?

## LHP
- [ ] Çalışma akışkanı ne olacak (etanol / amonyak / başka)?
- [ ] LHP hazır mı alınacak, üretilip doldurulacak mı?
- [ ] LHP tek CC'li mi, çift CC'li mi? (`T_CC1`/`T_CC2`)
- [ ] LHP platforma hangi yönde monte edilecek?

## Stewart Platformu
- [ ] Simulink modeli hangi ortamda ve hangi bilgisayarda çalışıyor?
- [ ] Hareket sınırları, maksimum hız/ivme, taşıma kapasitesi, Euler açı sırası?
- [ ] Modele UDP blokları eklenebilir mi? Kim onaylayacak?

## Deney
- [ ] Buz önleme için hedef test yüzeyi sıcaklığı?
- [ ] Kararlı hal kriteri ve sonlandırma sıcaklığı?
- [ ] Sensörlerin düzenek üzerindeki kesin konumları?
- [ ] Gerçek düzenek ne zaman hazır olacak?

## Cevaplananlar
- **Yazılım:** Kontrol ve kayıt **MATLAB** ile yapılacak (LabVIEW bırakıldı). Instrument Control Toolbox kuruldu.
- **Veri toplama cihazı değişti.** Keysight DAQ973A artık ana cihaz değil.
- **Termokupllar:** 23 × **T tipi** (9 evaporatör + 9 kondenser + 5 dış).
- **GPP-3323** MATLAB'dan kontrol ediliyor (USB, GW Instek sürücüsü, 115200 baud).
- **EDU36311A** MATLAB'dan kontrol ediliyor (USB, `visadev`).
- **Mevcut kartuş ısıtıcının direnci ≈ 5,33 Ω.** GPP CH1 ile en fazla ≈ 48 W.
- **Fan:** 12 V DC, EDU36311A CH2'den çalışıyor.
- LHP düzeneği İTÜ'de kurulacak, dinamik testler Türk-Alman Üniversitesi'ndeki Stewart Platformu'nda yapılacak.
- Basınç sensörleri: DMS20S, mutlak, 4–20 mA, 2 telli.
