# 🚗 DriveON Platform

Full-stack logistics & delivery management platform.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Web** | React 19 + Vite + Tailwind CSS 4 |
| **Mobile** | Flutter (Android & iOS) |
| **Backend** | Java 17 + Spring Boot 3.2 |
| **Database** | PostgreSQL 16 (H2 for dev) |
| **Auth** | JWT (access + refresh tokens) |
| **API Docs** | Swagger UI (OpenAPI 3) |

## Quick Start

### Backend
```bash
cd backend
# Dev mode (H2 database)
./mvnw spring-boot:run

# Production (Docker + PostgreSQL)
docker compose up -d
```
API: http://localhost:8080  
Swagger: http://localhost:8080/swagger-ui.html  
H2 Console: http://localhost:8080/h2-console

### Web
```bash
cd web
npm install
npm run dev
```
Opens at http://localhost:5173

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

## Default Accounts

| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Operator | operator | operator123 |
| Driver | driver | driver123 |

## Project Structure
```
DriveON/
├── backend/          # Spring Boot API
│   ├── src/main/java/com/driveon/
│   │   ├── config/       # Security, CORS, Swagger, Seed data
│   │   ├── controller/   # REST controllers
│   │   ├── dto/          # Request/Response DTOs
│   │   ├── exception/    # Global error handler
│   │   ├── model/        # JPA entities
│   │   ├── repository/   # Data access
│   │   ├── security/     # JWT filter & provider
│   │   └── service/      # Business logic
│   ├── Dockerfile
│   └── docker-compose.yml
├── web/              # React + Tailwind
│   └── src/
│       ├── api/          # API client
│       ├── components/   # Layout, UI components
│       ├── pages/        # Login, Dashboard, Orders, Profile
│       └── store/        # Zustand state
└── mobile/           # Flutter
    └── lib/
        ├── router/       # GoRouter navigation
        ├── screens/      # Login, Home, Orders, Profile
        ├── services/     # API & Auth services
        └── theme/        # Colors, design tokens
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Login |
| POST | /api/auth/register | Register |
| GET | /api/users/me | Current user |
| GET | /api/orders | List orders (paginated) |
| POST | /api/orders | Create order |
| PATCH | /api/orders/{id}/status/{status} | Update status |
| GET | /api/orders/dashboard/stats | Dashboard stats |
