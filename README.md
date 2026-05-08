# Farmy Frontend Platform

[![Flutter](https://img.shields.io/badge/Flutter-v3.10+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/State-Provider-blue?style=flat-square)](https://pub.dev/packages/provider)
[![Design](https://img.shields.io/badge/UI-Glassmorphism-A3E635?style=flat-square)](https://farmynet.com)

> A modern, scalable, and cross-platform mobile ecosystem built with Flutter, powering the Farmy agri-tech platform with high-performance dashboards, real-time marketplace interactions, and blockchain-verified tools.

---

## 📖 Overview

The **Farmy Frontend Platform** is a state-of-the-art mobile application that provides a unified experience for the four pillars of the Farmy ecosystem: Farmers, Workers, Investors, and Customers. It leverages Flutter's high-performance rendering engine to deliver a premium, glassmorphic UI across iOS and Android.

### High-Level Goals
- **Unified Experience**: Seamless role-switching and specialized dashboards.
- **Visual Excellence**: A high-fidelity, interactive UI that feels premium and responsive.
- **Trust & Transparency**: Integrated blockchain verification and live financial tracking.
- **AI-First Design**: Native AI assistants to guide users through complex agricultural and investment tasks.

---

## 🛠️ Tech Stack

### Core Framework
- **Framework**: Flutter (v3.10+)
- **Language**: Dart (v3.0+)
- **Architecture**: MVVM + Service Layer pattern

### State Management
- **Primary**: `Provider` for reactive UI state.
- **Secondary**: `Riverpod` for complex asynchronous logic.
- **Persistence**: `Hive` (NoSQL) & `Shared Preferences` for localized caching.

### Communication & Real-time
- **Networking**: `Dio` & `Http` with specialized interceptors.
- **Real-time**: `Socket.io Client` for live notifications and marketplace updates.
- **Sync**: Automated background data synchronization via `Workforce Lifecycle` providers.

### External Integrations
- **Payments**: `Flutter Stripe` for secure in-app transactions and payouts.
- **Auth**: `Apple Sign-In`, `Google Sign-In`, and `Firebase Auth`.
- **Intelligence**: `Google ML Kit` (Face/Text recognition) and Gemini-powered assistants.
- **Blockchain**: `Hedera Hashgraph` SDK for data integrity verification.

---

## 🏗️ Project Architecture

The application follows a modular, feature-based architecture designed for long-term scalability and clean separation of concerns.

```text
lib/
├── core/           # Low-level system configurations and constants
├── models/         # PODO (Plain Old Dart Objects) for data mapping
├── providers/      # Global and feature-specific state management logic
├── services/       # API communication and third-party service integration
├── screens/        # Feature-based UI organization (Customer, Farmer, etc.)
├── theme/          # Design system tokens and Glassmorphic styling
├── widgets/        # Reusable UI components and shared UI elements
└── game/           # Isometric engine logic and game-based visualizations
```

### Core Layers
1. **UI Layer**: Composed of feature-focused screens and atomic widgets, utilizing the custom `Farmy Design System`.
2. **State Layer**: Reactive providers that encapsulate business logic and data flows.
3. **Service Layer**: Dedicated API services handling network requests, error handling, and data normalization.

---

## 👥 User Roles & Experience

### 👨‍🌾 Farmer Experience
- **Operational Dashboard**: Live overview of land status, workforce activity, and production metrics.
- **Workforce Management**: Digital recruitment, contract management, and performance tracking.
- **AI Strategy**: Specialized AI agent for crop calendar generation and operational optimization.

### 👷 Worker Experience
- **Job Finder**: Localized marketplace for agricultural labor opportunities with real-time matching.
- **Wallet & Earnings**: Transparent tracking of earnings with Stripe-integrated withdrawal flows.
- **Task Management**: Structured task lists with digital proof-of-work submission.

### 💰 Investor Experience
- **ROI Analytics**: Real-time financial dashboard tracking production yields and investment returns.
- **Asset Management**: Digital ownership tracking of land, trees, machines, and structures.
- **Trust Tools**: Direct integration with Hedera for immutable transaction records.

### 🛒 Customer Experience
- **Marketplace**: Browse and purchase fresh, sustainable products directly from local farms.
- **Order Tracking**: End-to-end delivery tracking with live status updates.

---

## 🚀 Core Systems

### 🧑‍🌾 Workforce System
Manage the entire lifecycle of agricultural labor through digital invitations, contract negotiations, and active performance monitoring.

### 💼 Jobs System
Automated job request creation linked to specific land plots, featuring AI-driven worker recommendations and real-time application status tracking.

### 🤖 AI Features
Integrated "Agent" screens for Farmers and Investors, providing contextual intelligence for strategy sessions and investment recommendations.

### 🎮 Isometric Engine
A custom-built game engine within the app that provides visual representations of land plots, asset placement, and worker movement.

---

## 🔐 Routing & Security

- **Role-Based Navigation**: Dynamic tab management in `MainScreen` that adapts to the authenticated user's role.
- **Protected Routes**: Middleware-style checks for authenticated sessions and role permissions.
- **Secure Storage**: `Flutter Secure Storage` for JWT and sensitive user credentials.
- **2FA Support**: Native implementation of TOTP-based secondary authentication.

---

## 🎨 UI/UX Design System

The app follows the **Farmy Glassmorphic Design System**, characterized by:
- **Visuals**: Backdrop filters, transparent gradients, and lime-green branding.
- **Theming**: Full support for high-contrast Dark and Light modes.
- **Responsiveness**: Flexible layouts designed to scale from compact smartphones to large-screen tablets.
- **Animations**: Staggered list animations and smooth hero transitions for a premium feel.

---

## 📦 Environment Setup

### Prerequisites
- Flutter SDK (v3.10+)
- Android Studio / VS Code
- Xcode (for iOS development)
- CocoaPods

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/farmyapp.git
   cd farmyapp
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Setup environment variables:
   ```bash
   cp .env.example .env
   # Add your API base URL and Stripe/AI keys
   ```
4. Run the application:
   ```bash
   flutter run
   ```

### Build Commands
- **iOS**: `flutter build ios --release`
- **Android**: `flutter build apk --release`

---

## 👥 Development Team

| Avatar | Name | Role | Links |
| :---: | :--- | :--- | :--- |
| <img src="https://github.com/fekikarim.png" width="40" height="40" style="border-radius:50%"> | **Karim Feki** | Lead Full-Stack Developer | [GitHub](https://github.com/fekikarim) • [LinkedIn](https://www.linkedin.com/in/karimfeki) • [Portfolio](https://karimfeki.is-a.dev) |
| <img src="https://github.com/nesrine-derouiche.png" width="40" height="40" style="border-radius:50%"> | **Nesrine Derouiche** | Frontend Developer | [GitHub](https://github.com/nesrine-derouiche) • [LinkedIn](https://linkedin.com/in/nesrine-derouiche) • [Portfolio](https://nesrine-derouiche.is-a.dev) |
| <img src="https://github.com/hamabtw.png" width="40" height="40" style="border-radius:50%"> | **Mohamed Abidi** | Backend Developer | [GitHub](https://github.com/hamabtw) • [LinkedIn](https://www.linkedin.com/in/med-abidi) • [Portfolio](https://hamabtw.github.io/portfolio) |
| <img src="https://github.com/oussemissaoui.png" width="40" height="40" style="border-radius:50%"> | **Oussema Issaoui** | Mobile Developer | [GitHub](https://github.com/oussemissaoui) |
| <img src="https://github.com/fatmahidouss.png" width="40" height="40" style="border-radius:50%"> | **Fatma Hidoussi** | Marketing & QA | [GitHub](https://github.com/fatmahidouss) • [LinkedIn](https://www.linkedin.com/in/fatma-hidoussi-497052236) |

---

© 2026 Farmy Platform. All rights reserved.
