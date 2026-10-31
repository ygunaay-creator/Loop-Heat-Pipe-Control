# Literatür

Projeyle doğrudan ilgili yayınlar. Makalelerin PDF'leri telif hakkıyla korunduğu (Elsevier, "All rights reserved") ve bu repo herkese açık olduğu için **PDF'ler repoya konmaz**. Ortak sürücüde `literatur/` klasöründe tutulur. Buradan DOI bağlantısıyla erişilebilir.

## 1. LHP ile uçak buz önleme

**Zhao, Y., Chang, S., Yang, B., Zhang, W., Leng, M. (2017).** Experimental study on the thermal performance of loop heat pipe for the aircraft anti-icing system. *International Journal of Heat and Mass Transfer*, 111, 795–803.
DOI: [10.1016/j.ijheatmasstransfer.2017.04.009](https://doi.org/10.1016/j.ijheatmasstransfer.2017.04.009)

- Çift kompansasyon odalı LHP (DCCLHP), paslanmaz çelik gövde, nikel fitil, çalışma akışkanı etanol.
- Isı yükü 10–180 W, hücum açısı (AOA) değiştirilerek test edilmiş.
- Bulgular: Sistem, aşırı soğumuş damlacıklı buluta girmeden yaklaşık 10 dakika önce açılmalı. AOA 0° değilken başlangıçta sıcaklık salınımları görülüyor. Pozitif AOA yüzey sıcaklığını ve buz önleme etkisini artırıyor.
- **Projeye katkısı:** Kurduğumuz düzeneğe en yakın çalışma. Güç aralığı (≤ 200 W) GPP-3323 ile aynı mertebede. Eğim etkisi Stewart Platformu testleriyle doğrudan karşılaştırılabilir. Başlangıç süresi ve salınımlar, alarm limitlerinin seçiminde dikkate alınmalı.

## 2. Yönelimin (eğimin) LHP performansına etkisi

**Wang, H., Lin, G., Guo, Y., Zhao, W., Bai, L. (2024).** Experimental study of a high-capacity dual compensation chamber loop heat pipe at different orientations. *International Journal of Thermal Sciences*, 202, 109051.
DOI: [10.1016/j.ijthermalsci.2024.109051](https://doi.org/10.1016/j.ijthermalsci.2024.109051)

- kW sınıfı DCCLHP, farklı yönelimlerde kararlı hal ve başlangıç performansı.
- Bulgular: Yönelime göre kondenser performansındaki değişim belirleyici. Isı transfer sınırı %50'ye kadar düşebiliyor veya %10 artabiliyor. Yerçekimi, kondenserdeki yoğuşma filminin kalınlığını değiştirerek kondenser kapasitesini ve CC'ye giren sıvının sıcaklığını etkiliyor. Yoğuşan sıvının yerçekimine karşı aktığı yönelimlerden kaçınılmalı.
- Çalışma sıcaklığını analiz etmek için bir yöntem öneriyor.
- **Projeye katkısı:** Platform testlerinde yalnızca evaporatör–kondenser yükseklik farkının değil, **kondenserin kendi yöneliminin** de izlenmesi gerektiğini gösteriyor. T_CO_01–03 ve T_LL_IN verileri bu açıdan değerlendirilmeli.

## 3. Yüksek kapasiteli LHP tasarımı ve ısı sızıntısı

**Wang, H., Lin, G., Qin, H., Zhang, R., Bai, L., Guo, Y. (2023).** Design and experimental validation of a high capacity loop heat pipe for avionics cooling. *Thermal Science and Engineering Progress*, 45, 102139.
DOI: [10.1016/j.tsep.2023.102139](https://doi.org/10.1016/j.tsep.2023.102139)

- kW sınıfı LHP'nin uçtan uca tasarım süreci ve tasarım kriterleri. Akışkan amonyak, gövde paslanmaz çelik, fitil nikel.
- Bulgular: 20 °C ısı kuyusunda en fazla 1021 W, evaporatörde ortalama 12,04 W/cm². Termal direnç ~50 W'ta 0,16 °C/W (en yüksek), ~600 W'ta 0,054 °C/W (en düşük). Sıcaklık dalgalanması ±1,40 °C'nin altında.
- Evaporatör–CC arasındaki **ısı sızıntısını tahmin etmek için bir yöntem** geliştiriyor. En yüksek sızıntı oranı yaklaşık %5,2.
- **Projeye katkısı:** Termal direncin (R = ΔT/Q) düşük güçte yüksek, yüksek güçte düşük çıkması, değişken/sabit iletkenlik rejimleri için referans eğri. Isı sızıntısı yöntemi, T_CC ve T_EV verileriyle bizim düzenekte de uygulanabilir. Amonyak kullanılırsa basınç sensörü aralığının yeniden seçilmesi gerektiğini de hatırlatıyor (bkz. [acik-sorular.md](acik-sorular.md)).
