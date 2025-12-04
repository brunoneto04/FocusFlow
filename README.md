# FocusFlow

FocusFlow is an iOS app that helps you reduce distractions, build healthy device habits, and stay focused on what matters – without feeling overwhelmed.

> Built with SwiftUI and the latest Screen Time / Family Controls APIs.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Open in Xcode](#2-open-in-xcode)
  - [3. Configure capabilities](#3-configure-capabilities)
  - [4. Build & run](#4-build--run)
- [Permissions & Privacy](#permissions--privacy)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

FocusFlow uses Apple's **Screen Time**, **Family Controls** and (optionally) **HealthKit** to provide a structured way to:

- Limit distracting apps
- Plan focus sessions
- Track your progress over time
- Build sustainable digital habits

The app is built using **SwiftUI** and follows an **MVVM**-oriented architecture, with a clear separation between views, view models, and services.

---

## Features

- 🧠 **Guided Onboarding**  
  Friendly onboarding flow explaining why the app needs Screen Time / Notification permissions and how FocusFlow works.

- 🔒 **Screen Time & App Blocking**  
  Uses `FamilyControls` / `DeviceActivity` to:
  - Request Screen Time authorization
  - Configure which apps / categories can be limited
  - Apply focus rules during active sessions

- ⏱️ **Focus Sessions**  
  - Start focus timers with a duration and simple goal  
  - Use app limits during a session to reduce distractions  
  - Visual feedback on progress during and after the session

- 📊 **Progress & Insights**  
  - Overview of recent focus sessions  
  - High-level stats (total focus time, streaks, etc.)  
  *(Extend / customise this section according to your implementation.)*

- 🧩 **Modular Permissions UI**  
  - Reusable permission cards (e.g. Screen Time, Notifications, Health)  
  - Clear status and actions: "Enable", "Granted", "Fix issue"

---

## Architecture

FocusFlow is organised in a modular way around **features** and **services**:

- `Core/`
  - `Services/`
    - `ScreenTimeManager.swift` – wraps Screen Time / Family Controls APIs
    - Other managers (e.g. `NotificationManager`, `HealthManager`) as needed
  - `Models/` – core data models and types
- `Features/`
  - `Onboarding/`
  - `Permissions/`
  - `FocusSession/`
  - `Dashboard/`
- `Shared/`
  - Reusable UI components (e.g. `PermissionCard`, buttons, typography)
  - Theming and constants

The app follows MVVM:

- **View**: SwiftUI views (`*.swift` in `Features/.../Views`)
- **ViewModel**: business logic, state & side-effects
- **Service / Manager**: wraps Apple frameworks and system APIs

---

## Requirements

- **Xcode**: 15.0 or later  
- **iOS Deployment Target**: iOS 16.0+  
  - Family Controls / Screen Time APIs used in this project require iOS 16 or newer.
- **Swift**: 5.9+ (or the version that ships with your Xcode)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/FocusFlow.git
cd FocusFlow
