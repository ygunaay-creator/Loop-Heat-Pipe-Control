# Ekipman

Bu belge, elimizdeki ekipmanların projeyle ilgili özelliklerini ve sistemdeki rollerini özetler. Değerler üretici belgelerinden alınmıştır. Kesin değerler için orijinal kılavuzlara bakın.

## Özet

| Ekipman | Model | Rolü | PC bağlantısı | LabVIEW ile kontrol |
|---|---|---|---|---|
| Veri toplama | Keysight **DAQ973A** + **DAQM901A** | Sıcaklık ve basınç ölçümü | USB / LAN (GPIB) | SCPI (VISA) |
| Güç kaynağı 1 | GW Instek **GPP-3323** | **Isıtıcı** beslemesi ve güç ölçümü (Q) | USB / RS-232 (LAN, GPIB opsiyonel) | SCPI (VISA) |
| Güç kaynağı 2 | Keysight **EDU36311A** | **Fanlar** ve basınç sensörlerinin 24 V beslemesi | USB / LAN | SCPI (VISA), IVI |
| Soğutucu | Huber **CC-415** (Pilot ONE) | Kondenser / test yüzeyi soğutması | Ethernet / USB / RS-232 | Huber komut seti (doğrulanacak) |
| Basınç sensörü (×2) | **DMS20S** basınç transmitteri | Evaporatör ve kondenser tarafı basıncı | DAQM901A akım kanalları | DAQ üzerinden |
| Bilgisayar | Dell Precision **T3680** | LabVIEW, Simulink, Origin | – | – |

**Önemli sonuç:** DAQM901A yalnızca ölçüm kartıdır, çıkışı yoktur. Isıtıcı ve fanların kontrolü **güç kaynakları üzerinden** yapılır: LabVIEW, güç kaynaklarına SCPI komutlarıyla gerilim ve akım ayarı gönderir. Bu nedenle ek bir çıkış modülüne (DAQM907A/DAQM903A) gerek yoktur.

---

## Keysight DAQ973A + DAQM901A

**Ana kasa (DAQ973A)**
- Dahili 6½ haneli DMM, 3 modül yuvası (100 / 200 / 300)
- Arayüzler: USB 2.0, Gigabit LAN, GPIB. Ayrıca web arayüzü ve ön panel.
- 1 milyon okumalık zaman damgalı kalıcı hafıza, USB belleğe kayıt
- Kanal başına alarm limitleri, 4 adet TTL alarm çıkışı
- Kanal başına **Mx+B ölçekleme** (ör. 4–20 mA → bar)
- Programlama: SCPI-1999, 34970A/34972A uyumlu
- Birlikte gelen yazılım: **BenchVue DAQ**. LabVIEW programı hazır olmadan sensörleri test etmek için kullanılabilir.

**Kart (DAQM901A)**: 20 kanallı armatür multiplexer
- 20 adet 2 telli kanal (101–120) + **2 adet sigortalı akım kanalı (121–122, en fazla 1 A)**
- **Dahili termokupl soğuk uç referansı**
- Kopuk termokupl kontrolü (kanal başına seçilebilir)
- Tarama hızı: DCV için 80 kanal/s, **termokupl için 50 kanal/s**. 20 termokupl kanalının bir taraması yaklaşık 0,4 s sürer, bu nedenle önerilen örnekleme aralığı **1 s**.

**Termokupl doğruluğu (DAQ + soğuk uç, termokuplun kendi hatası hariç)**

| Tip | Aralık | Hata |
|---|---|---|
| K | −100…1200 °C | 0,9 °C |
| T | −100…400 °C | 0,9 °C |
| J | −150…1200 °C | 1,0 °C |
| E | −150…1000 °C | 1,0 °C |

Pt100 RTD de desteklenir (DMM hatası 0,05 °C). Kritik noktalarda daha hassas ölçüm için seçenek olabilir.

## GW Instek GPP-3323: Isıtıcı beslemesi

- CH1 ve CH2: 0–32 V / 0–3 A (her biri ~96 W). CH3: sabit 1,8 / 2,5 / 3,3 / 5 V, 5 A.
- **Tracking seri** modunda 64 V / 3 A, **paralel** modda 32 V / 6 A (en fazla ~192 W)
- Geri okuma doğruluğu: gerilim ±(0,03 % + 10 mV), akım ±(0,3 % + 10 mA)
- Arayüzler: RS-232 ve USB (standart), LAN ve GPIB (opsiyonel). SCPI komutları.

**Projedeki rolü:** Isıtıcıyı besler. LabVIEW gerilimi ayarlar, gerilim ve akımı geri okur. **Uygulanan ısı Q = V · I doğrudan ölçülür.** Bu değer termal direnç hesabı için gereklidir. Sabit güç modu, LabVIEW'da gerilimin sürekli ayarlanmasıyla sağlanır.

