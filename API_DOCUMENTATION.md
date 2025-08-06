# Good Night API Documentation

## Overview
The Good Night API allows users to track their sleep patterns and follow other users to see their friends' sleep records. This RESTful JSON API provides endpoints for clocking in/out of sleep sessions, managing follow relationships, and retrieving sleep data.

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication
Currently, the API does not require authentication. User identification is handled through user IDs in the URL path.

## Error Handling
All endpoints return appropriate HTTP status codes and JSON error messages:

```json
{
  "error": "User not found"
}
```

Common HTTP status codes:
- `200 OK` - Successful request
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error

---

## Endpoints

### 1. Clock In/Out
Track sleep sessions by clocking in when going to bed and clocking out when waking up.

**Endpoint:** `POST /api/v1/users/:user_id/clock_in`

**Description:** 
- If user has no active sleep session: Creates a new sleep record with clock_in time
- If user has an active sleep session: Completes the session by setting clock_out time

**Parameters:**
- `user_id` (path parameter, required): The ID of the user clocking in/out

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
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "User not found"
}
```

**Example Usage:**
```bash
# Clock in for user ID 1
curl -X POST http://localhost:3000/api/v1/users/1/clock_in

# Clock out (same endpoint - toggles based on current state)
curl -X POST http://localhost:3000/api/v1/users/1/clock_in
```

---

### 2. Follow User
Create a follow relationship between two users.

**Endpoint:** `POST /api/v1/users/:user_id/follow/:id`

**Description:** User with `user_id` follows the user with `id`.

**Parameters:**
- `user_id` (path parameter, required): The ID of the user who wants to follow
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
# User 1 follows user 2
curl -X POST http://localhost:3000/api/v1/users/1/follow/2
```

---

### 3. Unfollow User
Remove a follow relationship between two users.

**Endpoint:** `DELETE /api/v1/users/:user_id/follow/:id`

**Description:** User with `user_id` unfollows the user with `id`.

**Parameters:**
- `user_id` (path parameter, required): The ID of the user who wants to unfollow
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
# User 1 unfollows user 2
curl -X DELETE http://localhost:3000/api/v1/users/1/follow/2
```

---

### 4. Get Following Users' Sleep Records
Retrieve sleep records from all users that the specified user follows, from the previous week, sorted by sleep duration.

**Endpoint:** `GET /api/v1/users/:user_id/following_sleep_records`

**Description:** Returns completed sleep records from followed users in the past week, ordered by duration (longest sleep first).

**Parameters:**
- `user_id` (path parameter, required): The ID of the user requesting the data

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
# Get sleep records from users that user 1 follows
curl http://localhost:3000/api/v1/users/1/following_sleep_records
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

## Usage Examples

### Complete Workflow Example

1. **Create sleep session:**
```bash
curl -X POST http://localhost:3000/api/v1/users/1/clock_in
```

2. **Follow another user:**
```bash
curl -X POST http://localhost:3000/api/v1/users/1/follow/2
```

3. **Complete sleep session:**
```bash
curl -X POST http://localhost:3000/api/v1/users/1/clock_in
```

4. **View friends' sleep patterns:**
```bash
curl http://localhost:3000/api/v1/users/1/following_sleep_records
```

### Example Response Format for Following Sleep Records

The third requirement asks for sleep records sorted by duration. Here's the expected format:

```json
[
  {
    "id": 101,
    "user_name": "User A",
    "clock_in": "2025-08-05T22:00:00.000Z",
    "clock_out": "2025-08-06T08:00:00.000Z",
    "duration_hours": 10.0,
    "created_at": "2025-08-05T22:00:00.000Z"
  },
  {
    "id": 203,
    "user_name": "User B", 
    "clock_in": "2025-08-05T23:30:00.000Z",
    "clock_out": "2025-08-06T07:00:00.000Z",
    "duration_hours": 7.5,
    "created_at": "2025-08-05T23:30:00.000Z"
  },
  {
    "id": 102,
    "user_name": "User A",
    "clock_in": "2025-08-04T21:00:00.000Z", 
    "clock_out": "2025-08-05T04:30:00.000Z",
    "duration_hours": 7.5,
    "created_at": "2025-08-04T21:00:00.000Z"
  }
]
```

This format shows records from multiple users (A, B, A, etc.) sorted by sleep duration as requested.

---

## Performance Considerations

- **Caching**: Following sleep records are cached for 1 hour
- **Database Indexes**: Optimized queries with proper indexing
- **Query Optimization**: Uses efficient joins and scopes to minimize database load
- **Response Size**: Large result sets may benefit from pagination in future versions

## Rate Limiting
Currently no rate limiting is implemented. Consider implementing rate limiting for production use.

## Future Enhancements
- User authentication and authorization
- Pagination for large datasets  
- WebSocket support for real-time updates
- Sleep statistics and analytics endpoints
- Profile management endpoints