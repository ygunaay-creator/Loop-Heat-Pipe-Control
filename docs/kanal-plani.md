# Sensör ve Kanal Planı

> Taslak – sensör konumları ve sayıları hocayla kesinleştirilecek. Ekipman ayrıntıları: [ekipman.md](ekipman.md)

DAQM901A kartı **slot 100**'e takılıdır:
- **101–120:** 20 adet termokupl kanalı
- **121–122:** 2 adet akım kanalı. Basınç transmitterleri (4–20 mA) bu kanallara bağlanır, böylece 20 kanalın tamamı sıcaklığa kalır.

## Giriş kanalları (öneri)

Termokupl tipi önerisi: **T tipi** (−100…400 °C aralığında DAQ hatası 0,9 °C; 0 °C civarında iyi davranır). Kesinleşmedi.

| Kanal | Etiket | Büyüklük | Konum |
|---|---|---|---|
| 101 | T_EV_01 | Sıcaklık | Evaporatör gövdesi – ısıtıcı tarafı |
| 102 | T_EV_02 | Sıcaklık | Evaporatör gövdesi |
| 103 | T_EV_03 | Sıcaklık | Evaporatör gövdesi |
| 104 | T_CC | Sıcaklık | Kompansasyon odası (compensation chamber) |
| 105 | T_VL_IN | Sıcaklık | Buhar hattı girişi (evaporatör çıkışı) |
| 106 | T_VL_OUT | Sıcaklık | Buhar hattı çıkışı (kondenser girişi) |
| 107 | T_LL_IN | Sıcaklık | Sıvı hattı girişi (kondenser çıkışı) |
| 108 | T_LL_OUT | Sıcaklık | Sıvı hattı çıkışı (evaporatör girişi) |
| 109 | T_CO_01 | Sıcaklık | Kondenser |
| 110 | T_CO_02 | Sıcaklık | Kondenser |
| 111 | T_CO_03 | Sıcaklık | Kondenser |
| 112 | T_SURF_01 | Sıcaklık | Test yüzeyi (hücum kenarı) |
| 113 | T_SURF_02 | Sıcaklık | Test yüzeyi |
| 114 | T_SURF_03 | Sıcaklık | Test yüzeyi |
| 115 | T_SURF_04 | Sıcaklık | Test yüzeyi |
| 116 | T_SURF_05 | Sıcaklık | Test yüzeyi |
| 117 | T_CH_SUP | Sıcaklık | Soğutucu sıvı gidiş hattı |
| 118 | T_CH_RET | Sıcaklık | Soğutucu sıvı dönüş hattı |
| 119 | T_HTR | Sıcaklık | Isıtıcı yüzeyi (güvenlik limiti için) |
| 120 | T_AMB | Sıcaklık | Ortam |
| 121 | P_EV | Basınç (4–20 mA) | Evaporatör / buhar hattı – mutlak |
| 122 | P_CO | Basınç (4–20 mA) | Kondenser / sıvı hattı – mutlak |

Soğutucu sıvı gidiş/dönüş sıcaklıkları ve debisi bilinirse kondenserden çekilen ısı hesaplanabilir: Q_c = ṁ·c_p·ΔT. Bu değer enerji dengesi kontrolü için kullanılır.

## Cihazlardan okunan diğer büyüklükler

| Etiket | Kaynak | Açıklama |
|---|---|---|
| HTR_V, HTR_I, HTR_P | GPP-3323 CH1 (geri okuma) | Isıtıcı gerilimi, akımı, gücü (Q) |
| FAN_V, FAN_I | EDU36311A CH2 | Fan gerilimi ve akımı |
| LOOP_V | EDU36311A CH3 | Basınç sensörü besleme gerilimi (24 V) |
| CH_T_INT, CH_T_PROC, CH_SET | Huber CC-415 | Banyo sıcaklığı, proses sıcaklığı, hedef sıcaklık |
| SP_* | Simulink (UDP) | Stewart Platformu konum ve açıları |

## Çıkışlar (kontrol)

| Aktüatör | Cihaz | Kontrol |
|---|---|---|
| Isıtıcı | GPP-3323 CH1 (gerekirse CH1+CH2 seri/paralel) | Gerilim ayarı. Sabit güç veya sıcaklık hedefli (PID). |
| Fanlar | EDU36311A CH2 | Gerilim ayarıyla hız kontrolü |
| Basınç sensörü beslemesi | EDU36311A CH3 | Sabit 24 V |
| Test yüzeyi soğutması | Huber CC-415 | Hedef sıcaklık |
| Stewart Platformu | Simulink (UDP) | Hareket profili |

## Etiketleme kuralı

`<büyüklük>_<bölge>_<sıra>`

- Büyüklük: `T` sıcaklık, `P` basınç
- Bölge: `EV` evaporatör, `CC` kompansasyon odası, `VL` buhar hattı, `LL` sıvı hattı, `CO` kondenser, `SURF` test yüzeyi, `CH` soğutucu, `HTR` ısıtıcı, `AMB` ortam

Aynı etiketler LabVIEW kanal isimlerinde, kayıt dosyası sütunlarında ve Origin'de kullanılır.
