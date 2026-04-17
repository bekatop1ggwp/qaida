````md
# Qaida — local run guide

Проект состоит из 3 частей:

- `qaida-back` — backend на NestJS
- `qaida-back/knn-service` — Python KNN recommendation service
- `qaida_front` — Flutter mobile app

## 1. Что нужно установить

### Для backend
- Node.js 18+
- pnpm
- MongoDB

### Для mobile
- Flutter SDK
- Android Studio
- Android SDK
- Android emulator
- JDK 17

### Для recommendation service
- Python 3.10
- pip
- virtualenv

---

## 2. Важные пути

Проекты лучше хранить в папке **без кириллицы**.  
Рабочий вариант:

- `C:\Qaida\qaida-back`
- `C:\Qaida\qaida_front`

---

## 3. Backend setup

Перейти в backend:

```powershell
cd C:\Qaida\qaida-back
````

Установить зависимости:

```powershell
pnpm install
```

Создать файл:

```text
src/core/.env
```

Содержимое:

```env
DATABASE_URL=mongodb://localhost:27017/qaida
ACCESS_TOKEN=qaida_access_secret_123
REFRESH_TOKEN=qaida_refresh_secret_123
BACKEND_URL=http://192.168.8.6:8080
API_KEY=test
```

Запуск backend:

```powershell
pnpm run start:dev
```

Swagger:

```text
http://localhost:8080/swagger
```

---

## 4. KNN service setup

Перейти в папку сервиса:

```powershell
cd C:\Qaida\qaida-back\knn-service
```

Создать venv:

```powershell
python -m venv venv
```

Активировать:

```powershell
.\venv\Scripts\Activate.ps1
```

Установить зависимости:

```powershell
pip install -r requirements.txt
```

Запуск:

```powershell
python main.py
```

Сервис поднимается на:

```text
http://0.0.0.0:8001
```

Локальная проверка через Postman:

```text
POST http://localhost:8001/recommend
```

Body → raw → JSON:

```json
{
  "user_id": "USER_ID"
}
```

---

## 5. Flutter setup

Перейти в mobile project:

```powershell
cd C:\Qaida\qaida_front
```

Установить зависимости:

```powershell
flutter pub get
```

Проверить Flutter:

```powershell
flutter doctor -v
```

Важно:

* Flutter SDK должен быть установлен
* Android SDK должен быть привязан
* JDK 17 должен быть прописан в Flutter:

```powershell
flutter config --jdk-dir "C:\Program Files\Java\jdk-17.0.1"
```

---

## 6. Android/Gradle fixes, которые уже были нужны

### `android/settings.gradle`

```gradle
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.2" apply false
    id "org.jetbrains.kotlin.android" version "1.9.24" apply false
}

include ":app"
```

### `android/build.gradle`

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

### `android/app/build.gradle`

```gradle
plugins {
    id "com.android.application"
    id "org.jetbrains.kotlin.android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "com.aitu.qaida"
    compileSdk flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.aitu.qaida"
        minSdk 24
        targetSdk flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib"
}
```

---

## 7. Assets

В `pubspec.yaml` используются:

* `assets/sample.jpg`
* `assets/reviews.png`
* `assets/R.jpg`
* `assets/logo1.png`
* `assets/logo2.png`

Папка `assets` должна существовать, и эти файлы должны лежать внутри нее.

---

## 8. 2GIS map issue

Плагин `dgis_map_kit` оказался несовместим с текущей версией Flutter, поэтому карта была временно отключена.

Файл:

```text
lib/components/place/place_map.dart
```

временно заменен на заглушку с текстом:

```text
Карта временно недоступна
```

Пакет `dgis_map_kit` удален из `pubspec.yaml`.

---

## 9. Recommendation display fix

Для корректного отображения рекомендаций был поправлен экран:

```text
lib/views/home/authorized_home.dart
```

Проблема была в том, что рекомендации вызывались в неподходящий момент и refresh только очищал список, но не загружал данные заново.

---

## 10. IP для телефона

Для Android emulator использовался:

```text
10.0.2.2
```

Для реального телефона в одной Wi-Fi сети использовался IP ноутбука:

```text
192.168.8.6
```

Во Flutter-проекте были заменены адреса:

* `http://10.0.2.2:8080` → `http://192.168.8.6:8080`
* `http://10.0.2.2:8001` → `http://192.168.8.6:8001`

Если IP ноутбука изменится, его нужно заменить снова.

---

## 11. Firewall

Чтобы телефон мог достучаться до backend и KNN, были открыты порты:

* `8080`
* `8001`

Команды PowerShell от имени администратора:

```powershell
New-NetFirewallRule -DisplayName "Qaida Backend 8080" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
New-NetFirewallRule -DisplayName "Qaida KNN 8001" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8001
```

---

## 12. Run order

### Terminal 1 — backend

```powershell
cd C:\Qaida\qaida-back
pnpm run start:dev
```

### Terminal 2 — knn-service

```powershell
cd C:\Qaida\qaida-back\knn-service
.\venv\Scripts\Activate.ps1
python main.py
```

### Terminal 3 — Flutter

```powershell
cd C:\Qaida\qaida_front
flutter run
```

---

## 13. APK build

Debug APK:

```powershell
flutter build apk --debug
```

Путь к APK:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 14. Current status

Сейчас работает:

* регистрация
* логин
* рекомендации
* отображение карточек мест
* подключение телефона к backend и knn-service по Wi-Fi

Временно отключено:

* карта 2GIS внутри place screen
