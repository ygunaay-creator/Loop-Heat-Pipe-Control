# Literatür Özeti: Uçak Uygulamalarında Loop Heat Pipe

> Bu belge, projeyle doğrudan ilgili üç deneysel makalenin özetidir. Amaç makaleleri baştan sona okumadan **düzeneğimizi, ölçümlerimizi ve deney planımızı etkileyen bilgileri** tek yerde toplamaktır.
>
> Makalelerin PDF'leri telif hakkıyla korunduğu (Elsevier, "All rights reserved") ve bu repo herkese açık olduğu için repoya konmaz. DOI bağlantıları en altta, PDF'ler ortak sürücüde.

**İçindekiler**

1. [Üç makaleye kısa bakış](#1-üç-makaleye-kısa-bakış)
2. [Zhao vd. 2017: LHP ile kanat buz önleme](#2-zhao-vd-2017-lhp-ile-kanat-buz-önleme)
3. [Wang vd. 2023: kW sınıfı LHP tasarımı](#3-wang-vd-2023-kw-sınıfı-lhp-tasarımı)
4. [Wang vd. 2024: yönelimin etkisi](#4-wang-vd-2024-yönelimin-etkisi)
5. [Projemize çıkarımlar](#5-projemize-çıkarımlar)
6. [Formül kartı](#6-formül-kartı)
7. [Açık sorulara eklenecekler](#7-açık-sorulara-eklenecekler)
8. [Kaynaklar](#8-kaynaklar)

---

## 1. Üç makaleye kısa bakış

Üç çalışma da Beihang Üniversitesi'nden (Pekin) ve hepsi **çift kompansasyon odalı LHP (DCCLHP)** kullanıyor. DCCLHP'de evaporatörün iki ucunda birer kompansasyon odası (CC1, CC2) bulunur. Böylece hangi yöne eğilirse eğilsin fitile sıvı ulaşır. Uçakta yönelim sürekli değiştiği için tercih edilen yapı budur.

Wang 2023 ve Wang 2024 **aynı LHP'yi** kullanıyor (boyutlar birebir aynı). 2023 makalesi tasarımı ve yatay konumdaki performansı, 2024 makalesi ise farklı yönelimlerdeki davranışı anlatıyor.

| | Zhao 2017 | Wang 2023 | Wang 2024 |
|---|---|---|---|
| Uygulama | Kanat buz önleme | Aviyonik soğutma | Aviyonik soğutma |
| Akışkan | Etanol | Amonyak | Amonyak |
| Gövde / fitil | Paslanmaz çelik / nikel | Paslanmaz çelik / nikel | Paslanmaz çelik / nikel |
| Isı yükü | 10–180 W | 50–1021 W | 50–~1100 W |
| Isıtıcı | İnce film ısıtıcı, AC | 2 kartuş ısıtıcı, DC programlanabilir kaynak | Aynı |
| Isı kuyusu | Rüzgâr tüneli, kanat yüzeyi (NACA 0012) | 20 °C su, 3,6 L/dk, kriyostat | Aynı |
| Yönelim | Hücum açısı 0°, ±5°, 10° | Yatay | φ, θ: −90°…+90°, 45° adımla |
| Termokupl | T tipi, ±0,5 °C | T tipi, ±0,46 °C (kalibre) | Aynı |
| DAQ | Agilent 34972A, 20 s | Keysight 34970A + 2×34901A, 10 s | Aynı |

Bizim düzenekle karşılaştırma: Güç aralığımız (GPP-3323 ile ≤ ~190 W) **Zhao 2017 ile aynı mertebede**. Ölçüm altyapımız ise Wang çalışmalarının bir üst sürümü (DAQ973A, 34970A'nın halefi). Isı kuyusu olarak Wang'lardaki gibi bir sirkülatör (Huber) kullanıyoruz.

---

## 2. Zhao vd. 2017: LHP ile kanat buz önleme

### 2.1 Düzenek

- **Evaporatör:** Dış/iç çap 52/45 mm, uzunluk 120 mm. 11 buhar oluğu (1×1 mm).
- **Fitil:** Nikel. Gözenek yarıçapı 1,2 µm, gözeneklilik %48, geçirgenlik 2,3×10⁻¹⁴ m².
- **Kompansasyon odaları:** CC1 ve CC2, her biri 59,5 ml. Akışkan doluluk oranı %62,5.
- **Hatlar ve kondenser:** Buhar hattı, sıvı hattı ve kondenser 3/2 mm çapında, her biri 500 mm boru.
- **Kondenser yerleşimi:** Kondenser borusu NACA 0012 kanat profilinin içinden, kanat derisine temas edecek şekilde geçiyor (veter 375 mm). Boru ile deri arasında ısıl silikon jel var. Kanadın iç tarafı yalıtılmış, böylece ısının tamamı deriye gidiyor.
- **Yüzey ölçümü:** Veter boyunca 20 mm arayla 7 adet T tipi termokupl. 6 numaralı nokta durma noktası.
- **Hatların yalıtımı:** İçte nano seramik kaplama (k = 0,0012 W/m·K), dışta seramik elyaf kâğıt.
- **Deney koşulları:** Rüzgâr hızı 0–30,9 m/s. Isı yükü 10, 35, 60, 100, 180 W. Hücum açısı (AOA) 0°, ±5°, 10°. Pozitif AOA'da CC1 yukarıda.

### 2.2 Başlangıç (start-up)

**Tanım.** Başlangıç süresi, ısıtıcının açıldığı andan **kondenser giriş sıcaklığının yükselmeye başladığı ana** kadar geçen süredir.

**Seyir.** İlk 1–2 dakikada evaporatör çıkışı yavaş ısınır. Bu bir ön ısıtma evresidir: ısı, akışkanı oda sıcaklığından buharlaşma sıcaklığına çıkarmaya harcanır. Ardından buhar, buhar hattındaki sıvıyı itip kondensere ulaşır. 100 W ve 11,7 m/s'de bu süreç **yaklaşık 10 dakika** sürüyor.

> Makalenin ana pratik sonucu: Sistem, aşırı soğumuş damlacık içeren buluta girmeden **yaklaşık 10 dakika önce** açılmalı.

**Hücum açısının etkisi:**
- En kısa başlangıç süresi AOA = 0°'de.
- Açılar arasındaki en büyük başlangıç süresi farkı 10 W'ta **21,5 dakika**. 180 W'ta bu fark **2,75 dakikaya** iniyor. Yani düşük güçte yönelimin etkisi çok daha büyük.
- AOA ≠ 0° iken evaporatör çıkışında, kondenser girişinde ve sıvı hattı çıkışında **büyük sıcaklık salınımları** oluşuyor. Sebebi, buharın yukarıda kalan CC'ye kaçıp orada birikmesi. Yukarıdaki CC belirgin şekilde daha sıcak çıkıyor (100 W'ta bir örnekte 91,1 °C'ye karşı 66,2 °C).

**Güç ve rüzgârın etkisi:**
- Güç arttıkça başlangıç kısalıyor.
- Rüzgâr hızı arttıkça başlangıç uzuyor: kondenserden dönen sıvı daha soğuk geliyor ve evaporatörü soğutuyor.

### 2.3 Kanat yüzey sıcaklığı

- Kondenser girişine yakın nokta **en sıcak**, çünkü burada buhar henüz yoğuşmamış.
- Durma noktası **en soğuk**. Burada sınır tabaka çok ince olduğu için taşınım katsayısı yüksek.
- Pozitif AOA'da yüzey daha sıcak çıkıyor. Bu yüzden öneri şu: Uçuşta AOA genelde pozitif olduğu için **evaporatör çıkışı yukarıda kalacak şekilde** montaj yapılmalı.

### 2.4 Termal direnç

Tanım:

$$R = \frac{T_{e,out} - \tfrac{1}{2}(T_{cond,in} + T_{cond,out})}{Q}$$

- Güç arttıkça R önce hızla düşüyor, **100 W'ın üstünde sabitleniyor**. Düşük güçte kondenser tamamen aktif değil (değişken iletkenlik bölgesi). Yüksek güçte tamamen aktif (sabit iletkenlik bölgesi).
- En düşük R, AOA = 0°'de. Açı R'yi artırıyor ama artış büyük değil.
- Belirsizlikler: Q için %7,44 (AC kaynağı, sınıf 1,5). R için %7,84. Bizim GPP-3323 geri okumasıyla Q belirsizliği bunun çok altında kalacak.

---

## 3. Wang vd. 2023: kW sınıfı LHP tasarımı

### 3.1 Akışkan seçimi için ölçütler

Bu bölüm, bizim henüz kararlaştırmadığımız akışkan seçimine doğrudan uygulanabilir.

1. **Sıcaklık aralığı:** Çalışma sıcaklığı üçlü nokta ile kritik nokta arasında kalmalı: $T_{üçlü} < T < T_{kritik}$. Aviyonik için −40…+85 °C alınmış.
2. **Isı taşıma potansiyeli ("figure of merit"):** Bu ölçütle amonyak ve su öne çıkıyor.
   - Buhar akışı baskınken: $FM_v = \rho_v \sigma_l h_{lv}^{1.75} / \mu_v^{0.25}$
   - Sıvı akışı baskınken: $FM_l = \rho_l \sigma_l h_{lv} / \mu_l$
3. **İvmeye ve eğime dayanıklılık:**
   - $\sigma_l/(\rho_l-\rho_v)$: Kılcal kuvvetin yerçekimi direncine oranıyla orantılıdır. En iyi değer suda.
   - $P_{sat}/(\rho_l-\rho_v)$: Yüksek doyma basıncı avantajdır. Amonyak ve bazı freonlar öne çıkıyor.
   - $dP/dT$ (doyma eğrisinin eğimi): Büyük olması ivme kaynaklı basınç kaybının etkisini azaltır ve başlangıcı kolaylaştırır. En büyük değer amonyakta.
4. **Malzeme uyumu:** Akışkan gövde ve fitille tepkimeye girerse **yoğuşmayan gaz (NCG)** oluşur. Bu da performans kaybına, başlangıç zorluğuna ve ömür kısalmasına yol açar.

Sonuç: Aviyonik soğutma için **amonyak** seçilmiş. Ama makale, amonyağın yüksek basıncı ve zehirliliği nedeniyle dikkatle kullanılması gerektiğini de vurguluyor.

Zhao 2017 ise buz önleme için **etanol** kullanmış ve su ile alkollerin önerildiği önceki çalışmalara (Gregori vd. 2007) dayanmış. Yani **buz önleme uygulamasında amonyak tek seçenek değil**.

### 3.2 Tasarım ve boyutlar

| Bileşen | Değer |
|---|---|
| Evaporatör gövdesi | Ø18/16 mm × 200 mm |
| Fitil | Ø16/6 mm × 160 mm. En büyük gözenek 1,06 µm, gözeneklilik ~%50, geçirgenlik ~3,7×10⁻¹⁵ m² |
| Buhar olukları | 22 adet, 1×1×150 mm |
| Buhar hattı | Ø6/4 mm × 450 mm |
| Sıvı hattı | Ø3/2 mm × 585 mm |
| Kondenser | 15 mm çelik plakada 6 paralel kanal (3×1 mm). Soğutucu kanalı yılan biçimli, 20×10 mm |
| CC | 2 adet, Ø32/30 mm × 40 mm |
| Bayonet | Ø3/2 mm × 275 mm, CC1'in içine uzatılmış (başlangıcı iyileştirmek için) |
| Akışkan miktarı | 46,6 g amonyak |

Tasarım ilkeleri:
- **Ana direnç fitilde olmalı.** Bu tasarımda 55 °C'de toplam akış direncinin %94'ten fazlası fitilde, hatlar ve kondenserdeki kayıp küçük. Bu sayede hat uzunluğu ve yerleşimi değiştiğinde performans pek etkilenmiyor.
- **Hatlarda esneklik ile direnç dengesi:** Büyük çap direnci düşürür ama esnekliği azaltır. Önerilen çözüm küçük çaplı boruları paralel kullanmak.

### 3.3 Isı transfer limitleri

LHP'de dört limit dikkate alınır. Klasik ısı borusundaki sürüklenme (entrainment), kaynama ve süreklilik limitleri LHP'de genelde önemsizdir.

| Limit | Ne zaman devreye girer |
|---|---|
| **Kılcal** | Toplam akış direnci + yerçekimi/ivme direnci, en büyük kılcal basıncı ($2\sigma/r_p$) aştığında |
| **Viskoz** | Döngüdeki en düşük basınç, ısı kuyusu sıcaklığındaki doyma basıncının altına inemeyeceği için |
| **Ses hızı** | Buhar hızı yerel ses hızına yaklaştığında (Mach < 1 olmalı) |
| **Yoğuşma** | Kondenser, gelen ısıyı ısı kuyusuna aktaramadığında |

Bu LHP için 20–70 °C aralığında belirleyici limitler **yoğuşma ve kılcal limit**. Teorik en büyük kapasite 44 °C'de ~1153 W. **8 g ters ivmede** kapasitenin %20–30 düşeceği tahmin edilmiş.

### 3.4 Deney sonuçları (yatay konum)

- **Kapasite:** En fazla **1021 W**, evaporatörde ortalama ısı akısı 12,04 W/cm². Tasarım tahmini (~1045 W) ile fark yalnızca %2,4.
- **Limit anındaki sıcaklıklar:** Isıtıcı eyer yüzeyi 88,8 °C, evaporatör çıkışı 52,6 °C.
- **Termal direnç** güç arttıkça önce düşüp sonra hafifçe artıyor:

| Isı yükü | R (°C/W) |
|---|---|
| ~50 W | 0,16 (en yüksek) |
| ~600 W | 0,054 (en düşük) |
| 1021 W | 0,067 |

  Açıklaması: Düşük güçte kondenserin yalnızca bir kısmı kullanılıyor. Güç arttıkça kullanılan kısım büyüyor ve R düşüyor. CC'ler tamamen dolduktan sonra CC'deki sıvı ısınıp genleşiyor, kondenserin bir kısmını geri dolduruyor ve R biraz yükseliyor.
- **Salınım:** ~300 W'ın üstünde sıcaklık salınımları başlıyor ve güçle büyüyor. ~1000 W'ta eyer yüzeyinde ±1,40 °C, buharda ±0,45 °C.
- **Başlangıç:** 50 W'tan itibaren tüm güçlerde yumuşak, **aşırı ısınma (overshoot) yok**.
- **Dinamik test:** 107 → 518 → 1030 → 520 → 106 → 1030 → 106 W basamaklarında kararlı. Aynı güçte her seferinde aynı sıcaklığa dönüyor.

### 3.5 Isı sızıntısı hesabı (bizde de uygulanabilir)

Evaporatörden CC'ye geçen ısı (sızıntı), CC'ye dönen soğuk sıvıyı ısıtmaya harcanır. Kararlı halde enerji dengesi şu ilişkiyi verir:

$$Q_{leak} = Q \left(1 + \frac{h_{lv}}{c_{p,l}\,(\bar T_{CC} - T_{CC,in})}\right)^{-1}$$

Terimler:
- $\bar T_{CC}$: CC'lerin ortalama sıcaklığı, $(T_{CC1}+T_{CC2})/2$
- $T_{CC,in}$: CC'ye giren sıvının sıcaklığı
- $h_{lv}$: Evaporatör çıkış sıcaklığında gizli ısı
- $c_{p,l}$: $\bar T_{CC}$ ile $T_{CC,in}$ ortalamasında sıvının özgül ısısı

Sonuç: Sızıntı %1,5–5,2 arasında, en yüksek güçte ~50 W. **Yalnızca termokupl verisiyle hesaplanabilmesi** bizim için önemli.

### 3.6 Ölçüm ve hazırlık pratikleri

- Termokupllar buzlu su ve gazyağında kalibre edilmiş: 4–160 °C'de ±0,46 °C.
- Isıtıcı–evaporatör bağlantısında alüminyum eyer ve ısıl macun (7 W/m·K) kullanılmış.
- Hatlar 10 mm kauçuk köpükle yalıtılmış (k = 0,034 W/m·K). Ortam klimayla 20–25 °C'de tutulmuş.
- Soğutucu debisi bir debimetreyle ölçülmüş (±%2).
- **Gaz alma:** Dolumdan önce LHP ~100 °C'ye ısıtılıp 0,5 Pa'ya kadar vakumlanmış. Amaç NCG'yi kontrol altında tutmak.

---

## 4. Wang vd. 2024: yönelimin etkisi

### 4.1 Yönelimin tanımı

İki dönme açısı kullanılıyor:

- **φ (evaporatör ekseni etrafında):** Evaporatör–CC grubunun kondensere göre **yüksekliğini** değiştirir. φ > 0'da evaporatör yukarıda, φ < 0'da aşağıda.
- **θ (φ kadar döndürülmüş Y ekseni etrafında):** CC1 ile CC2'nin göreli yüksekliğini ve **kondenser içindeki akışın yerçekimine göre yönünü** değiştirir.
  - θ > 0: CC2 yukarıda, kondenserde akış **yerçekimine karşı**.
  - θ < 0: CC1 yukarıda, kondenserde akış **yerçekimi yönünde**.
- **Döndürme sırası önemli:** Önce φ, sonra θ. φ = ±90°'de θ'nın anlamı kalmıyor.

Deney: Tutucu 45° adımla ayarlanıyor, hata ±1,5°. Prosedür: Önce ~50 W, sonra ~100 W, ardından 100 W'lık basamaklarla çıkılıyor. Evaporatör çıkışı **70 °C'yi** aşınca (izin verilen sınır) deney sonlandırılıyor.

### 4.2 Temel bulgu: belirleyici olan kondenser

Beklenti, evaporatör kondenserin üstündeyken sıvının yukarı pompalanması gerektiği için performansın düşmesiydi. Sonuçlar bunun **ötesinde** bir şey gösteriyor:

**φ ≠ 0 için:**
- Kapasite ~920 W'a düşüyor (−%10). φ = −45°'de kapasite neredeyse aynı (1020 W), ama buhar 6,7 °C daha sıcak.
- En düşük R, referansta 0,0542 °C/W iken φ ≠ 0'da 0,061–0,065 °C/W.
- Isı sızıntısı **artmıyor**, hatta bazen azalıyor. Buna karşılık CC'ye giren sıvı belirgin şekilde **daha sıcak**.
- Kondenser termal direnci **%27–164 artıyor**.

**Mekanizma:**
- Kondenser kanalındaki Bond sayısı 0,6–1,0 aralığında. $0,05 < Bo < 3$ olduğu için yoğuşmada **hem yüzey gerilimi hem yerçekimi** etkili.
- Kondenser dikleştiğinde yoğuşan sıvı alt kanallarda birikiyor. Sıvı filmi kalınlaşıyor ve yoğuşma zayıflıyor.
- Bu tıkanma için büyük açı gerekmiyor. **Etki 45°'de neredeyse doyuyor**, 90°'ye çıkmak pek bir şey değiştirmiyor.

**θ için:**

| Durum | Sonuç |
|---|---|
| θ < 0 (akış yerçekimi yönünde) | Kapasite ~1100 W (**+%10**). 200 W'ın üstünde R referansla neredeyse aynı (en düşük 0,0518 °C/W). Düşük güçte (50 W) buhar 2,3–6,6 °C daha sıcak, çünkü CC1'in yukarıda olması düşük güçte olumsuz. |
| θ > 0 (akış yerçekimine karşı) | 200 W'ın üstünde **12–26 °C daha sıcak**. Kapasite ~600 W'a iniyor (**−%40**). R 0,084–0,088 °C/W (%50'den fazla yüksek). Kondenser direnci bazı güçlerde **%300'ü aşıyor**. Buharın bir kısmı yoğuşmadan CC'ye ulaşıyor. |

**Karma yönelimler (φ ≠ 0 ve θ ≠ 0):** Sonuçlar iki gruba ayrılıyor.
- **Grup I** (kondenserde akış yerçekimi yönünde): Kapasite > 1000 W, sıcaklıklar referansa yakın.
- **Grup II** (akış yerçekimine karşı): Kapasite referansın yalnızca %50–60'ı, buhar 10–20 °C daha sıcak.

> **Makalenin ana mesajı:** Yüksek kapasiteli DCCLHP'de performansı büyük ölçüde **kondenserdeki akışın yerçekimiyle aynı yönde olup olmaması** belirliyor. Kondenser, yoğuşan sıvının yerçekimine (veya ivmeye) karşı akmayacağı şekilde monte edilmeli.

Burada bir sınırlama var. Bu sonuçlar **~1 kW'lık amonyak LHP'si** için geçerli. Bizim güç aralığımızda (≤ 200 W) kondenser büyük olasılıkla tam dolmayacak ve LHP değişken iletkenlik bölgesinde çalışacak. Orada evaporatör–CC yönelimi de (Zhao 2017'deki gibi) önemli bir etken olarak kalır.

### 4.3 Yönelim ve başlangıç (50 W)

- Tüm yönelimlerde başlangıç başarılı ve çoğunlukla yumuşak.
- φ = −45°'de ~2 °C aşırı ısınma ve ±1 °C salınım görülüyor.
- θ > 0'da kondenser çıkışında salınımlar oluyor ve bu buhar sıcaklığını da dalgalandırıyor. Yani zayıflamış kondenser başlangıcı da olumsuz etkileyebiliyor.
- Aşırı ısınma düşük güçte daha belirgindir. Sebebi, CC'ye dönen aşırı soğumuş sıvının debisinin küçük olması ve sızıntıyı dengeleyememesi.

### 4.4 Evaporatör çıkış sıcaklığı modeli

Kararlı halde buhar sıcaklığı yaklaşık olarak şöyle ifade edilmiş:

$$T_{eva,out} \approx T_{CC,in} + \frac{h_{lv}/c_{p,l}}{Q/Q_{leak} - 1} + Q_{leak}(R_{CC}+R_w) + \Delta T_{v,sh}$$

Pratik anlamı: Aynı güçte **evaporatör sıcaklığını esas olarak iki şey belirler**: CC'ye giren sıvının sıcaklığı ($T_{CC,in}$, yani kondenser performansı) ve ısı sızıntısı. Bir deneyde evaporatör ısınırsa, sebebin hangisi olduğunu bu iki büyüklüğe bakarak ayırt edebiliriz.

---

## 5. Projemize çıkarımlar

Bu bölüm makalelerdeki bilgilerden **bizim türettiğimiz önerilerdir**. Hocayla ve ekiple tartışılmalı.

### 5.1 Akışkan seçimi ve basınç sensörü aralığı

İki aday öne çıkıyor:

| | Etanol (Zhao 2017) | Amonyak (Wang 2023/2024) |
|---|---|---|
| Lehine | Düşük basınç, daha güvenli, buz önleme literatüründe önerilen | En yüksek kapasite ve ivme dayanıklılığı |
| Aleyhine | Isı taşıma potansiyeli daha düşük | Yüksek basınç, zehirli |
| Doyma basıncı | 20 °C'de ~0,06 bar, 78 °C'de ~1 bar (atmosfer altı) | 20 °C'de ~8,6 bar, 50 °C'de ~20 bar |

Mevcut DMS20S seçenekleri (1 / 2 / 4 bar mutlak) **etanol için uygun** (0–1 veya 0–2 bar). **Amonyak için hiçbiri yeterli değil**, en az 25 bar'lık bir sensör gerekir. Sensör sipariş edilmeden önce akışkan netleşmeli.

### 5.2 Termal direnç tanımını sabitleyelim

Makalelerde iki farklı tanım var. Sonuçlarımızı ikisiyle de karşılaştırabilmek için **üç direnci birlikte** hesaplamayı öneriyoruz. Yeni kanal gerekmiyor:

| Büyüklük | Bizim kanallarla formül | Karşılaştırma |
|---|---|---|
| Döngü direnci $R_{LHP}$ | $\big(T_{VL\_IN} - \tfrac{1}{2}(T_{VL\_OUT}+T_{LL\_IN})\big)/Q$ | Zhao 2017 |
| Toplam direnç $R_{tot}$ | $(T_{HTR} - T_{CH\_SUP})/Q$ | Wang 2023/2024 |
| Kondenser direnci $R_{cond}$ | $\big(\tfrac{1}{2}(T_{VL\_OUT}+T_{LL\_IN}) - T_{CH\_SUP}\big)/Q$ | Wang 2024 (yönelim etkisinin ana göstergesi) |

$Q$ = `HTR_P` (GPP-3323 geri okuması). Bu tanımlar [veri-formati.md](veri-formati.md) dosyasına işlenmeli.

**Beklenen mertebe:** Wang 2023'te 50 W'ta R = 0,16 °C/W idi. Bizim güç aralığımız düşük olduğu için **değişken iletkenlik bölgesinde** çalışacağız. Daha yüksek ve güçle hızla değişen R değerleri bekleriz. Zhao 2017'deki "100 W'ın üstünde sabitlenme" bizim için iyi bir referans noktası.

### 5.3 Isı sızıntısını hesaplayalım

Wang yöntemi (Bölüm 3.5) yalnızca termokupllarla çalışır. Bizim kanallarla:

- $T_{CC,in}$ → `T_LL_OUT` (sıvı hattı çıkışı = CC girişi). Termokupl **CC girişine olabildiğince yakın** yerleştirilmeli.
- $\bar T_{CC}$ → `T_CC` (LHP'miz çift CC'liyse iki CC'nin ortalaması).
- $h_{lv}$, $c_{p,l}$ → akışkan tablosundan (örn. CoolProp veya NIST). LabVIEW ya da Origin'de sıcaklığa bağlı fonksiyon olarak.

Bu hesap aynı zamanda bir **teşhis aracı** olur. Örneğin platform testinde evaporatör ısındığında sebebin sızıntı mı kondenser mi olduğunu söyler (Bölüm 4.4).

### 5.4 Kanal planına öneriler

1. **LHP çift CC'liyse** `T_CC` yerine `T_CC1` ve `T_CC2` gerekir. Zhao'da yukarıdaki CC, aşağıdakinden 40 °C'den fazla sıcak çıkabildi (94,3 °C'ye karşı 50,1 °C). Tek termokupl yanıltıcı olur. Boş kanal yoksa üç evaporatör termokuplundan biri (`T_EV_03`) bu amaçla kullanılabilir.
2. **Test yüzeyi termokuplları (`T_SURF_01…05`) kondenser akış yönü boyunca**, girişten çıkışa doğru sıralanmalı. Zhao'da yüzeyin en sıcak noktası kondenser girişi tarafıydı. Buz önlemede kritik olan **en soğuk nokta** olduğu için dağılımı görmek önemli.
3. **`T_HTR`**, Wang'lardaki eyer yüzeyi sıcaklığının karşılığıdır. Hem güvenlik limiti hem $R_{tot}$ için kullanılır. Isıtıcının **ortasına** yerleştirilmeli.
4. **Soğutucu debisi ölçülmeli.** Wang ±%2'lik bir debimetre kullanmış. Bu, "Soğutucu sıvının debisi ölçülecek mi?" açık sorusuna literatürden bir "evet" cevabı. Debi bilinirse $Q_c = \dot m c_p (T_{CH\_RET} - T_{CH\_SUP})$ ile enerji dengesi kurulabilir.

### 5.5 Deney prosedürüne öneriler

- **Güç basamakları:** Zhao'nun 10–35–60–100–180 W dizisi bizim aralığa doğrudan uyuyor. Karşılaştırma için aynı noktaları kullanmak mantıklı.
- **Sonlandırma kriteri:** Wang'lar evaporatör çıkışında 70 °C sınır kullanmış. Bizim sınır akışkana ve malzemeye göre belirlenmeli ve LabVIEW güvenlik döngüsüne girmeli.
- **Başlangıç süresinin otomatik ölçümü:** Zhao'nun tanımıyla, ısıtıcı açıldığı andan `T_VL_OUT`'un (kondenser girişi) belirgin şekilde yükselmeye başladığı ana kadar geçen süre. LabVIEW'da bir eğim eşiğiyle ($dT/dt$) otomatik işaretlenebilir.
- **Aşırı ısınma (overshoot) miktarı:** Başlangıçtaki en yüksek `T_EV` değerinden kararlı hal değerini çıkarmak. Her başlangıç testinde raporlanmalı.
- **Projeye özgü bir ölçüt önerisi, "buz önleme hazır olma süresi":** Isıtıcı açıldıktan sonra en soğuk `T_SURF` kanalının 0 °C'yi geçmesine kadar geçen süre. Zhao'daki "10 dakika önceden açın" sonucunun bizim düzenekteki karşılığı olur.
- **Kararlı hal kriteri:** Makalelerde sayısal bir kriter verilmemiş. Bizim önerimiz örneğin "tüm sıcaklıklarda 5 dakikada 0,1 °C'den az değişim". Ekiple netleştirilmeli.

### 5.6 Stewart Platformu testleri

- **Ne test edebiliriz?** Platform eğimle yerçekiminin yönünü değiştirir ama sürekli yüksek g üretemez. Wang 2023'teki 8 g senaryosu bizim kapsamımızda değil. Testlerimiz **yönelim etkisini** temsil eder, kısa süreli ivmeler yalnızca dinamik hareketlerde oluşur.
- **Açıları iki ayrı etki olarak düşünün:**
  - Evaporatör–kondenser yükseklik farkını değiştiren açı (Wang'daki φ, Zhao'daki AOA)
  - Kondenserdeki akışın yerçekimine göre yönünü değiştiren açı (Wang'daki θ)

  Platformun roll/pitch eksenlerinin bu ikisine nasıl karşılık geldiği, **LHP'nin platforma montaj yönüne** bağlı. Montaj yapılmadan önce belgelenmeli.
- **Döndürme sırası:** Wang'da sıra önemliydi (önce φ, sonra θ). Simulink modelinin hangi Euler açısı sırasını kullandığı (örn. ZYX) öğrenilmeli ve LabVIEW'daki hareket profilleri buna göre tanımlanmalı.
- **Önerilen ilk test matrisi:** Etkinin 45°'de büyük ölçüde doyduğu biliniyor. Bu yüzden 0°, ±5°, ±10°, ±20°, ±45° gibi küçük açılara yoğunlaşan bir tarama, platformun hareket sınırlarına da uygun ve bilgi açısından en verimli seçenek olur. Kesin sınırlar platform verisi gelince belirlenmeli.
- **Montaj önerisi:** Gerçek uçuşta AOA çoğunlukla pozitif. Hem Zhao'ya (evaporatör çıkışı yukarıda) hem Wang'a (kondenser akışı yerçekimi yönünde) göre, düzenek **pozitif pitch'te kondenserdeki akış aşağı doğru olacak** şekilde kurulmalı.
- **Düşük güçte daha hassas:** Zhao'da yönelimin başlangıç süresine etkisi 10 W'ta 21,5 dakika, 180 W'ta 2,75 dakikaydı. Platform testleri **düşük güç noktalarını mutlaka içermeli**.

### 5.7 Örnekleme, salınımlar ve alarmlar

- Makaleler 10–20 s örnekleme kullanmış. Bizim 1 s'lik örneklememiz başlangıç geçişlerini ve salınımları (±0,5–1,5 °C mertebesinde) rahatça çözer.
- AOA ≠ 0° iken başlangıçtaki salınımlar ve ~2 °C'lik aşırı ısınmalar **normal davranış**. LabVIEW'daki alarm limitleri bunlarla tetiklenmeyecek, ama gerçek kuruma (dry-out) durumunu yakalayacak şekilde seçilmeli. Örneğin `T_HTR` için mutlak limit artı hızlı yükselme ($dT/dt$) limiti birlikte kullanılabilir.

### 5.8 Kalibrasyon ve yalıtım

- **Kalibrasyon:** Wang'lar termokuplları buzlu suda kalibre etmiş. Bizim kritik bölgemiz 0 °C olduğu için **buz noktası kalibrasyonu** özellikle değerli ve ucuz.
- **Yalıtım:** Hatlar en az 10 mm köpükle yalıtılmalı, ortam sıcaklığı (`T_AMB`) kaydedilmeli. Wang'larda ortam 20–25 °C'de tutulmuştu.
- **LHP'yi kendimiz dolduracaksak** gaz alma adımı (ısıtma + vakum, ~0,5 Pa) şart. Aksi halde NCG performansı düşürür ve sonuçları makalelerle karşılaştırılamaz hale getirir.

---

## 6. Formül kartı

| Büyüklük | Formül | Kaynak |
|---|---|---|
| Kılcal basınç (en büyük) | $\Delta P_{cap} = 2\sigma\cos\theta / r_p$ | Üçü de |
| Çalışma koşulu | $\Delta P_{cap} \ge \Delta P_v + \Delta P_l + \Delta P_w + \Delta P_g$ | Zhao 2017, Denk. 4 |
| Kütle debisi | $\dot m \approx Q / h_{lv}$ | Wang 2023, Denk. 13 |
| Fitilde akış direnci (Darcy) | $\Delta P_w = \dfrac{\dot m \mu_l \ln(d_o/d_i)}{2\pi\rho_l L_w K_w}$ | Wang 2023, Denk. 22 |
| Yerçekimi/ivme direnci | $\Delta P_a = (\rho_l-\rho_v)\,a\,L\cos\alpha$ | Wang 2023, Denk. 5 |
| Kondenser kapasitesi | $Q_{cond} \approx \alpha A (T_{cond} - T_{coolant})$ | Wang 2023, Denk. 31 |
| Isı sızıntısı | $Q_{leak} = Q\left(1 + \dfrac{h_{lv}}{c_{p,l}(\bar T_{CC}-T_{CC,in})}\right)^{-1}$ | Wang 2023, Denk. 38 |
| Toplam direnç | $R_{tot} = (T_{eyer} - T_{coolant})/Q$ | Wang 2023/2024 |
| Döngü direnci | $R = \big(T_{e,out} - \bar T_{cond}\big)/Q$ | Zhao 2017, Denk. 1 |
| Kondenser direnci | $R_{cond} = (\bar T_{cond} - T_{sink})/Q$ | Wang 2024, Denk. 8 |
| Bond sayısı | $Bo = g(\rho_l-\rho_v)d_h^2/\sigma_l$. $0{,}05<Bo<3$ ise yerçekimi ihmal edilemez | Wang 2024, Denk. 10 |

---

## 7. Açık sorulara eklenecekler

Makaleler aşağıdaki soruları gündeme getiriyor. [acik-sorular.md](acik-sorular.md) dosyasına eklenmesi önerilir.

- [ ] **Çalışma akışkanı ne olacak** (etanol / amonyak / başka)? Basınç sensörü aralığı buna bağlı.
- [ ] **LHP hazır mı alınacak, yoksa üretilip doldurulacak mı?** Doldurulacaksa gaz alma ve vakum ekipmanı gerekir.
- [ ] **LHP tek CC'li mi, çift CC'li mi?** Kanal planı (T_CC1/T_CC2) buna bağlı.
- [ ] **LHP platforma hangi yönde monte edilecek?** Kondenserdeki akışın pitch ve roll ile yerçekimine göre nasıl değiştiği belgelenmeli.
- [ ] **Simulink modeli hangi Euler açı sırasını kullanıyor?**
- [ ] **Kararlı hal kriteri** ve **sonlandırma sıcaklığı** ne olacak?
- [ ] Soğutucu debisi için **debimetre** temin edilecek mi? (Literatür evet diyor.)

---

## 8. Kaynaklar

1. **Zhao, Y., Chang, S., Yang, B., Zhang, W., Leng, M. (2017).** Experimental study on the thermal performance of loop heat pipe for the aircraft anti-icing system. *International Journal of Heat and Mass Transfer*, 111, 795–803. [doi:10.1016/j.ijheatmasstransfer.2017.04.009](https://doi.org/10.1016/j.ijheatmasstransfer.2017.04.009)
2. **Wang, H., Lin, G., Qin, H., Zhang, R., Bai, L., Guo, Y. (2023).** Design and experimental validation of a high capacity loop heat pipe for avionics cooling. *Thermal Science and Engineering Progress*, 45, 102139. [doi:10.1016/j.tsep.2023.102139](https://doi.org/10.1016/j.tsep.2023.102139)
3. **Wang, H., Lin, G., Guo, Y., Zhao, W., Bai, L. (2024).** Experimental study of a high-capacity dual compensation chamber loop heat pipe at different orientations. *International Journal of Thermal Sciences*, 202, 109051. [doi:10.1016/j.ijthermalsci.2024.109051](https://doi.org/10.1016/j.ijthermalsci.2024.109051)

Makalelerde atıf yapılan ve projeyle ilgili olabilecek diğer çalışmalar:
- Su, Q., Chang, S., Zhao, Y. vd. (2018). A review of loop heat pipes for aircraft anti-icing applications. *Applied Thermal Engineering*, 130, 528–540. Uçak buz önlemede LHP'ler üzerine derleme, başlangıç için iyi bir okuma.
- Gregori, C. vd. (2007). Loop heat pipe technology for aircraft anti-icing applications. SAE 2007-01-3312. Buz önleme için akışkan karşılaştırması.
- Xie, Y. vd. (2015). DCCLHP'nin ivme alanındaki davranışı. *Applied Thermal Engineering*, 81, 297–312.
