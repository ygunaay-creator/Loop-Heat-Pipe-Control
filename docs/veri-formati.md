# Veri Formatı

> Taslak.

## Dosya

- Biçim: **CSV**, UTF-8, ayraç `,`, ondalık ayırıcı `.` (Origin'e doğrudan aktarılabilmesi için)
- Gerekirse ek olarak **TDMS**
- Dosya adı: `YYYYMMDD_HHMMSS_<deney-adi>.csv`, ör. `20261105_143000_sabit-guc-20W.csv`
- Önerilen örnekleme aralığı: **1 s**

## Başlık (metadata)

Dosyanın başında `#` ile başlayan satırlar:

```
# deney: sabit-guc-20W
# tarih: 2026-11-05 14:30:00
# operator: Yigit, Alper
# ornekleme_araligi_s: 1
# tc_tipi: T
# basinc_araligi_bar: 4
# isitici_direnci_ohm: ...
# sogutucu_hedef_C: -10
# platform_profili: sabit
# not: ...
```

## Sütunlar

| Sütun | Birim | Kaynak |
|---|---|---|
| `time_s` | s | Deney başlangıcından itibaren süre |
| `timestamp` | ISO 8601 | PC saati |
| `T_EV_01` … `T_AMB` (20 sütun) | °C | DAQ973A, kanal 101–120 ([kanal-plani.md](kanal-plani.md)) |
| `P_EV`, `P_CO` | bar (mutlak) | DAQ973A, kanal 121–122 |
| `HTR_V`, `HTR_I`, `HTR_P` | V, A, W | GPP-3323 geri okuma |
| `HTR_SET` | W veya V | Isıtıcı komutu |
| `FAN_V`, `FAN_I` | V, A | EDU36311A CH2 |
| `CH_SET`, `CH_T_INT`, `CH_T_PROC` | °C | Huber CC-415 |
| `SP_STATUS` | – | Platform durumu |
| `SP_X` … `SP_YAW` | mm, ° | Platformun gerçek konumu ve açıları |
| `ALARM` | – | Aktif alarm kodu (0 = yok) |

## Origin'de hesaplanacak büyüklükler

- **Termal direnç:** R = (T_evap − T_kond) / Q [K/W]. Q = HTR_P = V·I.
- **Başlangıç süresi:** Isıtıcı açıldıktan sonra buhar hattı sıcaklığının yükselip sistemin kararlı çalışmaya geçme süresi
- **Kararlı hal:** Seçilen bir pencerede (ör. son 10 dk) sıcaklık değişimi < 0,1 °C/dk olduğunda ortalamalar
- **Test yüzeyi dağılımı:** T_SURF_01…05 ortalaması, minimum ve buz önleme eşiğiyle (ör. > 0 °C) karşılaştırma
- **Enerji dengesi (opsiyonel):** Soğutucu debisi biliniyorsa Q_c = ṁ·c_p·(T_CH_RET − T_CH_SUP)
- Platform açısına ve hareketine göre karşılaştırmalar

## Belirsizlik

| Kaynak | Değer | Not |
|---|---|---|
| DAQ (TC + soğuk uç) | ±0,9 °C (T/K tipi) | DAQ973A teknik verisi |
| Termokuplun kendisi | Tedarikçiye göre (T tipi Sınıf 1: ±0,5 °C) | Kalibrasyonla azaltılabilir |
| Basınç transmitteri | ±%0,5 FS (4 bar'da ±0,02 bar) + sıcaklık kayması | DMS20S |
| DAQ akım ölçümü | DAQ973A teknik verisine bakılacak | |
| Isıtıcı gerilimi | ±(%0,03 + 10 mV) | GPP-3323 geri okuma |
| Isıtıcı akımı | ±(%0,3 + 10 mA) | GPP-3323 geri okuma |

Termal direnç belirsizliği, bileşenlerin yayılımıyla (kök-kareler toplamı) hesaplanır:

(u_R / R)² = (u_ΔT / ΔT)² + (u_Q / Q)²,  u_ΔT = √(u_Tevap² + u_Tkond²)

Aynı referansta karşılaştırma kalibrasyonu yapılırsa sıcaklık farklarındaki sistematik hata büyük ölçüde azalır.
