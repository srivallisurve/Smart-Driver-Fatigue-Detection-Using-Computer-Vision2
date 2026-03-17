# 🚗 Smart Driver Fatigue Detection System

A real-time driver drowsiness detection system built with **Flutter Web** (frontend) and **FastAPI + MediaPipe** (backend), deployed on **Vercel** and **Render**.

---

## 🌐 Live Demo

- **Frontend**: https://drowsiness-frontend.vercel.app
- **Backend API**: https://smart-driver-fatigue-detection-using.onrender.com

---

## 📸 Screenshots

> Add screenshots here

---

## 🏗️ Architecture
```
Flutter (Vercel)
      ↓ HTTP POST (image)
FastAPI (Render)
      ↓ imports
MediaPipe + OpenCV
      ↓ returns JSON
Flutter shows alert 🚨
```

---

## ⚙️ How It Works

1. Flutter Web captures webcam frame every second
2. Sends frame to FastAPI backend via HTTP POST
3. Backend runs MediaPipe Face Mesh
4. Calculates **EAR** (Eye Aspect Ratio) and **MAR** (Mouth Aspect Ratio)
5. Checks against thresholds
6. Returns status: **SAFE / WARNING / DROWSY**
7. Flutter shows alert and plays alarm if DROWSY

---

## 📊 Detection Logic

| Metric | Formula | Threshold |
|--------|---------|-----------|
| EAR | (A+B) / 2C | < 0.25 → drowsy |
| MAR | A / C | > 0.65 → yawning |
| Frame Counter | consecutive low EAR frames | > 15 → drowsy |
| Drowsy Score | accumulated score | > 15 → drowsy |

### Status Levels

| Status | Condition | Color |
|--------|-----------|-------|
| 🟢 SAFE | Normal state | Green |
| 🟡 WARNING | Early drowsiness | Orange |
| 🔴 DROWSY | High drowsiness | Red + Alarm |

---

## 🛠️ Tech Stack

### Frontend
- Flutter Web
- Dart
- audioplayers
- http package

### Backend
- Python 3.11
- FastAPI
- MediaPipe 0.10.30
- OpenCV
- NumPy
- Uvicorn

### Deployment
- Frontend → Vercel
- Backend → Render

---

## 📁 Project Structure
```
Smart-Driver-Fatigue-Detection/
│
├── backend/
│   ├── app.py           ← FastAPI server
│   ├── utils.py         ← EAR & MAR functions
│   ├── config.py        ← thresholds
│   ├── render.yaml      ← Render config
│   └── requirements.txt
│
└── frontend/
    ├── lib/
    │   ├── main.dart
    │   ├── screens/
    │   │   └── home_screen.dart
    │   ├── services/
    │   │   └── api_service.dart
    │   └── widgets/
    │       └── status_card.dart
    ├── assets/
    │   └── alarm.wav
    └── pubspec.yaml
```

---

## 🚀 Run Locally

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app:app --reload
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /health | Check server status |
| POST | /detect | Send image, get drowsiness result |
| GET | /docs | API documentation |

### Sample Response
```json
{
  "ear": 0.25,
  "mar": 0.37,
  "frame_counter": 5,
  "drowsy_score": 8,
  "status": "WARNING"
}
```

---

## ⚙️ Configuration

Edit `config.py` to adjust thresholds:
```python
EAR_THRESHOLD = 0.25      # Eye closure threshold
MAR_THRESHOLD = 0.65      # Mouth opening threshold
FRAME_THRESHOLD = 15      # Consecutive frames for alert
DROWSY_SCORE_LIMIT = 15   # Score limit for DROWSY
WARNING_SCORE_LIMIT = 7   # Score limit for WARNING
```

---

## 👩‍💻 Author

**Srivalli Surve**
- GitHub: [@srivallisurve](https://github.com/srivallisurve)

---

## 📝 License

MIT License

---

## 🙏 Acknowledgements

- MediaPipe by Google
- Flutter by Google
- FastAPI
- OpenCV