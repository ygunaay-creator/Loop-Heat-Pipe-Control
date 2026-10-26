# LabVIEW

LabVIEW projesi (`.lvproj`) ve VI'lar bu klasörde yer alacak.

## Gerekli yazılımlar

- LabVIEW (sürüm: **belirlenecek**)
- NI-VISA
- Keysight IO Libraries Suite (DAQ973A ve EDU36311A için USB/LAN sürücüleri)
- GPP-3323 için USB sanal COM portu sürücüsü (GW Instek)
- Keysight ve GW Instek LabVIEW sürücüleri (varsa NI Instrument Driver Network'ten). Yoksa doğrudan SCPI komutları kullanılır.

## Planlanan yapı

```
labview/
├── LHP-Control.lvproj
├── Main.vi                     Ana uygulama (arayüz + döngüler)
├── instruments/
│   ├── daq973a/                Kanal yapılandırma, tarama, okuma
│   ├── gpp3323/                Isıtıcı beslemesi
│   ├── edu36311a/              Fan ve 24 V döngü beslemesi
│   └── huber/                  Soğutucu
├── platform/                   Simulink UDP haberleşmesi
├── control/                    Sabit güç, PID, fan kontrolü
├── safety/                     Limitler ve alarmlar
├── logging/                    CSV/TDMS kayıt
└── subvi/                      Ortak yardımcı VI'lar
```

## Örnek SCPI komutları (taslak – kılavuzlardan doğrulanacak)

**DAQ973A – T tipi termokupl taraması**
```
*RST
CONF:TEMP TC,T,(@101:120)
CONF:CURR:DC (@121,122)
ROUT:SCAN (@101:122)
TRIG:SOUR TIM
TRIG:TIM 1
TRIG:COUN INF
INIT
FETCh?  / R?
```

**GPP-3323 – ısıtıcı (CH1)**
```
VSET1:12.0      gerilim ayarı
ISET1:2.5       akım sınırı
:OUTPut1:STATe ON
VOUT1?          gerilim geri okuma
IOUT1?          akım geri okuma
```

**EDU36311A – fan (CH2) ve 24 V döngü (CH3)**
```
APPL CH2,12,0.5
APPL CH3,24,0.1
OUTP ON,(@2,3)
MEAS:VOLT? CH2
MEAS:CURR? CH2
```

## Notlar

- VI'lar ikili dosyadır. Aynı VI üzerinde iki kişi aynı anda çalışmayın. Değişiklikten önce `git pull` yapın.
- *Tools → Options → Environment → "Separate compiled code from new files"* seçeneğini açın.
