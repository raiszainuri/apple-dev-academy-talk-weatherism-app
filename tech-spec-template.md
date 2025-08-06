## Tech Spec : Hourly Weather Forecast Horizontal Scroll

* **Author** : Rais Zainuri
* **Engineering Lead** : -
* **Product Specs** : - 
* **Important Documents** : - 
* **JIRA Epic** : -
* **Figma** : -
* **Figma Prototype** : -
* **BE Tech Specs** : -
* **Content Specs** : -
* **Instrumentation Specs** : -
* **QA Test Suite** : -
* **PICs** :

  * **PIC FE**: Rais Zainuri
  * **PIC PM**: 
  * **PIC Designer**: 
  * **QA**: 

---

## Project Overview

Menampilkan prakiraan cuaca per jam (12 jam ke depan) dalam format horizontal scroll dengan informasi:

* Jam (contoh: `12:00`)
* Ikon cuaca (dari `weatherCode`)
* Suhu (contoh: `22°`)

Digunakan untuk memperlihatkan prediksi cuaca kepada user secara ringkas dan mudah digeser.

---

## Requirements

### Functional Requirements

* Menampilkan maksimal 12 jam ke depan dari array `weather.hourly.time`.
* Setiap item menunjukkan:

  * Jam dalam format `"HH:mm"`
  * Ikon cuaca berdasarkan `weatherCode`
  * Suhu dalam derajat celcius
* Tersedia dalam bentuk horizontal scroll.
* Tanpa scrollbar (scroll indicator disembunyikan).

### Non Functional Requirements

* Performa tetap ringan meskipun datanya panjang.
* Rendering UI harus konsisten dan smooth saat scroll.

---

## High-Level Diagram

```
WeatherView
  └── ScrollView (.horizontal)
        └── HStack (ForEach hourly items)
              └── VStack (hour | icon | temperature)
```

---

## Low-Level Diagram

```
HourlyWeatherView
├── weather.hourly.time[index] → hourFromTimeString()
├── weather.hourly.temperature2m[index]
├── weather.current.weatherCode → viewModel.weatherIconName()
└── VStack {
      Text(hour)
      Image(systemIconName)
      Text(temperature)
    }
```

---

## Code Structure & Implementation Details

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 16) {
        ForEach(0..<min(weather.hourly.time.count, 12), id: \.self) { index in
            VStack {
                Text(hourFromTimeString(weather.hourly.time[index]))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Image(systemName: viewModel.weatherIconName(for: weather.current.weatherCode))
                    .foregroundColor(.white)

                Text("\(Int(weather.hourly.temperature2m[index]))°")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
        }
    }
    .padding(.horizontal)
}
```

---

## Operational Excellence

Belum diperlukan monitoring khusus untuk komponen UI statis ini.

---

## Backward Compatibility / Rollback Plan

Perubahan ini hanya pada level tampilan. Jika bermasalah, UI ini dapat dengan mudah dihilangkan dari view tanpa memengaruhi fitur lain.

---

## Rollout Plan

* Langsung aktif setelah code merge.
* Tidak menggunakan feature flag.

---

## Out of Scope

* Tidak mencakup *forecast harian*.
* Tidak mencakup perubahan *theme*, *dark mode*, atau animasi transisi antar jam.

---

## Demo

Contoh tampilan:

```
12:00 ☀️ 22°
13:00 ☀️ 23°
14:00 ☁️ 21°
...
```

---

## Steps to use this feature

1. Buka halaman utama cuaca (misal: `WeatherView`).
2. Scroll horizontal ke kanan untuk melihat prediksi hingga 12 jam ke depan.

---

## Discussions and Alignments

**Q:** Kenapa hanya 12 jam?
**A:** Supaya tidak terlalu panjang dan tetap mudah dilihat.

**Q:** Ikon cuaca kok tidak sesuai tiap jam?
**A:** Saat ini masih menggunakan `weather.current.weatherCode`, bisa dikembangkan agar menggunakan `weather.hourly.weatherCode[index]` jika tersedia.

