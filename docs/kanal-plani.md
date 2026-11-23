# Sensör ve Kanal Planı

> Taslak. Termokupl sayısı ve tipi kesinleşti (**23 × T tipi**). Konumlar öneri niteliğinde. Kanal numaraları yeni veri toplama cihazının modeline göre atanacak.

## Özet

| Grup | Sayı | Amaç |
|---|---|---|
| Evaporatör tarafı | 9 | Isıtıcı, evaporatör gövdesi, kompansasyon odaları, evaporatör giriş/çıkışı |
| Kondenser tarafı | 9 | Kondenser giriş/çıkışı, kondenser gövdesi, test yüzeyi dağılımı |
| Dış ölçümler | 5 | Ortam, soğutucu sıvı ve serbest ölçüm noktaları |
| **Toplam termokupl** | **23** | Hepsi **T tipi** |
| Basınç | 2 | DMS20S, 4–20 mA |
| **Toplam giriş** | **25** | |

**Neden T tipi?** Düşük sıcaklıklarda (0 °C civarı, buz önleme bölgesi) doğruluğu iyi. Literatürdeki üç çalışmanın üçü de T tipi kullanmış ([literatur.md](literatur.md)). T tipinde (ANSI) **mavi tel +, kırmızı tel −**.

## Evaporatör tarafı (9)

| # | Etiket | Konum | Not |
|---|---|---|---|
| 1 | `T_HTR` | Isıtıcı yüzeyi, **ısıtılan bölgenin ortası** | Güvenlik limiti ve $R_{tot}$ için |
| 2 | `T_EV_01` | Evaporatör gövdesi | |
| 3 | `T_EV_02` | Evaporatör gövdesi | |
| 4 | `T_EV_03` | Evaporatör gövdesi | |
| 5 | `T_CC1` | Kompansasyon odası 1 | Tek CC'li LHP'de `T_CC` |
| 6 | `T_CC2` | Kompansasyon odası 2 | LHP tek CC'liyse evaporatör gövdesine kaydırılır |
| 7 | `T_VL_IN` | Buhar hattı girişi (evaporatör çıkışı) | $R_{LHP}$ |
| 8 | `T_LL_OUT` | Sıvı hattı çıkışı (CC girişi) | Isı sızıntısı hesabı. CC girişine olabildiğince yakın |
| 9 | `T_EV_04` | Evaporatör / yedek | Gerekirse ikinci ısıtıcı noktası |

## Kondenser tarafı (9)

| # | Etiket | Konum | Not |
|---|---|---|---|
| 10 | `T_VL_OUT` | Buhar hattı çıkışı (kondenser girişi) | Başlangıç anı tespiti, $R_{LHP}$, $R_{cond}$ |
| 11 | `T_LL_IN` | Sıvı hattı girişi (kondenser çıkışı) | $R_{LHP}$, $R_{cond}$ |
| 12 | `T_CO_01` | Kondenser gövdesi | |
| 13 | `T_CO_02` | Kondenser gövdesi | |
| 14 | `T_SURF_01` | Test yüzeyi, kondenser **girişi** tarafı | Kondenser akış yönü boyunca sıralı |
| 15 | `T_SURF_02` | Test yüzeyi | |
| 16 | `T_SURF_03` | Test yüzeyi, orta | |
| 17 | `T_SURF_04` | Test yüzeyi | |
| 18 | `T_SURF_05` | Test yüzeyi, kondenser **çıkışı** tarafı | Buz önlemede kritik olan en soğuk nokta burada beklenir. **Kontrol değişkeni:** `min(T_SURF_01…05)` |

## Dış ölçümler (5)

| # | Etiket | Konum | Not |
|---|---|---|---|
| 19 | `T_AMB` | Ortam havası | Her deneyde kaydedilmeli |
| 20 | `T_CH_SUP` | Soğutucu sıvı gidiş hattı | $R_{tot}$, $R_{cond}$, enerji dengesi |
| 21 | `T_CH_RET` | Soğutucu sıvı dönüş hattı | Enerji dengesi: $Q_c = \dot m c_p (T_{CH\_RET} - T_{CH\_SUP})$ |
| 22 | `T_EXT_01` | Serbest (ör. yalıtım dış yüzeyi) | Deneye göre belirlenecek |
| 23 | `T_EXT_02` | Serbest (ör. fan çıkış havası) | Deneye göre belirlenecek |

## Basınç

| Etiket | Konum | Sinyal | Not |
|---|---|---|---|
| `P_EV` | Evaporatör / buhar hattı | 4–20 mA | Mutlak basınç |
| `P_CO` | Kondenser / sıvı hattı | 4–20 mA | Mutlak basınç |

Besleme: EDU36311A CH3, 24 V. Yeni DAQ'ta akım girişi yoksa her sensör için bir şönt direnç gerekir (250 Ω → 1–5 V).

## Cihazlardan okunan diğer büyüklükler

| Etiket | Kaynak | Açıklama |
|---|---|---|
| `HTR_V`, `HTR_I`, `HTR_P` | GPP-3323 CH1 | Isıtıcı gerilimi, akımı, gücü (Q) |
| `FAN_V`, `FAN_I` | EDU36311A CH2 | Fan gerilimi ve akımı |
| `CH_SET`, `CH_T_INT` | Huber CC-415 | Hedef ve banyo sıcaklığı (komut seti gelince) |
| `SP_*` | Simulink | Stewart Platformu konum ve açıları |

## Etiketleme kuralı

`<büyüklük>_<bölge>_<sıra>`

- Büyüklük: `T` sıcaklık, `P` basınç
- Bölge: `HTR` ısıtıcı, `EV` evaporatör, `CC` kompansasyon odası, `VL` buhar hattı, `LL` sıvı hattı, `CO` kondenser, `SURF` test yüzeyi, `AMB` ortam, `CH` soğutucu, `EXT` serbest dış ölçüm

Aynı etiketler MATLAB değişkenlerinde, kayıt dosyası sütunlarında ve analizde kullanılır. Termal direnç formülleri bu etiketlere göre yazılmıştır: [veri-formati.md](veri-formati.md).

## Yapılacaklar

- [ ] Yeni DAQ'ın modeline göre kanal numaralarını atamak
- [ ] LHP tek CC'li mi çift CC'li mi öğrenmek (`T_CC1`/`T_CC2`)
- [ ] Termokuplları buz noktasında (0 °C) kalibre etmek
- [ ] Termokuplları etiketlemek (kablonun iki ucuna etiket numarası)
