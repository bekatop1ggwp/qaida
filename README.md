````md
# Qaida — local run guide

Проект состоит из 3 частей:

- `qaida-back` — backend на NestJS
- `qaida-back/knn-service` — Python recommendation service
- `qaida_front` — Flutter mobile app

## 1. Requirements

### Backend
- Node.js 18+
- pnpm
- MongoDB

### Mobile
- Flutter SDK
- Android Studio
- Android SDK
- Android emulator
- JDK 17

### Recommendation service
- Python 3.10
- pip
- virtualenv

---

## 2. Recommended paths

Хранить проект лучше в папке без кириллицы:

- `C:\Qaida\qaida-back`
- `C:\Qaida\qaida_front`

---

## 3. Backend setup

```powershell
cd C:\Qaida\qaida-back
pnpm install
````

Создать файл:

```text
src/core/.env
```

Пример содержимого:

```env
DATABASE_URL=your_mongodb_connection_string
ACCESS_TOKEN=your_access_token_secret
REFRESH_TOKEN=your_refresh_token_secret
API_KEY=your_api_key
BACKEND_URL=http://localhost:8080
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

## 4. Recommendation service setup

```powershell
cd C:\Qaida\qaida-back\knn-service
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

Health check:

```text
http://127.0.0.1:8001/health
```

Проверка endpoint:

```text
POST http://localhost:8001/recommend
```

Body:

```json
{
  "user_id": "USER_ID"
}
```

---

## 5. Flutter setup

```powershell
cd C:\Qaida\qaida_front
flutter pub get
flutter doctor -v
```

Если нужно, указать JDK 17:

```powershell
flutter config --jdk-dir "C:\Program Files\Java\jdk-17.0.1"
```

---

## 6. Recommendation API URL

Во Flutter recommendation service передаётся через `dart-define`.

Для Android emulator:

```powershell
flutter run -d emulator-5554 --dart-define="RECOMMENDATION_API_URL=http://10.0.2.2:8001"
```

Для реального телефона в одной Wi-Fi сети с ноутбуком:

```powershell
flutter run --dart-define="RECOMMENDATION_API_URL=http://192.168.8.6:8001"
```

---

## 7. Network notes

Для Android emulator:

* backend: `10.0.2.2:8080`
* recommendation service: `10.0.2.2:8001`

Для реального телефона:

* backend: `192.168.8.6:8080`
* recommendation service: `192.168.8.6:8001`

Если IP ноутбука изменится, его нужно обновить.

---

## 8. Firewall

Чтобы телефон мог достучаться до backend и recommendation service, должны быть открыты порты:

* `8080`
* `8001`

PowerShell от имени администратора:

```powershell
New-NetFirewallRule -DisplayName "Qaida Backend 8080" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
New-NetFirewallRule -DisplayName "Qaida KNN 8001" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8001
```

---

## 9. Run order

### Terminal 1 — backend

```powershell
cd C:\Qaida\qaida-back
pnpm run start:dev
```

### Terminal 2 — recommendation service

```powershell
cd C:\Qaida\qaida-back\knn-service
.\venv\Scripts\Activate.ps1
python -m uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### Terminal 3 — Flutter (Android emulator)

```powershell
cd C:\Qaida\qaida_front
flutter pub get
flutter run -d emulator-5554 --dart-define="RECOMMENDATION_API_URL=http://10.0.2.2:8001"
```

### Terminal 3 — Flutter (real phone)

```powershell
cd C:\Qaida\qaida_front
flutter pub get
flutter run --dart-define="RECOMMENDATION_API_URL=http://192.168.8.6:8001"
```

---

## 10. APK build

```powershell
flutter build apk --debug
```

APK path:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

```
```