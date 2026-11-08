# MATLAB: Cihaz Kontrolü ve Komut Kılavuzu

Bu klasör, laboratuvardaki cihazları **MATLAB'dan** kontrol etmek için hazır fonksiyonları ve komut penceresine (Command Window) yazılacak komutları içerir. Komutların hepsi 6 Kasım 2026'da İTÜ laboratuvarında denendi. N5765A hariç, onun testi henüz yapılmadı.

**İçindekiler**
1. [Kurulum](#1-kurulum)
2. [Bağlantı özeti](#2-bağlantı-özeti)
3. [Hazır fonksiyonlar](#3-hazır-fonksiyonlar)
4. [Komut penceresi kılavuzu](#4-komut-penceresi-kılavuzu)
5. [Komut listeleri](#5-komut-listeleri)
6. [Sorun giderme](#6-sorun-giderme)
7. [Veri toplama cihazı (yeni)](#7-veri-toplama-cihazı-yeni)

---

## 1. Kurulum

1. **MATLAB** + **Instrument Control Toolbox** (Home → Add-Ons → Get Add-Ons). Keysight cihazları (`visadev`) için gerekli.
2. **NI-VISA** veya **Keysight IO Libraries Suite**. EDU36311A ve N5765A için.
3. **GW Instek USB sürücüsü.** GPP-3323 için: [GPP-Series indirme sayfası](https://www.gwinstek.com/en-US/products/detail/GPP-Series) → USB Driver.
4. Bu klasörü MATLAB yoluna ekleyin:
   ```matlab
   addpath("C:\...\Loop-Heat-Pipe-Control\matlab")   % kendi yolunuzu yazın
   ```

## 2. Bağlantı özeti

| Cihaz | Görev | Kablo | MATLAB | Adres |
|---|---|---|---|---|
| GW Instek GPP-3323 | Isıtıcı (CH1) | USB-B, arka panel | `serialport` | `COMx`, 115200 baud |
| Keysight EDU36311A | Fan (CH2), 24 V sensör (CH3) | USB-B, **arka** panel | `visadev` | `USB0::0x2A8D::0x8F01::CN64470294::0::INSTR` |
| Keysight N5765A | Yüksek güç | USB-B / LAN | `visadev` | `visadevlist` ile bulunur |

**Kanal sınırları**

| Cihaz / kanal | Gerilim | Akım | Not |
|---|---|---|---|
| GPP-3323 CH1, CH2 | 0–32 V | 0–3 A | Isıtıcı CH1'de |
| GPP-3323 CH3 | 1,8 / 2,5 / 3,3 / 5 V sabit | 5 A | |
| EDU36311A CH1 | 0–6 V | 0–5 A | 12 V fan için uygun değil |
| EDU36311A CH2, CH3 | 0–30 V | 0–1 A | Fan CH2'de |
| N5765A | 0–30 V | 0–50 A | Akım sınırını mutlaka düşük ayarlayın |

## 3. Hazır fonksiyonlar

| Dosya | Ne yapar | Örnek |
|---|---|---|
| `gpp_baglan.m` | GPP-3323'e bağlanır. Port verilmezse kendisi bulur | `gpp = gpp_baglan();` |
| `edu_baglan.m` | EDU36311A'ya bağlanır. Eski bağlantıyı kapatır | `edu = edu_baglan();` |
| `gpp_oku.m` | GPP kanalının gerçek V, I, P değerini okur | `[V,I,P] = gpp_oku(gpp,1)` |
| `isitici_direnc_olc.m` | Isıtıcı direncini 2 V ile güvenli ölçer | `R = isitici_direnc_olc(gpp)` |
| `isitici_guc_basamaklari.m` | Sabit güç basamakları, CSV kaydı, bitince kapatır | `isitici_guc_basamaklari(gpp,[10 20 30],180)` |
| `fan_ayarla.m` | Fan hızını gerilimle ayarlar (0 = kapat) | `fan_ayarla(edu,12)` |
| `peltier_test.m` | Peltieri kısa süre çalıştırıp kapatır | `peltier_test(edu,1,3,20)` |
| `tum_cikislari_kapat.m` | Bütün güç kaynaklarının çıkışlarını kapatır | `tum_cikislari_kapat` |
| `n5765a_ilk_test.m` | N5765A ilk bağlantı testi (yüksüz) | `n5765a_ilk_test` |

Isıtıcı ve peltier fonksiyonları **Ctrl+C**, hata veya bitişte çıkışı kendiliğinden kapatır (`onCleanup`).

**Tipik bir deney:**
```matlab
gpp = gpp_baglan();                          % ısıtıcı
edu = edu_baglan();                          % fan
fan_ayarla(edu, 12);                         % fanı aç
R = isitici_direnc_olc(gpp);                 % direnç ≈ 5,33 Ω
isitici_guc_basamaklari(gpp, [10 20 30], 180, R);   % 3 basamak × 3 dk, kaydet, kapat
fan_ayarla(edu, 0);                          % fanı kapat
clear gpp edu
```

---

## 4. Komut penceresi kılavuzu

Aşağıdaki blokları komut penceresine kopyalayıp yapıştırabilirsiniz. Bir bağlantıyı (`gpp`, `edu`) **bir kez** açın, iş bitince `clear` ile kapatın.

### 4.1 GPP-3323 (ısıtıcı)

**Bağlan**
```matlab
serialportlist("available")                     % GPP hangi COM'da?
gpp = serialport("COM3", 115200, "Timeout", 2); % listedeki portu yazın
configureTerminator(gpp, "LF");
writeline(gpp, "*IDN?");  readline(gpp)         % "GW Instek,GPP-3323,SN:...,V1.26"
```

**Korumalar (bir kez)**
```matlab
writeline(gpp, ":OUTPut1:OVP 30");   writeline(gpp, ":OUTPut1:OVP:STATe ON");
writeline(gpp, ":OUTPut1:OCP 3.3");  writeline(gpp, ":OUTPut1:OCP:STATe ON");
```

**Isıtıcıyı aç / ayarla / kapat**
```matlab
writeline(gpp, "ISET1:1.6");             % akım sınırı
writeline(gpp, "VSET1:7.3");             % gerilim → 5,33 Ω'da ≈ 10 W
writeline(gpp, ":OUTPut1:STATe ON");     % çıkışı AÇ (VSET tek başına açmaz!)

writeline(gpp, "VOUT1?");  readline(gpp) % gerçek gerilim
writeline(gpp, "IOUT1?");  readline(gpp) % gerçek akım

writeline(gpp, ":OUTPut1:STATe OFF");    % kapat
```

**Güç tablosu (ısıtıcı ≈ 5,33 Ω)**

| Güç | VSET1 | ISET1 |
|---|---|---|
| 5 W | 5,2 | 1,2 |
| 10 W | 7,3 | 1,6 |
| 20 W | 10,3 | 2,3 |
| 30 W | 12,6 | 2,8 |
| ≈ 48 W (en fazla) | 17 | 3 (sabit akım modunda kalır) |

Gerilim hesabı: $V = \sqrt{P \cdot R}$, akım: $I = V/R$ (en fazla 3 A).

**Hepsini kapat ve bağlantıyı bitir**
```matlab
writeline(gpp, ":ALLOUTOFF");
clear gpp
```

### 4.2 EDU36311A (fan, peltier, sensör beslemesi)

**Bağlan**
```matlab
visadevlist                                                        % adresi gösterir
edu = visadev("USB0::0x2A8D::0x8F01::CN64470294::0::INSTR");
edu.Timeout = 3;
writeline(edu, "*IDN?");  readline(edu)   % "Keysight Technologies,EDU36311A,CN64470294,..."
```

**Fan (CH2, 12 V)**
```matlab
writeline(edu, "VOLT:PROT 13,(@2)");     % aşırı gerilim koruması
writeline(edu, "APPL CH2,12,0.6");       % 12 V, akım sınırı 0,6 A
writeline(edu, "OUTP ON,(@2)");
writeline(edu, "MEAS:VOLT? CH2");  readline(edu)
writeline(edu, "MEAS:CURR? CH2");  readline(edu)   % fan çalışıyorsa ≈ 0,1–0,3 A

writeline(edu, "VOLT 8,(@2)");           % hızı düşür
writeline(edu, "OUTP OFF,(@2)");         % kapat
```

**Basınç sensörleri için 24 V (CH3, planlanan)**
```matlab
writeline(edu, "APPL CH3,24,0.1");
writeline(edu, "OUTP ON,(@3)");
```

**Peltier (CH1, 6 V / 5 A kanal)**
```matlab
writeline(edu, "APPL CH1,4,3");          % akım sınırı 3 A → ≈ 9–10 W
writeline(edu, "OUTP ON,(@1)");
% ... kısa süre ...
writeline(edu, "OUTP OFF,(@1)");
```

**Hata kontrolü ve kapatma**
```matlab
writeline(edu, "SYST:ERR?");  readline(edu)   % +0,"No error"
writeline(edu, "OUTP OFF,(@1:3)");            % tüm kanallar
clear edu
```

### 4.3 N5765A (henüz test edilmedi)

```matlab
n57 = visadev("USB0::...::INSTR");       % visadevlist'teki adres
n57.Timeout = 3;
writeline(n57, "*IDN?");  readline(n57)
writeline(n57, "VOLT:PROT:LEV 10");      % OVP 10 V
writeline(n57, "CURR 1");                % akım sınırı ÖNCE
writeline(n57, "VOLT 5");
writeline(n57, "OUTP ON");
writeline(n57, "MEAS:VOLT?");  readline(n57)
writeline(n57, "OUTP OFF");
clear n57
```

---

## 5. Komut listeleri

### GPP-3323 (kılavuzdan, sonları `\n`)

| Komut | Anlamı |
|---|---|
| `*IDN?` | Kimlik |
| `VSET<n>:<V>` / `VSET<n>?` | Gerilim ayarı / sorgu |
| `ISET<n>:<A>` / `ISET<n>?` | Akım sınırı ayarı / sorgu |
| `VOUT<n>?` / `IOUT<n>?` | Gerçek gerilim / akım |
| `:OUTPut<n>:STATe ON\|OFF` | Kanal çıkışı |
| `:ALLOUTON` / `:ALLOUTOFF` | Tüm çıkışlar |
| `:OUTPut<n>:OVP <V>` + `:OUTPut<n>:OVP:STATe ON` | Aşırı gerilim koruması |
| `:OUTPut<n>:OCP <A>` + `:OUTPut<n>:OCP:STATe ON` | Aşırı akım koruması |
| `:OUTPut:SERies ON\|OFF`, `:OUTPut:PARallel ON\|OFF` | Seri / paralel mod |

### EDU36311A (laboratuvarda denenenler)

| Komut | Anlamı |
|---|---|
| `*IDN?`, `*RST` | Kimlik, varsayılan ayarlar (tüm çıkışlar kapanır) |
| `APPL CH<n>,<V>,<A>` | Gerilim ve akım sınırını birlikte ayarla |
| `VOLT <V>,(@<n>)` | Sadece gerilim |
| `VOLT:PROT <V>,(@<n>)` | Aşırı gerilim koruması |
| `OUTP ON\|OFF,(@<n>)`, `OUTP OFF,(@1:3)` | Çıkış |
| `MEAS:VOLT? CH<n>`, `MEAS:CURR? CH<n>` | Ölçüm (cevap `+1.20002800E+01` biçiminde) |
| `SYST:ERR?` | Son hata |

---

## 6. Sorun giderme

Laboratuvarda yaşanan sorunlar ve çözümleri:

| Belirti | Sebep | Çözüm |
|---|---|---|
| Aygıt Yöneticisi'nde sarı ünlemli "USB2.0-Serial" | GW Instek sürücüsü yok | Sürücüyü kurun (VID_2184 = GW Instek) |
| GPP `*IDN?`'ye cevap vermiyor | Cihaz USB modunda değil / baud uyuşmuyor | System → F1 → **F2 (USB)**, baud **115200** |
| `serialport`: *Unable to connect ... port is not in use* | Port zaten açık (başka değişken, LabVIEW, GW yazılımı) | `delete(serialportfind); clear gpp s` |
| `serialportlist` boş | GPP bağlı değil ya da kapalı | Kabloyu ve cihazı kontrol edin. COM numarası değişebilir |
| COM numarası değişti (COM5 → COM3) | Farklı USB girişi / bilgisayar | `serialportlist("available")` ile bakın |
| `Unrecognized function or variable 'gpp'` | Bağlantı `clear` ile kapatılmış | Yeniden bağlanın (`gpp_baglan`) |
| `Creating a second device ... is not supported` | `edu` zaten açıkken tekrar `visadev` | Yeniden bağlanmayın, `edu`'yu kullanın. Ya da `edu_baglan` |
| `visadevlist requires Instrument Control Toolbox` | Toolbox yok | Add-Ons'tan kurun |
| EDU hiç görünmüyor (Aygıt Yöneticisi'nde de yok) | Ön panel USB'si / kablo / ayar | **Arka panel** USB-B, veri kablosu, Utility → I/O'da USB açık |
| VSET yaptım ama çıkış yok | Çıkış kapalı | `:OUTPut1:STATe ON` (GPP), `OUTP ON,(@n)` (EDU) |
| GPP'de kırmızı **OCP**, kanal kapandı | OCP = ISET; kalkış akımı korumayı tetikledi | OCP'yi ISET'ten yüksek ayarlayın (ör. ISET 0,6, OCP 1) |
| Ölçülen akım ≈ 0 | Yük o kanala bağlı değil | Kabloyu ve kanal numarasını kontrol edin |
| Akım tam ISET değerinde, gerilim ayarın altında | Cihaz sabit akım (CC) modunda | Yük beklenenden fazla akım istiyor, direnci ölçün |
| Ön panel tuşları çalışmıyor | Uzaktan kontrol kilidi (RMT) | GPP: **F6** uzun bas. EDU: **Unlock** |

**Güvenlik**
- Isıtıcı açıkken başında durun. Sıcaklık henüz ölçülmüyor.
- Isıtılan parçanın altında kâğıt veya yanıcı malzeme olmasın.
- Acil durumda: **Ctrl+C**, ardından `tum_cikislari_kapat`. Ya da cihazın ön panelindeki On/Off tuşu.

---

## 7. Veri toplama cihazı (yeni)

Veri toplama cihazı değişti. **Model teyit edilecek** ("Lab…" ile başlıyor). Cihaz netleşince bu bölüme eklenecekler:
- MATLAB'dan bağlantı ve 23 T tipi termokuplun okunması ([../docs/kanal-plani.md](../docs/kanal-plani.md))
- 4–20 mA basınç sensörlerinin okunması ve bar'a ölçeklenmesi: `P = (I_mA - 4) / 16 * P_FS`
- Güç kaynaklarıyla birlikte tek döngüde kayıt yapan ana betik (`deney_ana.m`)
