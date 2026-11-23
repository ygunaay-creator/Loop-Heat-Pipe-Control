# Yol Haritası (kontrol ve veri toplama)

Hocanın iş adımlarıyla ilişkisi: [gorevler.md](gorevler.md)

## Aşama 0 – Hazırlık ✓
- [x] Ekipmanların belirlenmesi ([ekipman.md](ekipman.md))
- [x] Yazılım kararı: **MATLAB** (LabVIEW yerine)
- [x] Termokupl kararı: **23 × T tipi** (9 evaporatör + 9 kondenser + 5 dış)
- [x] MATLAB Instrument Control Toolbox kurulumu
- [x] GW Instek USB sürücüsü kurulumu

## Aşama 1 – Cihazlarla haberleşme
- [x] GPP-3323: USB, `serialport`, `*IDN?` (6 Kasım 2026)
- [x] EDU36311A: USB, `visadev`, `*IDN?` (6 Kasım 2026)
- [x] Isıtıcı direncinin ölçülmesi: ≈ 5,33 Ω
- [x] Isıtıcıyı farklı güçlerde çalıştırma (en fazla ≈ 48 W)
- [x] Fanı EDU36311A CH2'den 12 V ile çalıştırma
- [x] Peltier (TEC1-12715) kısa ısıtma testi
- [ ] Yeni veri toplama cihazının modelini teyit etmek ve MATLAB'dan okumak
- [ ] N5765A: AC bağlantısı, ilk açılış, MATLAB'dan `*IDN?`
- [ ] Huber CC-415: uzaktan kontrol komut setini edinmek

## Aşama 2 – Ölçüm ve kayıt
- [ ] 23 termokuplu yeni DAQ'tan okumak
- [ ] Basınç sensörlerini 24 V döngüyle okumak ve bar'a ölçeklemek
- [ ] Tüm cihazları tek zaman ekseninde CSV'ye kaydeden ana betik ([veri-formati.md](veri-formati.md))
- [ ] Canlı grafik (MATLAB figure, `animatedline`)

## Aşama 3 – Doğrulama ve kalibrasyon
- [ ] Termokuplları buz noktasında (0 °C) kalibre etmek
- [ ] Basit ısıtma deneyi: ısıtıcı + blok + fan, güç ve sıcaklık birlikte kayıt

## Aşama 4 – Kontrol ve güvenlik
- [x] Isıtıcı sabit gerilim ve güç basamakları (betik)
- [ ] Sabit güç modu (V·I geri beslemesi, sıcaklıkla direnç değişimini telafi eder)
- [x] Sıcaklık hedefli PI: MATLAB betiği ve Simulink modeli (sanal düzenekte)
- [x] TUSAŞ koşullarına göre senaryo: −10 °C, 13,4 dk bulut, yüzey hedefi +5 °C ([tusas-buzlanma-kosullari.md](tusas-buzlanma-kosullari.md))
- [ ] Simulink modelinde sanal düzenek yerine gerçek ısıtıcı (GPP-3323) ve sensör okuma
- [ ] Gerçek düzenekte `C_ev`, `C_yuzey`, `R_lhp` ölçüp modeli güncellemek
- [ ] Fan kontrolü (kondenser sıcaklığına göre)
- [ ] Sıcaklık ve $dT/dt$ limitleri, otomatik ısıtıcı kapatma
- [ ] Otomatik deney senaryoları (ör. 10–35–60–100 W basamakları)

## Aşama 5 – Stewart Platformu entegrasyonu
- [ ] Simulink modelini ve çalıştığı ortamı öğrenmek
- [ ] MATLAB ↔ Simulink UDP haberleşmesini platform olmadan test etmek ([matlab-simulink-haberlesme.md](matlab-simulink-haberlesme.md))
- [ ] Hareket profillerini MATLAB'dan göndermek
- [ ] Platform durumunu sensör verileriyle birlikte kaydetmek

## Aşama 6 – Gerçek sisteme entegrasyon
- [ ] İTÜ'deki LHP düzeneğine bağlanmak, ön testler (adım 6)
- [ ] Sabit konum ve parametrik deneyler (adım 7–8)
- [ ] Türk-Alman Üniversitesi'nde dinamik testler (adım 9)
- [ ] Analiz, belirsizlik ve raporlama (adım 10)
