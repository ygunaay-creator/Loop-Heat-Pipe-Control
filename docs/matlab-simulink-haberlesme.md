# MATLAB – Simulink Haberleşmesi

> Taslak. Türk-Alman Üniversitesi'ndeki platform sorumlusuyla birlikte kesinleştirilecek. Bu belge, önceki "LabVIEW–Simulink haberleşmesi" belgesinin yerini alır.

## Yaklaşım

Stewart Platformu Simulink ile kontrol edilmektedir. Platformun düşük seviyeli kontrolü Simulink'te kalır. MATLAB ana kontrol programı olarak platforma hedef açıları gönderir ve platformun gerçek konumunu alır. Böylece platform hareketi, sıcaklık verisiyle **aynı zaman ekseninde** kaydedilir.

LabVIEW yerine MATLAB kullanılması bu kısmı kolaylaştırıyor, çünkü MATLAB ve Simulink aynı ortamın parçası.

## Seçenekler

| Yöntem | Ne zaman | Gerekenler |
|---|---|---|
| **UDP** (önerilen) | Simulink modeli **ayrı bir bilgisayarda** veya gerçek zamanlı donanımda (Speedgoat) çalışıyorsa | MATLAB: `udpport` (Instrument Control Toolbox, kurulu). Simulink: UDP Send/Receive veya Packet Input/Output blokları |
| Doğrudan parametre değiştirme | Model **aynı bilgisayarda**, Simulink Desktop Real-Time / External Mode ile çalışıyorsa | `set_param(model/blok, 'Value', ...)` ile ayarlanabilir parametreler. Gerçek konum, model çıktılarından okunur |

Platformu süren model büyük ihtimalle Türk-Alman Üniversitesi'nin kendi bilgisayarında çalıştığı için **UDP** varsayılan yöntemdir.

## Mesajlar (taslak)

Tüm sayılar **double (8 bayt), little-endian**. Açılar derece, konumlar mm.

### MATLAB → Simulink (komut), port `25000`

| Sıra | Alan | Açıklama |
|---|---|---|
| 1 | `seq` | Paket sıra numarası |
| 2 | `cmd` | 0 = bekle, 1 = başlat, 2 = durdur, 3 = başlangıç konumuna dön |
| 3–5 | `x, y, z` | Hedef konum (mm) |
| 6–8 | `roll, pitch, yaw` | Hedef açılar (°) |

### Simulink → MATLAB (durum), port `25001`

| Sıra | Alan | Açıklama |
|---|---|---|
| 1 | `t_sim` | Simulink zamanı (s) |
| 2 | `seq_ack` | Son alınan komutun sıra numarası |
| 3 | `status` | 0 = hazır, 1 = hareket ediyor, 2 = durdu, 9 = hata |
| 4–9 | `x, y, z, roll, pitch, yaw` | Gerçek konum ve açılar |

## MATLAB tarafı (örnek)

```matlab
u = udpport("datagram", "LocalPort", 25001, "ByteOrder", "little-endian");

% Komut gönder: başlat, pitch = 10°
seq = 1;
paket = [seq 1  0 0 0  0 10 0];
write(u, paket, "double", "192.168.1.20", 25000);   % Simulink bilgisayarının IP'si

% Durum oku
if u.NumDatagramsAvailable > 0
    d = read(u, 1, "double");
    durum = d.Data;          % [t_sim seq_ack status x y z roll pitch yaw]
end

clear u
```

Platform olmadan test: Aynı bilgisayarda UDP Receive → Gain (×2) → UDP Send içeren basit bir Simulink modeli kurun ve MATLAB'dan IP olarak `127.0.0.1` kullanın.

## Hareket profilleri

Profiller MATLAB'da üretilip anlık hedefler olarak gönderilir:

- Sabit eğim (ör. pitch = 10°)
- Sinüzoidal salınım (genlik, frekans)
- Adım değişimi
- Dosyadan okunan profil (CSV)

Önerilen ilk test matrisi ve montaj yönü için: [literatur.md](literatur.md), Bölüm 5.6.

## Güvenlik kuralları

- Simulink belirli bir süre (ör. 0,5 s) komut alamazsa platformu güvenli konuma getirir. **Bu Simulink tarafında uygulanmalı.**
- Fiziksel acil durdurma butonu MATLAB'dan bağımsız olmalı.
- MATLAB, hedef değerleri göndermeden önce platformun hareket sınırlarına göre kırpar. Simulink'te de bir Saturation bloğu olmalı.

## Öğrenilmesi gerekenler

- Model hangi ortamda çalışıyor? (Simulink Desktop Real-Time, Simulink Real-Time/Speedgoat, normal simülasyon)
- Model aynı bilgisayarda mı, ayrı bilgisayarda mı?
- Platformun serbestlik derecesi, hareket sınırları, maksimum hız ve ivmeleri
- Euler açı sırası (ör. ZYX)
- Modele UDP blokları eklenmesine kim onay verecek?
