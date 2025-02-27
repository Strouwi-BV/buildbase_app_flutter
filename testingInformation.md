# 📘 Automatische Teststrategie voor Flutter & React Native

---

## 🚀 Teststrategie in Flutter

Flutter ondersteunt drie niveaus van testen:

### ✅ 1. Unit tests (Logica testen)

* **Framework** : `flutter_test`
* **Beschrijving** : Test individuele functies en klassen.
* **Commando** :

```sh
  flutter test test/unit_test.dart
```

### 🎨 2. Widget tests (UI-componenten testen)

* **Framework** : `flutter_test`
* **Beschrijving** : Simuleert interactie met widgets.
* **Commando** :

```sh
  flutter test test/widget_test.dart
```

### 📱 3. Integration tests (Volledige app testen)

* **Framework** : `integration_test`
* **Beschrijving** : Test volledige gebruikersflows op een apparaat/emulator.
* **Commando** :

```sh
  flutter test integration_test/app_test.dart
```

---

## ⚛️ Teststrategie in React Native

React Native biedt verschillende testmogelijkheden:

### ✅ 1. Unit tests (Logica testen)

* **Framework** : Jest (standaard)
* **Beschrijving** : Test functies, Redux-reducers en API-calls.
* **Commando** :

```sh
  npm test
```

### 🎨 2. Component tests (UI-componenten testen)

* **Framework** : React Testing Library + Jest
* **Beschrijving** : Simuleert gebruikersinteracties.
* **Commando** :

```sh
  npm test
```

### 📱 3. End-to-End (E2E) tests (Volledige app testen)

* **Frameworks** : Detox (beste keuze), Appium
* **Beschrijving** : Test de volledige gebruikerservaring.
* **Commando** :

```sh
  detox test -c android.emu.release
```

---

## 🌍 Cross-browser en multi-device testen

| **Platform** | **Framework** | **Testoplossing**            |
| ------------------ | ------------------- | ---------------------------------- |
| Flutter Web        | Playwright, Cypress | `flutter test --platform=chrome` |
| React Native Web   | Playwright, Cypress | `npx cypress open`               |
| Android/iOS        | Firebase Test Lab   | Cloud-based testing                |
| Android/iOS        | BrowserStack        | Testen op meerdere echte apparaten |

---

## 🔎 Vergelijking en Keuze

| **Type test**          | **Flutter**                             | **React Native**          |
| ---------------------------- | --------------------------------------------- | ------------------------------- |
| **Unit Test**          | `flutter_test`                              | Jest                            |
| **Component Test**     | `flutter_test`                              | React Testing Library           |
| **Integration Test**   | `integration_test`                          | Detox, Appium                   |
| **E2E Test**           | `flutter_driver`(oud) /`integration_test` | Detox (beste optie)             |
| **Cross-Browser Test** | Playwright, Cypress                           | Playwright, Cypress             |
| **Multi-device Test**  | Firebase Test Lab, Codemagic                  | Firebase Test Lab, BrowserStack |

---

## 🛠️ Aanbevolen Tools

* **CI/CD** : GitHub Actions, Bitrise, Codemagic
* **Cloud Testing** : Firebase Test Lab, BrowserStack
* **End-to-End Testing** : Detox (React Native), integration_test (Flutter)
* **Browser Testing** : Playwright, Cypress
