

# 🧮 BMI Calculator App (Flutter)

A modern **Flutter-based BMI Calculator application** that allows users to calculate their Body Mass Index (BMI), view health feedback, estimate body fat and water percentage, and track BMI history over time.

---

## 📱 Features

* ✅ **BMI Calculation** based on height and weight
* 👤 **Gender selection** (Male / Female)
* 📊 **BMI Result Interpretation**

  * Underweight
  * Normal
  * Overweight
  * Obese
* 💬 **Health feedback with emojis**
* 🛡️ **Biometric Security (Fingerprint / Face ID login)**
* ⚖️ **Healthy weight range calculation**
* 💧 **Estimated body water percentage**
* 🧬 **Estimated body fat percentage**
* 📈 **BMI history tracking**
* 💾 **Persistent storage using SharedPreferences**
* 🌙 **Dark / Light theme support**
* 🔔 **Optional daily reminder notifications**
* 📱 **Android support (tested on Android 9+)**

---

## 🧠 BMI Formula Used

```text
BMI = weight (kg) / (height (m) × height (m))
```

---

## 🧪 Body Fat Estimation Formula

```text
Body Fat % = 1.20 × BMI + 0.23 × age − 10.8 × gender − 5.4
```

* gender = 1 (male), 0 (female)

---

## 💧 Body Water Estimation

Based on lean body mass approximation:

```text
Water % ≈ (1 − bodyFat / 100) × constant
```

* Male constant ≈ 0.60
* Female constant ≈ 0.50

---

## 🗂 Project Structure

```text
lib/
│── main.dart
│── input_page.dart
│── result_page.dart
│── bmi_history_page.dart
│── bmi_measurement.dart
│── bmi_provider.dart
│── biometric_login_page.dart
│── splash_page.dart
│── notification_service.dart
│── theme_provider.dart
│── utils.dart
```

---

## 💾 Data Persistence

The app uses **SharedPreferences** to store BMI history locally:

* BMI values are saved as JSON
* Data remains available after app restart
* No external database required

---

## 🚀 Getting Started

### 1️⃣ Prerequisites

* Flutter SDK
* Android Studio / VS Code
* Android device or emulator

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Run the App

```bash
flutter run
```

---

## 📦 Dependencies Used

* `flutter`
* `provider`
* `shared_preferences`
* `page_transition`
* `fl_chart`
* `intl`
* `permission_handler`

---

## 📱 Supported Devices

* Android 9 (Pie) or higher
* Devices with or without fingerprint sensors
* Tested on budget phones (Samsung A-series, Xiaomi Redmi)

---

<<<<<<< HEAD
=======

>>>>>>> 82799e4c012f2df873f6b9385e70e6047cb5d529
