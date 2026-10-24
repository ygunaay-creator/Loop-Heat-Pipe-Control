# LabVIEW – Simulink Haberleşmesi

> Taslak – Türk-Alman Üniversitesi'ndeki platform sorumlusuyla birlikte kesinleştirilecek.

## Yaklaşım

Stewart Platformu Simulink ile kontrol edilmektedir. Platformun düşük seviyeli kontrolü Simulink'te kalır. LabVIEW ise ana kontrol arayüzü olarak platforma komut gönderir ve durum bilgisi alır.

Seçilen yöntem: **UDP**. Simulink modeline yalnızca UDP Send/Receive blokları eklenir, model yapısı değişmez. İki program aynı bilgisayarda ya da ağ üzerinden farklı bilgisayarlarda çalışabilir.

Değerlendirilen alternatifler:

| Yöntem | Artı | Eksi |
|---|---|---|
| **UDP** (seçilen) | Basit, hızlı, modele küçük müdahale | Paket kaybı olabilir; durum kontrolü gerekir |
| TCP/IP | Güvenilir iletim | Gecikme ve bağlantı yönetimi daha karmaşık |
| NI VeriStand / Model Interface Toolkit | Model LabVIEW içinde çalışır | Ek lisans, karmaşık kurulum |
| MATLAB Script / Engine | Kurulumu kolay | Yavaş, gerçek zamanlı kontrole uygun değil |

## Mesajlar (taslak)

Tüm sayılar **double (8 bayt), little-endian**. Açılar derece, konumlar mm cinsindendir.

### LabVIEW → Simulink (komut)

Port: `25000` (taslak)

| Sıra | Alan | Açıklama |
|---|---|---|
| 1 | `seq` | Paket sıra numarası |
| 2 | `cmd` | 0 = bekle, 1 = başlat, 2 = durdur, 3 = başlangıç konumuna dön |
| 3 | `x` | Hedef konum (mm) |
| 4 | `y` | |
| 5 | `z` | |
| 6 | `roll` | Hedef açı (°) |
| 7 | `pitch` | |
| 8 | `yaw` | |

### Simulink → LabVIEW (durum)

Port: `25001` (taslak)

| Sıra | Alan | Açıklama |
|---|---|---|
| 1 | `t_sim` | Simulink zamanı (s) |
| 2 | `seq_ack` | Son alınan komutun sıra numarası |
| 3 | `status` | 0 = hazır, 1 = hareket ediyor, 2 = durdu, 9 = hata |
| 4–9 | `x, y, z, roll, pitch, yaw` | Platformun gerçek konumu ve açıları |

## Hareket profilleri

Profiller LabVIEW tarafında üretilip anlık hedefler olarak gönderilir:

- Sabit eğim (ör. pitch = 10°)
- Sinüzoidal salınım (genlik, frekans)
- Adım (step) değişimi
- Dosyadan okunan profil (CSV)

## Güvenlik kuralları

- Simulink, belirli bir süre (ör. 0,5 s) komut alamazsa platformu **güvenli konuma** getirir. Bu Simulink tarafında uygulanmalıdır.
- Fiziksel acil durdurma butonu LabVIEW'dan bağımsız olmalıdır.
- LabVIEW, Simulink'e göndermeden önce hedef değerleri platformun hareket sınırlarına göre kırpar.

## Simulink tarafında öğrenilmesi gerekenler

- Model hangi ortamda çalışıyor? (Simulink Desktop Real-Time, Simulink Real-Time/Speedgoat, normal simülasyon)
- Kullanılabilir UDP blokları hangileri? (Instrument Control Toolbox, Desktop Real-Time, Real-Time kütüphanesi)
- Platformun hareket sınırları, maksimum hız ve ivmeleri
- Modelde hangi sinyallerin dışarıya açılabileceği
