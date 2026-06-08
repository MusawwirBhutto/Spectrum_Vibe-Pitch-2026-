# 💈 Groomin - AI-Powered Salon OS & Booking Platform

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Backend-Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Gemini AI](https://img.shields.io/badge/AI-Google_Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)

Groomin is a comprehensive B2B2C Software-as-a-Service (SaaS) platform designed to digitize the unorganized salon and grooming industry. It bridges the gap between salon owners facing "dead hours" and customers struggling with booking friction, using intelligent APIs and AI-driven style visualization.

## 🚀 The Elevator Pitch

We don't just sell salon bookings; we sell **confidence and efficiency**. Groomin provides an AI-powered "Style Match" for users to visualize their haircuts before booking, acting as a massive lead generator. For salons, we provide a unified CRM and dashboard to manage queues, optimize inventory, and deploy dynamic yield management to turn empty chairs into revenue.

---

## ✨ Key Features

### 👤 For Customers (B2C Interface)

- **AI Style Studio:** Integrated with Google Gemini Vision API to analyze face shapes and recommend suitable haircuts, along with a mock visualization engine.
- **Smart Discovery:** Geolocation-based "Nearby Salons", "Featured Salons", and robust search functionality to find the perfect stylist.
- **Seamless Booking:** Frictionless slot booking with real-time availability fetched via REST APIs.
- **Secure Authentication:** Full email verification, secure login, and password recovery mechanisms.

### 🏢 For Salon Owners (B2B Interface)

- **Dual-Role Architecture:** A single app seamlessly handles both customer and business environments using role-based state routing.
- **Business Dashboard:** Real-time visibility into active bookings, slot management, and daily schedules.
- **Dynamic Yield Ready:** Architecture designed to support off-peak flash discounts to maximize daily revenue.

---

## 🛠️ Technical Architecture & Stack

Groomin is built focusing on **Clean Architecture** principles, ensuring high scalability and modularity.

- **Frontend:** Flutter (Dart) with `Provider` for robust state management.
- **Backend:** Spring Boot (Java) handling business logic, user roles, and booking transactions.
- **Database:** MySQL relational database for structured storage of users, salons, and slots.
- **AI Integration:** Google Gemini REST API for computer vision and generative text analysis.

### 📂 Core Directory Structure (Frontend)

```text
lib/
├── api_services/       # API endpoints, HTTP clients, and AuthNotifier state
├── Business/           # Dedicated UI flow for Salon Owners (B2B)
├── models/             # Data classes (e.g., SalonModel) for JSON serialization
├── pages/              # B2C UI Screens (Home, AI Studio, Appointment, Profile)
└── routes/             # Centralized application routing logic
```
