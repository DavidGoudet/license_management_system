# License Management System

A Ruby on Rails application for managing software licenses within organizations.

## Quick Start with Docker
A docker-compose file is included to help you deploy the project faster.

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose

### Development Setup

1. **Clone the repository**
```bash
   git clone <repo-url>
   cd license_management_system
```
2. **Set your environment**

Before starting the application, create a `.env` file in the project root:

```bash
cp .env.example .env
```
Then fill in the required environment variables:
#### Database Password

Set your PostgreSQL password:

DB_PASSWORD=your_password_here

#### SECRET_KEY_BASE

Get your secure key:

```rails secret```




2. **Start the application with Docker Compose**
```
   docker compose up --build -d
```


3. **Run database migrations and seed**

A seed file is included for better testing.

```bash
   docker compose exec web bin/rails db:seed
```

4. **Access the application**
   
   Open your browser to: http://localhost:3000


## Running Tests Locally

This project uses RSpec for testing.

### First Time Setup

Make sure to set the .env file as mentioned previously.

Install dependencies and set up the test database:

```bash
# Install gems
bundle install

# Set up test database
rails db:test:prepare
```

### Running Tests

Run all tests:

```bash
bundle exec rspec
```

## Improvements
- The authentication layer needs to be implemented
- We need to add search bars because users and products could grow infinitely
- A flow for CI/CD should be added (For now, Rubocop was used for formatting)
- Business improvements: bulk license upload, analytics, better expiration system, notifications.

## Project Architecture
The application follows a standard MVC structure, with most features handled through CRUD controllers.

The license assignment flow, however, involves multiple models and more complex logic, so it is encapsulated in a dedicated **service object**. This service coordinates the assignment process and wraps the operation in a **database transaction** to ensure consistency and prevent overassignment.

The License Assignment view uses Turbo Streams to give the user a responsive single-page application experience while maintaining Rails' server-side rendering paradigm.


Simplified project structure:

```
license_management_system/
├── app/
│   ├── controllers/
│   │   ├── ...
│   │
│   ├── models/
│   │   ├── ...
│   │
│   ├── services/
│   │   └── license_assignment_service.rb
│   │
│   ├── views/
│   │   ├── ...
│   │   │
│   │   └── shared/
│   │       └── _flash_messages.html.erb
│
├── db/
│   ├── migrate/
│   │   ├── ...
│   │
│   ├── seeds.rb
│   └── schema.rb
│
├── spec/
│   ├── factories/
│   │   ...
│   ├── models/
│   │   ...
│   │
│   ├── services/
│   │   └── ...
│   │
│   ├── requests/
│   │   └── ...
│   │
│   ├── rails_helper.rb
│   └── spec_helper.rb
...
```

## Data Modeling

The schema implements a relational model with foreign key constraints and cascading deletes to maintain referential integrity. A compound unique index on `user_id` and `product_id` in license_assignments prevents duplicate licenses, ensuring each user holds at most one license per product. Critical operations are wrapped in database transactions to guarantee atomicity; during bulk assignments, either all licenses are created or none are, preventing partial states and maintaining data consistency.

## Tech Stack

- Ruby 3.4.7
- Rails 8.1.1
- PostgreSQL 17
- Bootstrap 5 (via CDN)
- RSpec (testing)
- FactoryBot (test fixtures)
- TurboStreams (single-page experience)


##### Created by David Goudet - November 2025