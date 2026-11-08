# Ekipman

Bu belge, ekipmanların projeyle ilgili özelliklerini, sistemdeki rollerini ve **MATLAB'dan nasıl kontrol edildiklerini** özetler. Değerler üretici belgelerinden ve laboratuvar testlerinden alınmıştır. Kesin değerler için orijinal kılavuzlara bakın.

## Özet

| Ekipman | Model | Rolü | PC bağlantısı | MATLAB | Durum |
|---|---|---|---|---|---|
| Veri toplama | **Yeni cihaz** (adı "Lab…" ile başlıyor, teyit edilecek) | 23 termokupl + 2 basınç | Belirlenecek | Belirlenecek | Seçildi, entegrasyon bekliyor |
| Güç kaynağı 1 | GW Instek **GPP-3323** | **Isıtıcı** (CH1) | USB → sanal COM | `serialport` | ✓ Test edildi |
| Güç kaynağı 2 | Keysight **EDU36311A** | **Fan** (CH2), basınç sensörü beslemesi (CH3) | USB (USBTMC) | `visadev` | ✓ Test edildi |
| Güç kaynağı 3 | Keysight **N5765A** | Yüksek güç (30 V / 50 A / 1500 W) | USB / LAN / GPIB | `visadev` | Kurulum aşamasında |
| Soğutucu | Huber **CC-415** (Pilot ONE) | Test yüzeyi soğutması (teyit edilecek) | USB / RS-232 / Ethernet | `serialport` (komut seti bekleniyor) | Test edilmedi |
| Termokupl | **T tipi** × 23 | 9 evaporatör + 9 kondenser + 5 dış | DAQ üzerinden | – | Karar verildi |
| Basınç sensörü | **DMS20S** × 2 | Evaporatör ve kondenser tarafı basıncı | DAQ üzerinden (4–20 mA) | – | Bağlantı DAQ'a göre belirlenecek |
| Bilgisayar | Dell Precision **T3680** | MATLAB, Simulink, Origin | – | – | – |
| Eski veri toplama | Keysight DAQ973A + DAQM901A | Artık ana cihaz değil | USB / LAN | `visadev` | Yedek / doğrulama için kullanılabilir |

**MATLAB gereksinimi:** Keysight cihazları (`visadev`) için **Instrument Control Toolbox** gerekir. Laboratuvar bilgisayarına kuruldu. GPP-3323 (`serialport`) temel MATLAB ile çalışır.

---

## Veri toplama cihazı (yeni)

Laboratuvar çalışmalarından sonra veri toplama cihazının değiştirilmesine karar verildi. Cihazın adı "Lab…" ile başlıyor. **Marka ve model teyit edilmeli** (olasılıklar: LabJack serisi, ADInstruments PowerLab/LabChart). Model netleşince bu bölüm doldurulacak:

- Kanal sayısı ve termokupl girişi var mı (soğuk uç kompanzasyonu dahili mi)?
- 4–20 mA akım girişi var mı? Yoksa basınç sensörleri için şönt direnç gerekir (ör. 250 Ω → 1–5 V).
- MATLAB'dan nasıl okunur (hazır MATLAB kütüphanesi, toolbox veya dosyadan aktarım)?
- Örnekleme hızı, doğruluk.

Gereken kanal sayısı: **23 termokupl + 2 basınç = 25 giriş.** Kanal planı: [kanal-plani.md](kanal-plani.md)

---

## GW Instek GPP-3323: Isıtıcı beslemesi

**Özellikler**
- CH1 ve CH2: 0–32 V / 0–3 A (her biri ~96 W). CH3: sabit 1,8 / 2,5 / 3,3 / 5 V, 5 A.
- Seri (64 V / 3 A) veya paralel (32 V / 6 A) bağlanabilir.
- Geri okuma doğruluğu: gerilim ±(%0,03 + 10 mV), akım ±(%0,3 + 10 mA).
- Komut sonu karakteri: `\n` (LF).

