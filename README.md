# Good Night Sleep Tracking API

A Rails 8 REST API application that allows users to track their sleep patterns and follow friends to see their sleep records.

## Features

✅ **JWT Authentication**: Secure user registration and login with JSON Web Tokens

✅ **Clock In/Out System**: Users can clock in when going to bed and clock out when waking up

✅ **Social Following**: Users can follow and unfollow other users  

✅ **Sleep Records Viewing**: See sleep records from followed users from the past week, sorted by duration

✅ **Performance Optimized**: Includes caching, database indexing, and query optimization

✅ **Comprehensive Tests**: Full test coverage for all APIs and models

✅ **Documentation**: Complete API documentation and performance strategy

## Quick Start

### Prerequisites
- Ruby 3.2.7+
- Rails 8.0+
- SQLite3

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd good_night
```

2. **Install dependencies**
```bash
bundle install
```

3. **Setup database**
```bash
rails db:create
rails db:migrate
```

4. **Enable caching and run the application**
```bash
rails dev:cache
rails server
```

The API will be available at `http://localhost:3000`

### Running Tests

```bash
bundle exec rspec
```

All tests should pass, covering models, controllers, and API functionality.

---

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication
The API requires JWT authentication for most endpoints. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

The user is identified from the JWT token, not from URL parameters.

### Error Handling
All endpoints return appropriate HTTP status codes and JSON error messages:

```json
{
  "error": "User not found"
}
```

Common HTTP status codes:
- `200 OK` - Successful request
- `401 Unauthorized` - Missing or invalid authentication token
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error

---

## Endpoints

### Authentication (Public)

#### 1. Sign Up
Create a new user account.

**Endpoint:** `POST /api/v1/signup`

**Request Body:**
```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

#### 2. Login
Authenticate and get JWT token.

**Endpoint:** `POST /api/v1/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Protected Endpoints (Requires JWT Token)

#### 3. Clock In/Out
Track sleep sessions by clocking in when going to bed and clocking out when waking up.

**Endpoint:** `POST /api/v1/clock_in`

**Description:** 
- If user has no active sleep session: Creates a new sleep record with clock_in time
- If user has an active sleep session: Completes the session by setting clock_out time
- User is identified from the JWT token

**Authentication:** Required (JWT token in Authorization header)

**Success Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Clocked in", // or "Clocked out"
  "sleep_records": [
    {
      "id": 1,
      "clock_in": "2025-08-06T22:00:00.000Z",
      "clock_out": null,
      "duration_hours": null,
      "created_at": "2025-08-06T22:00:00.000Z"
    },
    {
      "id": 2,
      "clock_in": "2025-08-05T22:30:00.000Z",
      "clock_out": "2025-08-06T06:30:00.000Z",
      "duration_hours": 8.0,
      "created_at": "2025-08-05T22:30:00.000Z"
    }
  ]
}
```

**Error Response:**
```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "error": "Unauthorized"
}
```

**Example Usage:**
```bash
# Clock in (requires authentication)
curl -X POST http://localhost:3000/api/v1/clock_in \
  -H "Authorization: Bearer <your_jwt_token>"

# Clock out (same endpoint - toggles based on current state)
curl -X POST http://localhost:3000/api/v1/clock_in \
  -H "Authorization: Bearer <your_jwt_token>"
```

#### 4. Follow User
Create a follow relationship between two users.

**Endpoint:** `POST /api/v1/follow/:id`

**Description:** Current authenticated user follows the user with `id`.

**Parameters:**
- `id` (path parameter, required): The ID of the user to be followed

**Success Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Successfully followed user",
  "following": [
    {
      "id": 2,
      "name": "John Doe"
    },
    {
      "id": 3,
      "name": "Jane Smith"
    }
  ]
}
```

**Already Following Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Already following this user",
  "following": [
    {
      "id": 2,
      "name": "John Doe"
    }
  ]
}
```

**Error Response:**
```http
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "error": "Cannot follow yourself"
}
```

**Example Usage:**
```bash
# Follow user 2 (requires authentication)
curl -X POST http://localhost:3000/api/v1/follow/2 \
  -H "Authorization: Bearer <your_jwt_token>"
```

#### 5. Unfollow User
Remove a follow relationship between two users.

**Endpoint:** `DELETE /api/v1/follow/:id`

**Description:** Current authenticated user unfollows the user with `id`.

**Parameters:**
- `id` (path parameter, required): The ID of the user to be unfollowed

**Success Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Successfully unfollowed user",
  "following": [
    {
      "id": 3,
      "name": "Jane Smith"
    }
  ]
}
```

**Not Following Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "message": "Not following this user",
  "following": []
}
```

**Example Usage:**
```bash
# Unfollow user 2 (requires authentication)
curl -X DELETE http://localhost:3000/api/v1/follow/2 \
  -H "Authorization: Bearer <your_jwt_token>"
