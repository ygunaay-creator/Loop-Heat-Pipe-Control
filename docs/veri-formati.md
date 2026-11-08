# Veri Formatı

> Taslak. Kanal etiketleri: [kanal-plani.md](kanal-plani.md)

## Dosya

- Biçim: **CSV**, UTF-8, ayraç `,`, ondalık ayırıcı `.`
- MATLAB'da yazma: `writetable` veya döngü içinde `fprintf` ile satır satır (deney yarıda kesilirse veri kaybolmaz)
- İsteğe bağlı olarak deney sonunda `.mat` dosyası (`save`)
- Dosya adı: `YYYYMMDD_HHMMSS_<deney-adi>.csv`, ör. `20261115_143000_sabit-guc-20W.csv`
- Konum: `data/raw/` (repoya gönderilmez)
- Önerilen örnekleme aralığı: **1 s**

## Başlık (metadata)

Dosyanın başında `#` ile başlayan satırlar:

```
# deney: sabit-guc-20W
# tarih: 2026-11-15 14:30:00
# operator: Yigit, Alper
# ornekleme_araligi_s: 1
# tc_tipi: T
# isitici_direnci_ohm: 5.33
# sogutucu_hedef_C: -10
# platform_profili: sabit
# not: ...
```

MATLAB'da okurken: `readtable(dosya, "CommentStyle", "#")`

## Sütunlar

| Sütun | Birim | Kaynak |
|---|---|---|
| `time_s` | s | Deney başlangıcından itibaren süre (`toc`) |
| `timestamp` | ISO 8601 | `datetime("now")` |
| `T_HTR`, `T_EV_01` … `T_EV_04`, `T_CC1`, `T_CC2`, `T_VL_IN`, `T_LL_OUT` | °C | DAQ, evaporatör tarafı (9) |
| `T_VL_OUT`, `T_LL_IN`, `T_CO_01`, `T_CO_02`, `T_SURF_01` … `T_SURF_05` | °C | DAQ, kondenser tarafı (9) |
| `T_AMB`, `T_CH_SUP`, `T_CH_RET`, `T_EXT_01`, `T_EXT_02` | °C | DAQ, dış ölçümler (5) |
| `P_EV`, `P_CO` | bar (mutlak) | DAQ |
| `HTR_V`, `HTR_I`, `HTR_P` | V, A, W | GPP-3323 CH1 geri okuma |
| `HTR_SET` | W veya V | Isıtıcı komutu |
| `FAN_V`, `FAN_I` | V, A | EDU36311A CH2 |
| `CH_SET`, `CH_T_INT` | °C | Huber CC-415 |
| `SP_STATUS`, `SP_X` … `SP_YAW` | –, mm, ° | Stewart Platformu |
| `ALARM` | – | Aktif alarm kodu (0 = yok) |

Henüz bağlı olmayan cihazların sütunları `NaN` yazılır. Böylece dosya yapısı her deneyde aynı kalır.

## Hesaplanacak büyüklükler

**Termal dirençler** (tanımlar: [literatur.md](literatur.md), Bölüm 5.2). $Q$ = `HTR_P`.

| Büyüklük | Formül | Karşılaştırma |
|---|---|---|
| Döngü direnci $R_{LHP}$ | $\big(T_{VL\_IN} - \tfrac{1}{2}(T_{VL\_OUT}+T_{LL\_IN})\big)/Q$ | Zhao 2017 |
| Toplam direnç $R_{tot}$ | $(T_{HTR} - T_{CH\_SUP})/Q$ | Wang 2023/2024 |
| Kondenser direnci $R_{cond}$ | $\big(\tfrac{1}{2}(T_{VL\_OUT}+T_{LL\_IN}) - T_{CH\_SUP}\big)/Q$ | Wang 2024 |

**Diğer**
- **Başlangıç süresi:** Isıtıcı açıldıktan `T_VL_OUT`'un belirgin şekilde yükselmeye başlamasına kadar geçen süre ($dT/dt$ eşiği).
- **Aşırı ısınma:** Başlangıçtaki en yüksek `T_EV` değeri − kararlı hal değeri.
- **Buz önleme hazır olma süresi:** Isıtıcı açıldıktan sonra en soğuk `T_SURF` kanalının 0 °C'yi geçmesine kadar geçen süre.
- **Kararlı hal:** Örneğin tüm sıcaklıklarda 5 dakikada 0,1 °C'den az değişim (ekiple netleştirilecek).
- **Enerji dengesi:** Soğutucu debisi biliniyorsa $Q_c = \dot m c_p (T_{CH\_RET} - T_{CH\_SUP})$.

## Belirsizlik

| Kaynak | Değer | Not |
|---|---|---|
| Termokupl (T tipi, Sınıf 1) | ±0,5 °C | Buz noktası kalibrasyonuyla azaltılabilir |
| DAQ | Yeni cihazın teknik verisinden eklenecek | |
| Basınç transmitteri | ±%0,5 FS | DMS20S |
| Isıtıcı gerilimi | ±(%0,03 + 10 mV) | GPP-3323 geri okuma |
| Isıtıcı akımı | ±(%0,3 + 10 mA) | GPP-3323 geri okuma |

Termal direnç belirsizliği:

$(u_R/R)^2 = (u_{\Delta T}/\Delta T)^2 + (u_Q/Q)^2$, $\quad u_{\Delta T} = \sqrt{u_{T1}^2 + u_{T2}^2}$

Aynı referansta karşılaştırma kalibrasyonu yapılırsa sıcaklık farklarındaki sistematik hata büyük ölçüde azalır.