**Bağlantı (test edildi)**
- **GW Instek USB sürücüsü gerekli** ("GPP Serial"): [GPP-Series indirme sayfası](https://www.gwinstek.com/en-US/products/detail/GPP-Series). Sürücü yoksa Aygıt Yöneticisi'nde sarı ünlemli "USB2.0-Serial" (VID_2184, PID_0057) görünür.
- Cihazda **System → F1 (Interface) → F2 (USB)** seçilmeli. USB baud rate: **115200**.
- Windows'ta bir COM portu olarak görünür. Numara bilgisayara ve USB girişine göre değişir (testlerde COM3 ve COM5 görüldü).
- MATLAB: `serialport("COMx", 115200)`, `configureTerminator(gpp, "LF")`.

**Projedeki kullanım:** Isıtıcı **CH1**'e bağlı. Gerilim ve akım geri okunarak uygulanan ısı **Q = V · I** doğrudan ölçülür.

**Laboratuvar ölçümü (6 Kasım 2026):** Mevcut kartuş ısıtıcının direnci **≈ 5,33 Ω** (5,00 V'ta 0,939 A). CH1'in 3 A sınırıyla bu ısıtıcıya verilebilecek en yüksek güç **≈ 48 W** (≈ 16 V, 3 A).

| Hedef güç | VSET1 | Akım | ISET1 önerisi |
|---|---|---|---|
| 10 W | 7,3 V | 1,37 A | 1,6 A |
| 20 W | 10,3 V | 1,94 A | 2,3 A |
| 30 W | 12,6 V | 2,37 A | 2,8 A |
| ~48 W (en fazla) | 16 V | 3,0 A | 3,0 A |

**Not:** Aşırı akım koruması (OCP) akım sınırından (ISET) **yüksek** ayarlanmalı. İkisi eşit olursa kalkış akımında kanal hemen kapanır (fan testinde görüldü).

---

## Keysight EDU36311A: Fan ve sensör beslemesi

**Özellikler**
- CH1: 0–6 V / 5 A. CH2 ve CH3: 0–30 V / 1 A. Toplam 90 W.
- Geri okuma doğruluğu (CH2/3): gerilim ±(%0,05 + 10 mV), akım ±(%0,2 + 5 mA).
- OVP, OCP ve OTP korumaları.

**Bağlantı (test edildi)**
- USB (USBTMC): ayrı sürücü gerekmez, NI-VISA veya Keysight IO Libraries yeterli. Kablo **arka paneldeki** USB-B girişine takılmalı (ön paneldeki USB girişi bellek içindir).
- VISA adresi: `USB0::0x2A8D::0x8F01::CN64470294::0::INSTR`
- MATLAB: `visadev(...)` (Instrument Control Toolbox).
- Ethernet de mümkün: doğrudan kabloyla cihaz 169.254.x.x adresi alır. `tcpclient(IP, 5025)` ile toolbox'sız bağlanılabilir.

**Projedeki kullanım**
- **CH2: Fan.** 12 V'luk DC fan, hız gerilimle ayarlanır (yaklaşık 7–12 V).
- **CH3: Basınç sensörleri için 24 V döngü beslemesi** (planlanan).
- **CH1:** 5 A'ya kadar akım gereken küçük yükler (ör. peltier testi).

**Not:** Keysight cihazlarında OCP açıkken akım sınırına ulaşılınca kanal kapanır. Fan gibi kalkış akımı olan yüklerde OCP'yi kapalı bırakıp yalnızca akım sınırı kullanın.

---

## Keysight N5765A: Yüksek güç kaynağı

- **0–30 V, 0–50 A, en fazla 1500 W**, tek çıkış. USB, LAN, GPIB, LXI.
- Giriş: 100–240 V AC, 50–60 Hz, ≈ 1940 VA (230 V'ta ≈ 8,5 A).
- **AC girişi vidalı klemens (L, N, ⏚):** cihazla fişli kablo gelmiyor. Kablo ve topraklı fiş bağlantısı **yetkili kişiye yaptırılmalı / kontrol ettirilmeli.** Cihaz doğrudan topraklı duvar prizine takılmalı.
- **DC çıkış arka paneldeki baralardan** alınır (+V, −V). Halkalı kablo pabucu kullanılmalı, kablo kesiti akıma uygun olmalı (10 A'ya kadar ≥ 1,5 mm², 50 A için ≈ 10 mm²).
- Arka paneldeki **sense konnektörü** (local sense köprüleri) takılı kalmalı. **SW1** DIP anahtarlarına dokunulmamalı.
- **İlk açılışta yük bağlanmamalı.** Akım sınırı her zaman yüke göre düşük ayarlanmalı.

Ayrıntılı test adımları: [../matlab/README.md](../matlab/README.md)

---

## Huber CC-415 soğutucu (Pilot ONE)

- Çalışma aralığı −40…200 °C. Soğutma gücü 0 °C'de ≈ 1,0 kW, −20 °C'de ≈ 0,6 kW.
- Dahili Pt100, harici Pt100 girişi. "Exclusive" lisansıyla harici sensöre göre (proses) kontrol.
- Arayüzler: Ethernet, USB, RS-232.
- 60 kg, platforma konamaz. Platform testlerinde yerde kalır, hortumla bağlanır.
- **Rolü (test yüzeyi soğutması) bir varsayımdır, teyit edilmeli.** MATLAB'dan kontrol için Huber'in uzaktan kontrol komut seti gerekli.

## DMS20S basınç transmitteri

- Mutlak basınç, aralık seçenekleri 1 / 2 / 4 bar, ¼" erkek diş, **4–20 mA**, 2 telli. Doğruluk %0,5 FS.
- Besleme 12–30 V DC → EDU36311A CH3 (24 V).
- Ölçekleme: `P [bar] = (I [mA] − 4) / 16 × P_FS`
- Akışkan amonyak olursa bu sensörlerin aralığı yetersiz kalır ([literatur.md](literatur.md), Bölüm 5.1).

## Diğer

- **Kartuş ısıtıcı:** ≈ 5,33 Ω (ölçüldü). Kutupsuz.
- **Fan:** 12 V DC, Molex konnektörlü (sarı +12 V, siyah toprak). Laboratuvar testinde EDU36311A CH2'den 12 V ile çalıştırıldı.
- **Peltier TEC1-12715:** en fazla ≈ 15 V / 15 A. Kutuplu (kırmızı +). Soğutucu olmadan yalnızca kısa süreli ve düşük güçte çalıştırılmalı.

## Dell Precision T3680: Kontrol bilgisayarı

- Intel Core i9-14900, 32 GB RAM, Windows 11 Pro.
- 1 × RJ-45 Ethernet, 10 USB portu. Cihazlar USB ile bağlanır, Ethernet Simulink/Stewart Platformu için ayrılabilir.