> Isıtıcının direnci ve hedef güç aralığı netleşince kaynağın yeterli olup olmadığı kontrol edilmeli. Örneğin 10 Ω'luk bir ısıtıcı 32 V'ta 3,2 A çeker, bu da 3 A sınırının üzerindedir.

## Keysight EDU36311A: Fan ve sensör beslemesi

- CH1: 0–6 V / 5 A. CH2 ve CH3: 0–30 V / 1 A. Toplam 90 W. Kanallar birbirinden yalıtılmıştır.
- CH2 ve CH3 seri (60 V) veya paralel (2 A) bağlanabilir.
- Geri okuma doğruluğu (CH2/3): gerilim ±(0,05 % + 10 mV), akım ±(0,2 % + 5 mA)
- OVP, OCP ve OTP korumaları. Komut işleme süresi 10 ms'nin altında.
- Arayüzler: USB, LAN (LXI). SCPI, IVI sürücüsü, BenchVue.

**Önerilen kullanım:**
- **CH2:** fan(lar). DC fanların hızı besleme gerilimiyle ayarlanır.
- **CH3:** basınç transmitterleri için **24 V döngü beslemesi**
- CH1: yedek (5 V'luk fanlar veya ek ihtiyaçlar için)

## Huber CC-415 soğutucu (Pilot ONE)

- Çalışma aralığı: −40…200 °C, −10 °C'de ±0,02 K kararlılık
- Soğutma gücü: 20 °C'de 1,2 kW, 0 °C'de 1,0 kW, −20 °C'de 0,6 kW, −30 °C'de 0,2 kW
- Basma pompası: 25 l/min, 0,7 bar. Emme pompası: 18,5 l/min. Banyo hacmi 5 l. Pompa bağlantısı M16×1.
- Dahili Pt100, **harici Pt100 girişi**
- Arayüzler: Ethernet, USB, RS-232. Huber "Spy" yazılımı ile uzaktan kontrol ve veri alma.
- "Exclusive" E-grade lisansı ile **process (harici sensör) kontrolü**, rampa ve programlar. Lisans durumu bilinmiyor.
- Boyut ve ağırlık: 410×480×764 mm, **60 kg**. Ortam sıcaklığı 5–40 °C olmalı.

**Projedeki rolü:** Soğuk test yüzeyini (kondenser tarafı) düşük sıcaklığa getirmek. LabVIEW'dan hedef sıcaklık ayarlanıp banyo ve proses sıcaklığı okunabilir.

> Stewart Platformu testlerinde soğutucu platforma konamaz. Yerde kalır ve platforma esnek hortumlarla bağlanır. Hortum uzunluğu ve hareket sırasında hortumların gerilmemesi planlanmalıdır.

## DMS20S basınç transmitteri

- Difüze silikon sensör, SS316L diyafram. Mutlak, gösterge veya sızdırmaz gösterge basıncı ölçebilir.
- Temin edilen modelin özellikleri: **mutlak basınç**, aralık seçenekleri 1 / 2 / 4 bar, ¼" erkek diş, **4–20 mA çıkış**
- Doğruluk %0,5 FS. Histerezis ve tekrarlanabilirlik %0,1 FS. Sıcaklık kayması ±%1,5 FS (−20…85 °C).
- Besleme 12–30 V DC, **2 telli** bağlantı (kırmızı: besleme +, yeşil: akım çıkışı)
- Ortam sıcaklığı −20…85 °C, akışkan sıcaklığı −30…105 °C. Tepki süresi ≤1 ms. IP65.

**Bağlantı:**
```
EDU36311A CH3 (+24 V) ──► Transmitter kırmızı (+)
Transmitter yeşil (çıkış) ──► DAQM901A akım kanalı (121 / 122) ──► EDU36311A CH3 (−)
```
**Ölçekleme (DAQ'da Mx+B veya LabVIEW'da):**
`P [bar] = (I [mA] − 4) / 16 × P_FS`  (P_FS: 1, 2 veya 4 bar)

## Dell Precision T3680: Kontrol bilgisayarı

- Intel Core i9-14900, 32 GB DDR5, 1 TB NVMe SSD, NVIDIA RTX 2000 Ada, Windows 11 Pro
- **1 adet RJ-45 (Intel I219-LM)**, 4× USB-C, 4× USB 3.2, 2× USB 2.0, boş PCIe yuvaları

**Bağlantı planı (öneri):** Bilgisayarda tek Ethernet portu olduğu için cihazlar **USB** ile bağlanır. Ethernet portu Simulink/Stewart Platformu ağı için ayrılır. Ağ üzerinden birden fazla cihaz gerekirse bir ağ anahtarı (switch) ya da PCIe ağ kartı eklenir.

| Cihaz | Bağlantı |
|---|---|
| DAQ973A | USB |
| GPP-3323 | USB (sanal COM) |
| EDU36311A | USB |
| Huber CC-415 | USB veya RS-232 |
| Simulink / Stewart Platformu | Ethernet (UDP) |
