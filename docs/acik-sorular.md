# Açık Sorular

Cevaplandıkça ilgili belgeleri güncelleyin ve soruyu "Cevaplananlar" bölümüne taşıyın.

## Donanım
- [ ] Termokupl tipi ne olacak (T tipi öneriliyor)? Kaç adet temin edilecek?
- [ ] Basınç transmitterlerinin aralığı nedir (1 / 2 / 4 bar mutlak)? Hangi bağlantı tipi (J3 kablo, J5 DIN43650…)?
- [ ] Isıtıcının tipi, direnci ve en yüksek gücü? GPP-3323 (32 V / 3 A kanal başına) yetiyor mu?
- [ ] Kaç fan olacak, gerilimleri nedir (12 V / 24 V)? EDU36311A CH2 (30 V / 1 A) yetiyor mu?
- [ ] Huber CC-415'te "Exclusive" E-grade lisansı var mı (harici Pt100 ile proses kontrolü)?
- [ ] Soğutucuda hangi sıvı kullanılacak? Test yüzeyi / soğuk plaka bağlantısı nasıl olacak?
- [ ] Soğutucu sıvının debisi ölçülecek mi (enerji dengesi için)?
- [ ] GPP-3323'te LAN opsiyonu var mı? (Yoksa USB/RS-232 kullanılacak.)
- [ ] DAQ973A'nın 200/300 yuvalarında başka modül var mı?

## Yazılım
- [ ] LabVIEW sürümü ve lisansı?
- [ ] Origin sürümü ve lisansı?
- [ ] Huber CC-415'in uzaktan kontrol komut seti (kılavuz gerekli)

## Stewart Platformu
- [ ] Simulink modeli hangi ortamda çalışıyor (Desktop Real-Time, Speedgoat vb.)?
- [ ] Platformun serbestlik derecesi, hareket sınırları, maksimum hız/ivme ve taşıma kapasitesi?
- [ ] Simulink modeline UDP blokları eklenebilir mi? Kim onaylayacak?
- [ ] LabVIEW ve Simulink aynı bilgisayarda mı çalışacak?
- [ ] Platforma kablo ve hortum nasıl taşınacak? Soğutucu ile platform arası mesafe?

## Deney
- [ ] Buz önleme için hedef test yüzeyi sıcaklığı?
- [ ] Hangi ısı girdileri ve hareket profilleri test edilecek?
- [ ] Sensörlerin düzenek üzerindeki kesin konumları?
- [ ] Gerçek düzenek ne zaman hazır olacak?

## Cevaplananlar
- LHP düzeneği İTÜ'de kurulacak. Dinamik testler Türk-Alman Üniversitesi'ndeki Stewart Platformu'nda yapılacak.
- Veri toplama cihazı: **Keysight DAQ973A + DAQM901A** (20 kanal + 2 akım kanalı).
- Isıtıcı beslemesi: **GW Instek GPP-3323**. Fan ve sensör beslemesi: **Keysight EDU36311A**.
- Soğutucu: **Huber CC-415**. Bilgisayar: **Dell Precision T3680**.
- Basınç sensörleri: **DMS20S**, mutlak, 4–20 mA, 2 telli.
- DAQM901A'nın çıkışı yok. Kontrol güç kaynakları ve soğutucu üzerinden yapılacak.
- Ana yazılım LabVIEW, analiz Origin. Platform Simulink ile çalışıyor.
