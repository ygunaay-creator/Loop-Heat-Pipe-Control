# Sensör ve Kanal Planı

> Taslak – sensör sayısı, tipi ve konumları kesinleştiğinde güncellenecek. Kanal atamaları şimdilik önerilir.

Veri toplama cihazında **20 giriş kanalı** bulunmaktadır. Beklenen sensör sayısı 14 olduğundan 6 kanal yedektir.

## Giriş kanalları

| Kanal | Etiket | Büyüklük | Konum | Sensör tipi | Not |
|---|---|---|---|---|---|
| 1 | T_EV_01 | Sıcaklık | Evaporatör | Belirsiz (termokupl?) | |
| 2 | T_EV_02 | Sıcaklık | Evaporatör | | |
| 3 | T_EV_03 | Sıcaklık | Evaporatör | | |
| 4 | T_EV_04 | Sıcaklık | Evaporatör | | |
| 5 | T_EV_05 | Sıcaklık | Evaporatör | | |
| 6 | T_EV_06 | Sıcaklık | Evaporatör | | |
| 7 | T_CO_01 | Sıcaklık | Kondenser | | |
| 8 | T_CO_02 | Sıcaklık | Kondenser | | |
| 9 | T_CO_03 | Sıcaklık | Kondenser | | |
| 10 | T_CO_04 | Sıcaklık | Kondenser | | |
| 11 | T_CO_05 | Sıcaklık | Kondenser | | |
| 12 | T_CO_06 | Sıcaklık | Kondenser | | |
| 13 | P_EV | Basınç | Evaporatör | Dijital | Bağlantı tipi belirsiz |
| 14 | P_CO | Basınç | Kondenser | Dijital | Bağlantı tipi belirsiz |
| 15–20 | – | Yedek | – | – | Ortam sıcaklığı, test yüzeyi, ısıtıcı akım/gerilimi için kullanılabilir |

> Basınç sensörleri RS-485/Modbus veya seri port üzerinden haberleşiyorsa analog kanal kullanmazlar; bu durumda 13–14 numaralı kanallar da yedeğe geçer.

## Önerilen ek ölçümler (yedek kanallar için)

- **T_AMB** – ortam sıcaklığı
- **T_SURF_xx** – soğuk test yüzeyi sıcaklıkları
- **Isıtıcı gücü** – akım ve gerilim ölçümü. Termal direnç hesabı için uygulanan ısı yükünün bilinmesi gerekir.

## Çıkışlar (kontrol)

| Çıkış | Aktüatör | Kontrol şekli | Not |
|---|---|---|---|
| OUT_HEATER | Isıtıcı | Açma-kapama / PWM / analog | Cihazda çıkış olup olmadığı belirsiz |
| OUT_FAN_xx | Fan(lar) | PWM / analog / röle | Fan sayısı belirsiz |
| – | Stewart Platformu | UDP üzerinden Simulink'e | Bkz. labview-simulink-haberlesme.md |

## Etiketleme kuralı

`<büyüklük>_<bölge>_<sıra>`

- Büyüklük: `T` sıcaklık, `P` basınç
- Bölge: `EV` evaporatör, `CO` kondenser, `SURF` test yüzeyi, `AMB` ortam
- Sıra: iki haneli numara

Aynı etiketler LabVIEW kanal isimlerinde, kayıt dosyası sütun başlıklarında ve Origin'de kullanılmalıdır.
