# Sistem Mimarisi

> Taslak – donanım bilgileri netleştikçe güncellenecek.

## 1. Fiziksel sistem

LHP düzeneği iki ana bölümden oluşur:

- **Evaporatör tarafı:** Elektrikli ısıtıcıdan alınan ısıyla çalışma akışkanı buharlaşır. Bu ısı, uçakta oluşan atık ısıyı temsil eder.
- **Kondenser tarafı:** Buhar yoğuşur ve ısıyı soğuk test yüzeyine aktarır. Fanlar soğutma koşullarını ayarlamak için kullanılır.

Her iki tarafta da sıcaklık sensörleri (toplam ~12) ve birer dijital basınç sensörü (toplam 2) bulunması beklenmektedir.

Düzenek İTÜ'de kurulacak, dinamik testler için Türk-Alman Üniversitesi'ndeki Stewart Platformu üzerine taşınacaktır.

## 2. Katmanlar

| Katman | Bileşen | Görev |
|---|---|---|
| Sensör | Sıcaklık sensörleri, basınç sensörleri | Fiziksel büyüklükleri ölçmek |
| Donanım | Veri toplama cihazı (20 giriş kanallı kart) | Sinyalleri dijitale çevirmek; varsa çıkış kanallarıyla aktüatörleri sürmek |
| Aktüatör | Isıtıcı, fanlar, Stewart Platformu | Isı girdisini, soğutmayı ve hareketi sağlamak |
| Yazılım | LabVIEW | İzleme, kontrol, güvenlik, kayıt, platform komutları |
| Yazılım | Simulink | Stewart Platformu'nun düşük seviyeli kontrolü |
| Analiz | Origin | Grafikler, termal direnç vb. hesaplar |

## 3. LabVIEW uygulamasının modülleri

1. **Okuma (Acquisition):** Tüm sıcaklık kanallarını eş zamanlı okur; basınç sensörlerini bağlantı tipine göre okur (analog giriş ya da RS-485/Modbus/seri).
2. **İzleme (UI):** Canlı grafikler, anlık değerler, durum göstergeleri.
3. **Kontrol:**
   - Isıtıcı: sabit güç modu ve sıcaklık hedefli (açma-kapama / PID) mod.
   - Fanlar: kondenser sıcaklığına göre hız ayarı.
4. **Güvenlik:** Sıcaklık ve basınç limitleri aşıldığında ısıtıcıyı keser, alarm verir ve olayı kaydeder.
5. **Platform arayüzü:** Simulink'e UDP üzerinden hareket komutları gönderir, gerçek konum ve durum bilgisini alır.
6. **Kayıt:** Sensör verileri, aktüatör komutları ve platform durumu tek zaman ekseninde, zaman damgalı olarak kaydedilir.

Önerilen yapı: üretici–tüketici (producer–consumer) döngüleri. Okuma, kontrol, platform haberleşmesi ve kayıt ayrı döngülerde çalışır, böylece birindeki gecikme diğerlerini etkilemez.

## 4. Stewart Platformu entegrasyonu

- Simulink platformun kendi kontrolünü yapmaya devam eder.
- LabVIEW ana kontrol merkezidir: hareket profili (ör. sabit eğim, sinüs), başlat/durdur komutları gönderir.
- Haberleşme koptuğunda platformun güvenli konuma dönmesi **Simulink tarafında** sağlanmalıdır. Acil durdurma LabVIEW'a bağımlı olmamalıdır.

Ayrıntılar: [labview-simulink-haberlesme.md](labview-simulink-haberlesme.md)

## 5. Açık noktalar

Donanımla ilgili belirsizlikler [acik-sorular.md](acik-sorular.md) dosyasında takip edilir. En kritik olanları:

- Veri toplama cihazının marka/modeli ve LabVIEW sürücüsü
- Cihazda ısıtıcı ve fanları sürecek **çıkış** kanalı olup olmadığı
- Basınç sensörlerinin haberleşme tipi
