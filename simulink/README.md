# Simulink

## 1. Sıcaklık kontrol modeli (`lhp_kontrol.slx`)

Isıtıcı gücünü PI kontrolcüsüyle ayarlayarak sıcaklığı hedefte (varsayılan 80 °C) tutan model. Şimdilik gerçek düzenek yerine **sanal bir ısıl model** kullanır. Mantık `matlab/sicaklik_kontrol.m` ile aynıdır.

`.slx` dosyası repoda tutulmaz, betikle üretilir. Böylece değişiklikler git'te satır satır görülebilir.

### Kurulum ve çalıştırma

MATLAB'da bu klasöre geçip komut penceresine yazın:

```matlab
lhp_kontrol_modeli_olustur   % modeli kurar, lhp_kontrol.slx olarak kaydeder ve açar (bir kez yeterli)
lhp_kontrol_calistir         % çalıştırır, özet yazar, grafik çizer, CSV kaydeder
```

Model Simulink'te açıkken **Run** düğmesiyle de çalışır. `Sicaklik` ve `Guc` scope'larına çift tıklayıp canlı izleyebilirsiniz.

Parametre değiştirmek için:

```matlab
T_hedef = 60;  Kp = 5;  lhp_kontrol_calistir
lhp_kontrol_parametreler     % varsayılanlara döner
```

Gereken: MATLAB + Simulink (ek toolbox gerekmez).

### Modelin yapısı

```
 Hedef ─▶ Hata ─▶ PI_Kontrolcu ─▶ Guvenlik ─▶ Duzenek_SANAL ─┬─▶ T_olculen
           ▲                       ▲    ▲                     │
           └───────────────────────┼────┴─────────────────────┘
                     Harici_Stop ──┘
```

| Blok | Ne yapar |
|---|---|
| `PI_Kontrolcu` | Simulink Discrete PID bloğu (PI modu). Çıkış 0–`P_max` W arasında sınırlı, clamping anti-windup açık |
| `Guvenlik` | Sıcaklık `T_limit`'i aşarsa, sensör arızalıysa (T < −50 °C) veya `Harici_Stop` > 0 ise gücü 0 yapar. Alarm bir kez oluşursa kalır (mandal) |
| `Duzenek_SANAL` | `C·dT/dt = P − (T − T_ortam)/R_th`. 1800. saniyede soğutma artar (bozucu). Sensör gecikmesi ve gürültüsü eklenir |
| `Harici_Stop` | Şimdilik sabit 0. Stewart Platformu eklenince platformun acil stop sinyali buraya bağlanacak |
| `Kayit` | Sonuçları `kayit` değişkenine yazar: T_hedef, T_olculen, P_W, T_gercek, alarm |

### Sonraki adımlar

1. **Gerçek ısıtıcı:** `Duzenek_SANAL` yerine gücü GPP-3323'e yazan bir blok (MATLAB System bloğu, `serialport`). Giriş `P_W`, çıkış `T_olculen` aynı kalacak.
2. **Gerçek sensör:** DAQ netleşince sıcaklık okuma bloğu.
3. **Stewart Platformu:** UDP Receive ile platform durumu ve acil stop, `Harici_Stop` girişine bağlanır.

## 2. Stewart Platformu haberleşmesi (sonra)

Stewart Platformu'nun Simulink modeli Türk-Alman Üniversitesi'ne aittir. Bu klasörde yalnızca haberleşme için eklenen bloklar, test modelleri ve notlar tutulacak.

- `udp_interface_test.slx`: platform olmadan UDP haberleşmesini test etmek için basit model
- Platform modeline eklenecek UDP Send/Receive bloklarının açıklaması

Mesaj formatı: [../docs/matlab-simulink-haberlesme.md](../docs/matlab-simulink-haberlesme.md)
