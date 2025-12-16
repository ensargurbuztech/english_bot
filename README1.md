# English Bot: AI Destekli Konuşma Pratik Asistanı

Bu proje, İngilizce öğrenen kullanıcıların (A1-C1 seviyesi) konuşma yeteneklerini geliştirmeleri için tasarlanmış, **Flutter** tabanlı mobil bir yapay zeka asistanıdır. Geleneksel uygulamaların aksine, kullanıcıyla sesli diyalog kurar ve telaffuz analizi yapar.

---

## Öne Çıkan Özellikler

* ** Akustik Yankı Engelleme (Acoustic Echo Cancellation):**
  Uygulamanın kendi sesi (TTS) ile kullanıcının mikrofon girdisi arasındaki döngü (loop) sorunu, donanım seviyesinde senkronizasyon algoritmalarıyla çözüldü. Bu sayede asistan konuşurken mikrofon otomatik kapanır, sözü bittiğinde dinlemeye geçer.

* ** Dinamik Seviye Yönetimi:**
  A1'den C1'e kadar 80'den fazla soru seti içerir. Dinleme ve cevaplama süreleri seviyeye göre otomatik ayarlanır (Örn: A1 için 10sn, C1 için 30sn).

* ** Yüksek Performans & Optimizasyon:**
  Gelişmiş ses işleme süreçlerine rağmen uygulama boyutu optimize edilerek **40MB** seviyesinde tutulmuştur.

---

## 🛠️ Kullanılan Teknolojiler

| Alan | Teknoloji / Kütüphane |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **Ses Sentezi (TTS)** | `flutter_tts` |
| **Ses Tanıma (STT)** | `speech_to_text` |
| **Veri Yönetimi** | Python (NLP tabanlı veri hazırlığı için) |

---

##  Teknik Zorluklar ve Çözümler

### 1. Donanımsal Yankı (Echo) Sorunu
**Sorun:** Asistan soru sorarken mikrofonun bu sesi algılayıp kendi kendini dinlemesi.
**Çözüm:** Mikrofon ve hoparlör arasına "Hardware-State" kontrolü eklendi. TTS bitiminden sonra mikrofonun aktifleşmesi için milisaniyelik gecikme (latency) tamponları oluşturuldu.

### 2. Derleme Bütünlüğü (Build Integrity)
**Sorun:** `dart.exe` kilitlenmeleri ve önbellek çakışmaları.
**Çözüm:** Manuel dosya temizliği ve pipeline optimizasyonu ile stabil bir derleme süreci sağlandı.

---

## 📷 Ekran Görüntüleri

![English_bot](https://github.com/user-attachments/assets/558f82af-e821-4a9f-b46d-b9b32f4de6bb)


##  Geliştirici

**Ensar Gürbüz**
*Siber Güvenlik Analisti & Mobil Uygulama Geliştiricisi*
