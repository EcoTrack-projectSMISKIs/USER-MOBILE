# EcoTrack User Mobile App

EcoTrack is a Flutter-based mobile application designed to help users monitor and manage their energy usage using IoT smart plug integrations. This app is part of the EcoTrack system ecosystem which includes user dashboards, smart plug connectivity, OTP verification, profile settings, and real-time usage display.

## ✨ Features

- 📲 User registration & login via email/phone/username
- 🔐 OTP-based email verification
- ⚙️ Profile settings with editable name and username
- 🔌 Device usage tracking (real-time data from smart plugs)
- 🌍 Responsive UI with persistent login
- 📡 IoT integration with smart plug APIs
- 🚪 Logout and local storage cleanup

## 📦 Technologies Used

- Flutter
- Dart
- RESTful APIs
- SharedPreferences
- HTTP package
- Node.js (for backend endpoints)

## 🛠️ Getting Started

1. Clone the repository:

```bash
git clone https://github.com/EcoTrack-projectSMISKIs/USER-MOBILE.git
cd USER-MOBILE
```

2. Create a `.env` file in the root with your base URL:

```env
BASE_URL=http://<your-ip>:5003
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app on a connected device:

```bash
flutter run
```

## 📁 Folder Structure

- `/lib/screens/` - Contains all the screens (Sign Up, Sign In, Profile, etc.)
- `/lib/services/` - Handles HTTP requests and authentication
- `/lib/widgets/` - Custom reusable widgets like NavBar

## 🧪 Notes

- Ensure the backend server is running and accessible via the IP in `.env`
- iOS simulator may need localhost to be mapped to your host IP

