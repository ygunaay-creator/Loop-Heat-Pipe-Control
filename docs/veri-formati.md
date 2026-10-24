# Veri Formatı

> Taslak.

## Dosya

- Biçim: **CSV**, UTF-8, ayraç `,`, ondalık ayırıcı `.` (Origin'e doğrudan aktarılabilmesi için)
- Gerekirse yüksek hızlı kayıtlar için ek olarak **TDMS**
- Dosya adı: `YYYYMMDD_HHMMSS_<deney-adi>.csv`, ör. `20261105_143000_sabit-egim-10deg.csv`

## Başlık (metadata)

Dosyanın başında `#` ile başlayan satırlar:

```
# deney: sabit-egim-10deg
# tarih: 2026-11-05 14:30:00
# operator: Yigit, Alper
# ornekleme_hizi_Hz: 1
# isitici_gucu_W: 50
# not: ...
```

## Sütunlar

| Sütun | Birim | Açıklama |
|---|---|---|
| `time_s` | s | Deney başlangıcından itibaren geçen süre |
| `timestamp` | ISO 8601 | Gerçek zaman |
| `T_EV_01` … `T_EV_06` | °C | Evaporatör sıcaklıkları |
| `T_CO_01` … `T_CO_06` | °C | Kondenser sıcaklıkları |
| `P_EV`, `P_CO` | bar | Basınçlar |
| `heater_cmd` | % veya W | Isıtıcıya verilen komut |
| `fan_cmd` | % | Fan komutu |
| `sp_status` | – | Platform durumu |
| `sp_x` … `sp_yaw` | mm, ° | Platformun gerçek konumu ve açıları |
| `alarm` | – | Aktif alarm kodu (0 = yok) |

Kanal isimleri [kanal-plani.md](kanal-plani.md) ile aynı olmalıdır.

## Origin'de hesaplanacak büyüklükler

- **Termal direnç:** R = (T_evaporatör − T_kondenser) / Q  [K/W]
- **Başlangıç süresi:** ısıtıcı açıldıktan sonra sistemin kararlı çalışmaya geçme süresi
- **Kararlı hal sıcaklıkları** ve test yüzeyi sıcaklık dağılımı
- Platform açısına ve hareketine göre performans karşılaştırmaları
