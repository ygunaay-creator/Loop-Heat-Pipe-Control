# Proje Görevleri

Danışman hocanın paylaştığı iş adımları ve bunların **kontrol ve veri toplama ekibiyle (Yiğit, Alper)** ilişkisi.

İlgi düzeyi: **●** doğrudan bizim işimiz · **◐** bizim altyapımızı kullanır / katkı veririz · **○** diğer ekip / mekanik-termal taraf

## 1. Literatür taraması ve ön hazırlık ○
- LHP'nin çalışma prensibi: evaporatör, kondenser, gözenekli yapı (wick), kılcal pompalama, çalışma akışkanı
- Uçaklarda buz önleme yöntemleri ve LHP ile atık ısı kullanımı üzerine çalışmalar
- Hedef değerler: test yüzeyinin buz oluşumunu önleyecek sıcaklık seviyesi, ısı girdisi aralığı, ortam sıcaklıkları

*Bizim için:* Hedef değerler, kontrol limitlerini ve ısıtıcı güç aralığını belirler.

## 2. Deney düzeneğinin tasarımı ◐
- Modüler düzeneğin şeması: ısı kaynağı, LHP, test yüzeyi, sensörler, veri toplama
- LHP seçimi veya temini, akışkan tipi ve boyutlar
- Basitleştirilmiş geometrik model (kanat hücum kenarını temsil eden test yüzeyi)
- Test yüzeyinin soğutma yöntemi → **Huber CC-415 soğutucu**

*Bizim için:* Sensör ve veri toplama kısmı şemaya eklenecek ([sistem-mimarisi.md](sistem-mimarisi.md)).

## 3. Isı kaynağının kurulması ●
- Elektrikli ısıtıcının evaporatöre termal olarak bağlanması
- Farklı seviyelerde kontrollü ısı girdisi → **GPP-3323 + LabVIEW ile sabit güç kontrolü, V·I ile güç ölçümü**

## 4. Kondenser ile test yüzeyinin entegrasyonu ◐
- Kondenserin soğuk test yüzeyine termal entegrasyonu (termal macun, kelepçe vb.)
- Soğutma sisteminin kurulması ve test yüzeyini düşük sıcaklığa getirebildiğinin doğrulanması
- Isı kaybına karşı yalıtım

*Bizim için:* Soğutucunun LabVIEW'dan kontrolü ve test yüzeyi sıcaklıklarının izlenmesi.

## 5. Ölçüm ve veri toplama sistemi ●
- Termokupl yerlerinin planlanması: evaporatör, buhar ve sıvı hatları, kondenser, test yüzeyi → [kanal-plani.md](kanal-plani.md)
- Termokuplların yerleştirilmesi ve kalibrasyonu
- Çok kanallı veri toplama sisteminin kurulması ve eş zamanlı kayıt → **DAQ973A + LabVIEW**

## 6. Ön testler ve doğrulama ●
- Sızdırmazlık, sensör okumaları ve soğutma kapasitesi kontrolü
- Düşük güçte ilk çalıştırma ve kararlı çalışmanın doğrulanması

## 7. Sabit konumda deneyler ◐
- Başlangıç (start-up) davranışı
- Farklı ısı girdilerinde kararlı hal sıcaklıkları
- Termal direnç: **R = (T_evap − T_kond) / Q**
- Test yüzeyindeki sıcaklık dağılımı

## 8. Parametrik deneyler ◐
- Isı girdisi
- Ortam ve test yüzeyi sıcaklığı
- Sistem yerleşimi (eğim, evaporatör–kondenser konumu)

*Bizim için:* Deney senaryolarının LabVIEW'dan otomatik çalıştırılması (ör. güç basamakları).

## 9. Stewart Platformu üzerinde dinamik testler ●
- Düzeneğin platforma taşınabilir hale getirilmesi: kablolama, sabitleme, veri toplama
- Açısal hareketler: eğim, salınım, uçuş manevrası benzetimi → **LabVIEW ↔ Simulink (UDP)**
- Hareketlerin termal performansa etkisinin ölçülmesi

## 10. Veri analizi ve değerlendirme ●
- Grafikler ve **belirsizlik analizi** → Origin
- Test yüzeyinin buz önleme için gereken sıcaklıkta tutulup tutulamadığının değerlendirilmesi
- LHP'nin buz önleme amacıyla kullanılabilirliği hakkında ön sonuç

Belirsizlik kaynakları: [veri-formati.md](veri-formati.md#belirsizlik)