```

#### 6. Get Following Users' Sleep Records
Retrieve sleep records from all users that the current user follows, from the previous week, sorted by sleep duration.

**Endpoint:** `GET /api/v1/following_sleep_records`

**Description:** Returns completed sleep records from followed users in the past week, ordered by duration (longest sleep first). User is identified from the JWT token.

**Authentication:** Required (JWT token in Authorization header)

**Success Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "id": 15,
    "user_name": "John Doe",
    "clock_in": "2025-08-05T22:00:00.000Z",
    "clock_out": "2025-08-06T07:30:00.000Z",
    "duration_hours": 9.5,
    "created_at": "2025-08-05T22:00:00.000Z"
  },
  {
    "id": 12,
    "user_name": "Jane Smith",
    "clock_in": "2025-08-05T23:00:00.000Z",
    "clock_out": "2025-08-06T07:00:00.000Z",
    "duration_hours": 8.0,
    "created_at": "2025-08-05T23:00:00.000Z"
  },
  {
    "id": 18,
    "user_name": "John Doe",
    "clock_in": "2025-08-04T21:30:00.000Z",
    "clock_out": "2025-08-05T05:00:00.000Z",
    "duration_hours": 7.5,
    "created_at": "2025-08-04T21:30:00.000Z"
  }
]
```

**Empty Response (No Following or No Records):**
```http
HTTP/1.1 200 OK
Content-Type: application/json

[]
```

**Features:**
- **Time Range**: Only includes records from the past 7 days
- **Status Filter**: Only includes completed sleep sessions (with clock_out)
- **Sorting**: Ordered by sleep duration (descending)
- **Caching**: Results are cached for 1 hour for improved performance

**Example Usage:**
```bash
# Get sleep records from users that current user follows (requires authentication)
curl http://localhost:3000/api/v1/following_sleep_records \
  -H "Authorization: Bearer <your_jwt_token>"
```

---

## Data Models

### User
```json
{
  "id": 1,
  "name": "John Doe"
}
```

### Sleep Record
```json
{
  "id": 1,
  "user_id": 1,
  "clock_in": "2025-08-06T22:00:00.000Z",
  "clock_out": "2025-08-06T06:00:00.000Z",
  "duration_hours": 8.0,
  "created_at": "2025-08-06T22:00:00.000Z"
}
```

### Follow Relationship
```json
{
  "id": 1,
  "follower_id": 1,
  "followed_id": 2,
  "created_at": "2025-08-06T12:00:00.000Z"
}
```

---

## Complete Workflow Example

1. **Register a new user:**
```bash
curl -X POST http://localhost:3000/api/v1/signup \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "John Doe",
      "email": "john@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'
```

2. **Login and get JWT token:**
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

3. **Create sleep session:**
```bash
curl -X POST http://localhost:3000/api/v1/clock_in \
  -H "Authorization: Bearer <your_jwt_token>"
```

4. **Follow another user:**
```bash
curl -X POST http://localhost:3000/api/v1/follow/2 \
  -H "Authorization: Bearer <your_jwt_token>"
```

5. **Complete sleep session:**
```bash
curl -X POST http://localhost:3000/api/v1/clock_in \
  -H "Authorization: Bearer <your_jwt_token>"
```

6. **View friends' sleep patterns:**
```bash
curl http://localhost:3000/api/v1/following_sleep_records \
  -H "Authorization: Bearer <your_jwt_token>"
```

---

## Database Schema

### Tables
- **users**: `id`, `name`, `email`, `password_digest`, `created_at`, `updated_at`
- **sleep_records**: `id`, `user_id`, `clock_in`, `clock_out`, `created_at`, `updated_at`
- **follows**: `id`, `follower_id`, `followed_id`, `created_at`, `updated_at`

### Indexes
- Primary keys on all tables
- Foreign key indexes (automatic)
- `users(email)` - unique index for authentication
- `sleep_records(created_at)` - for time-based queries
- `sleep_records(clock_in)` - for sleep time queries  
- `follows(follower_id, followed_id)` - unique composite index

## Performance Features

- **Database Indexing**: Strategic indexes for common query patterns
- **Query Optimization**: Efficient joins and scopes, N+1 query prevention
- **Caching**: Redis-backed caching for expensive operations (1-hour TTL)
- **Optimized Responses**: Database-level calculations and sorting

## Architecture Decisions

### Models
- **User**: Simple model with name field, associations to sleep_records and follows
- **SleepRecord**: Tracks clock_in/clock_out times with duration calculations
- **Follow**: Join table for user relationships with uniqueness constraints

### Business Logic
- Clock in/out toggles based on existing active sleep records
- Only completed sleep records (with clock_out) are shown in following feed
- Following sleep records are sorted by duration (longest first)
- Time filtering limited to previous week for performance

### Performance Strategy
- **Caching Strategy**: User-specific cache keys with date-based invalidation
- **Database Design**: Normalized schema with proper indexing
- **Query Patterns**: Bulk operations, eager loading, database-level sorting

## Testing Strategy

- **Model Tests**: Validations, associations, business logic
- **Controller Tests**: API endpoints, error handling, response formats
- **Integration Tests**: End-to-end API workflows
- **Fixtures**: Realistic test data setup

Coverage includes:
- Model validations and relationships
- API endpoint functionality  
- Error handling and edge cases
- Performance optimization verification

## Technology Stack

- **Framework**: Rails 8.0.2
- **Database**: SQLite3 (development/test), configurable for production
- **Authentication**: JWT with bcrypt password hashing
- **Caching**: solid_cache (Redis-compatible)
- **Testing**: RSpec with comprehensive test coverage
- **Web Server**: Puma

## Future Enhancements

- Advanced user roles and permissions
- Pagination for large datasets
- WebSocket support for real-time updates  
- Sleep analytics and statistics
- Rate limiting and API throttling
- Database read replicas for scaling
- Password reset functionality
- Social features (comments, likes)
- Mobile app integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

