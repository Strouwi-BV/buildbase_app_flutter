# buildbase_app_flutter

# Flutter Installatie Guide

## Flutter Installeren

1. Ga naar de officiële Flutter website: https://docs.flutter.dev/get-started/install
2. Kies je besturingssysteem (voor deze guide zal ik Windows kiezen).
3. Kies dan Android.
4. Download de Flutter zip file:

   ![image](https://github.com/user-attachments/assets/04a25f70-e840-4691-8322-1800384fba8c)

5. Unzip de file en knip en plak hem in je C: Drive.
6. Navigeer naar de Flutter file -> navigeer naar bin en kopieer je path. Dit zou normaal "C:/flutter/bin" moeten zijn.
7. Zoek nu op jouw systeem naar "Environment Variables" en klik op **Edit the system environment variables**.
8. Klik op de **Environment Variables** knop:

   ![image](https://github.com/user-attachments/assets/1f84087a-64d3-45d3-ac17-3a05726e962a)

9. Ga naar **Path** in **User variables for "User"** en klik op **Edit**:

   ![image](https://github.com/user-attachments/assets/59dbfc56-e992-4cdd-8c72-933d29474fd5)

10. Klik op **New** en plak het eerder gekopieerde path.

## Android Studio Installeren

1. Ga naar de officiële website van Android Studio: https://developer.android.com/studio
2. Download Android Studio en volg het installatieproces (het is belangrijk dat **Android SDK**, **Android SDK Platform** en **Android Virtual Device** allemaal zijn aangevinkt).

## Project Runnen

1. Start Android Studio en open het Flutter-project.
2. Selecteer een emulator of een fysiek apparaat.
3. Start het project via de terminal:
   ```flutter run```
   
4. Of klik op de Run-knop in Android Studio.
