# LabVIEW

LabVIEW projesi (`.lvproj`) ve VI'lar bu klasörde yer alacak.

## Planlanan yapı

```
labview/
├── LHP-Control.lvproj
├── Main.vi                 Ana uygulama (arayüz + döngüler)
├── acquisition/            Sensör okuma VI'ları
├── control/                Isıtıcı ve fan kontrolü, PID
├── safety/                 Limitler ve alarmlar
├── platform/               Simulink UDP haberleşmesi
├── logging/                CSV/TDMS kayıt
└── subvi/                  Ortak yardımcı VI'lar
```

## Notlar

- Kullanılan LabVIEW sürümünü buraya yazın: **(belirlenecek)**
- VI'lar ikili dosyadır; aynı VI üzerinde iki kişi aynı anda çalışmamaya dikkat edin. Değişiklikten önce `git pull` yapın.
- LabVIEW'da *Tools → Options → Environment → "Separate compiled code from new files"* seçeneğini açın. Böylece gereksiz değişiklikler azalır.
