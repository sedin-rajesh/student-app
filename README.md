# 🎓 Student Management Application (StudentApp)

[![Ruby](https://img.shields.io/badge/Ruby-4.0.5-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.3-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![Test Suite](https://img.shields.io/badge/Tests-RSpec-green.svg)](https://rspec.info/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A full-featured **Student Management Application** built with **Ruby on Rails 8**, featuring role-based access control, file attachment handling, PDF report card generation via background workers, email notifications, and a secure RESTful JSON API with JWT authentication.

---

## 📌 Features

### 🔐 Authentication & Role-Based Access Control
* **Devise Authentication**: Web session management for users.
* **Role Management**:
  * **Admin**: Complete access to manage all users, teachers, and student records across the platform.
  * **Teacher**: Manage assigned students, upload student documents, update marks, and view assigned dashboards.
* **JWT API Authentication**: Secure REST API endpoints via `devise-jwt`.

### 👨‍🎓 Student Management
* Full CRUD operations for Student profiles (Name, Email, Age, Course, City, Marks, Grade).
* Supported Courses: `Ruby`, `Rails`, `React`, `Java`.
* Dynamic pass/fail calculation based on marks threshold ($\ge 35$).
* Instant search and multi-attribute filtering (by name, email, course, and grade).

### 📎 Media & Document Attachments (Active Storage)
* **Profile Photo**: Single file upload (validated for JPEG/PNG image formats, max 5MB).
* **Documents**: Multiple document uploads (validated for PDF, JPEG, PNG formats, max 10MB per document).
* Dedicated endpoints to remove/purge individual profile photos or specific document attachments.

### 📄 PDF Report Card Generation & Background Jobs
* Automated PDF report card generation utilizing **Prawn**.
* Asynchronous job processing with **ActiveJob** / **Sidekiq** to avoid blocking HTTP request cycles.

### 📧 Email Notifications
* Automated transactional emails powered by `ActionMailer` & `Resend`:
  * **Student Creation**: Email alert upon student registration.
  * **Teacher Assignment**: Dual notifications sent to teacher and student upon assignment.
  * **Document Uploads**: Notification when new documents are attached to a profile.
  * **Marks Posted**: Alert when student evaluation marks are updated.
* **LetterOpener**: Integrated email preview in development mode.

### 🔌 RESTful JSON API (v1)
* Versioned API endpoints located at `/api/v1/`.
* Support for JWT Bearer token authentication header (`Authorization: Bearer <token>`).
* Endpoints for session management, teachers lookup, and student management.

---

## 🛠️ Tech Stack & Dependencies

* **Language**: Ruby 4.0.5
* **Framework**: Ruby on Rails 8.1.3
* **Database**: PostgreSQL 16
* **Frontend**: Hotwire (Turbo Rails & Stimulus), Importmaps, Propshaft
* **Authentication**: Devise & Devise-JWT
* **Background Processing**: Sidekiq / Solid Queue
* **PDF Generation**: Prawn
* **Email Service**: Resend (Development preview with LetterOpener)
* **Testing Framework**: RSpec, FactoryBot, Shoulda Matchers, SimpleCov
* **Static Analysis & Security**: RuboCop (Rails Omakase), Brakeman, Bundler-Audit
* **Deployment & Containerization**: Docker, Docker Compose, Kamal, Thruster

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
* **Ruby**: `4.0.5` (or compatible 3.x/4.x version)
* **PostgreSQL**: `16+`
* **Redis**: (Required if running Sidekiq for background jobs)
* **Bundler**: `gem install bundler`

---

### Local Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-username/studentApp.git
   cd studentApp
   ```

2. **Install Dependencies**
   ```bash
   bundle install
   ```

3. **Database Configuration**
   Configure your database credentials in `config/database.yml` or set the `DATABASE_URL` environment variable.

4. **Create & Seed the Database**
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```
   *Default Seed Credentials:*
   * **Admin Email**: `admin@example.com`
   * **Password**: `password123`

5. **Start the Rails Server**
   ```bash
   bin/rails server
   ```
   Access the web app at [http://localhost:3000](http://localhost:3000).

---

## 🐳 Running with Docker

You can easily run the application using **Docker Compose**:

```bash
# Build and start services (Rails web server + PostgreSQL database)
docker compose up --build
```

The application will be accessible at [http://localhost:3000](http://localhost:3000).

To run database migrations within Docker:
```bash
docker compose exec web bin/rails db:migrate
```

---

## 🛰️ API Endpoints (v1)

### Authentication
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/login` | Authenticate user and return JWT token |
| `DELETE` | `/api/v1/logout` | Revoke JWT token and destroy session |

### Students (`/api/v1/students`)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/students` | List all students (supports filtering & search) |
| `POST` | `/api/v1/students` | Create a new student record |
| `GET` | `/api/v1/students/:id` | Retrieve student details |
| `PATCH/PUT` | `/api/v1/students/:id` | Update student profile |
| `DELETE` | `/api/v1/students/:id` | Remove student record |

### Teachers & Users
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/users` | List users |
| `GET` | `/api/v1/users/teachers` | List all users with teacher role |
| `GET` | `/api/v1/users/teachers_by_subject` | Filter teachers by subject |
| `GET` | `/api/v1/teachers/:teacher_id/students` | List students assigned to a specific teacher |
| `POST` | `/api/v1/teachers/:teacher_id/students` | Create a student for a specific teacher |

---

## 🧪 Testing & Code Quality

### Running Tests
Execute the RSpec test suite:
```bash
bundle exec rspec
```

### Coverage Report
Coverage reports are automatically generated by **SimpleCov** after running tests and stored in `/coverage/index.html`.

### Static Code Analysis & Security
```bash
# RuboCop style check
bundle exec rubocop

# Security vulnerability scan in Rails code
bundle exec brakeman

# Gem dependency vulnerability audit
bundle exec bundler-audit --update
```

---

## 📂 Project Structure

```text
studentApp/
├── app/
│   ├── controllers/      # Web & API Controllers (v1)
│   ├── jobs/             # ActiveJob background workers (Report Card Job)
│   ├── mailers/          # ActionMailer notification emails
│   ├── models/           # User & Student ActiveRecord models & validations
│   ├── pdfs/             # Prawn PDF report generator templates
│   ├── services/         # Domain business logic (ReportCardGenerator)
│   └── views/            # ERB views and Turbo Frame templates
├── config/               # Database, routes, and environment configuration
├── db/                   # Migrations and seed data
├── spec/                 # RSpec request, model, job, and mailer tests
├── Dockerfile            # Production Dockerfile
├── Dockerfile.dev        # Development Dockerfile
└── docker-compose.yaml   # Docker Compose services definition
```

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).
