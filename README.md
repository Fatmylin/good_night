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

## API Endpoints

### Authentication (Public)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/signup` | Create new user account |
| `POST` | `/api/v1/login` | Authenticate and get JWT token |

### Protected Endpoints (Requires JWT Token)
| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/clock_in` | Clock in/out for sleep tracking |
| `POST` | `/api/v1/follow/:id` | Follow another user |
| `DELETE` | `/api/v1/follow/:id` | Unfollow a user |
| `GET` | `/api/v1/following_sleep_records` | Get following users' sleep records |

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
rails test
```

All 46 tests should pass, covering models, controllers, and API functionality.

## Usage Examples

### 1. Register a New User
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

### 2. Login and Get JWT Token
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### 3. Clock In for Sleep (Authenticated)
```bash
curl -X POST http://localhost:3000/api/v1/clock_in \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Follow Another User (Authenticated)
```bash
curl -X POST http://localhost:3000/api/v1/follow/:user_id \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 5. Unfollow a User (Authenticated)
```bash
curl -X DELETE http://localhost:3000/api/v1/follow/:user_id \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 6. Get Friends' Sleep Records (Authenticated)
```bash
curl http://localhost:3000/api/v1/following_sleep_records \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

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
- 46 tests total
- Model validations and relationships
- API endpoint functionality  
- Error handling and edge cases
- Performance optimization verification

## Documentation

- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)**: Complete REST API documentation
- **[PERFORMANCE.md](PERFORMANCE.md)**: Detailed performance optimization strategy

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

## License

This project is available under the MIT License.
