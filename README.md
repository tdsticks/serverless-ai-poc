# Serverless AI Application with React Frontend

This project is a serverless AI application with a React frontend, utilizing AWS Lambda and PostgreSQL for backend operations.

The application consists of two main components: a serverless backend API built with Node.js and Express, and a React-based frontend created using Vite. The backend is designed to be deployed on AWS Lambda and connects to a PostgreSQL database. The frontend is a modern, responsive web application that interacts with the backend API.

Key features of this project include:
- Serverless architecture using AWS Lambda
- Express.js backend with PostgreSQL database integration
- React frontend with TypeScript support
- Vite for fast and efficient frontend development
- Environment-based configuration for local development and production deployment

## Repository Structure

The repository is organized into two main directories:

- `dev/serverless-ai/`: Contains the backend API code
  * `app.js`: Main entry point for the Express.js application
  * `package.json`: Node.js project configuration and dependencies
  * `tf/`: Terraform configuration files for infrastructure

- `dev/serverless-al-frontend/`: Contains the frontend React application
  * `src/`: Source code for the React application
  * `vite.config.ts`: Vite configuration file
  * `package.json`: Frontend project configuration and dependencies

Key files:
- `dev/serverless-ai/app.js`: Entry point for the backend API
- `dev/serverless-ai/tf/main.tf`: Main Terraform configuration file
- `dev/serverless-al-frontend/src/main.tsx`: Entry point for the React application
- `dev/serverless-al-frontend/src/App.tsx`: Main React component

## Usage Instructions

### Backend Setup

1. Navigate to the `dev/serverless-ai` directory:
   ```
   cd dev/serverless-ai
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the `dev/serverless-ai` directory with the following content:
   ```
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_HOST=your_db_host
   DB_PORT=your_db_port
   DB_NAME=your_db_name
   ```

4. Start the development server:
   ```
   npm start
   ```

### Frontend Setup

1. Navigate to the `dev/serverless-al-frontend` directory:
   ```
   cd dev/serverless-al-frontend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the `dev/serverless-al-frontend` directory with the following content:
   ```
   VITE_API_URL=http://localhost:3000
   ```

4. Start the development server:
   ```
   npm run dev
   ```

### API Usage

The backend API provides two endpoints:

1. GET `/api`: Returns a simple JSON message
   ```
   curl http://localhost:3000/api
   ```

2. GET `/api/hello`: Returns a JSON object with a message and the current timestamp from the database
   ```
   curl http://localhost:3000/api/hello
   ```

### Frontend Usage

The frontend application is a simple React app with a counter. You can interact with it by clicking the button to increment the counter.

### Testing

Currently, there are no specified tests for either the backend or frontend. It is recommended to add unit tests and integration tests to ensure the reliability of the application.

### Troubleshooting

1. Database Connection Issues:
   - Problem: Unable to connect to the PostgreSQL database
   - Error message: "Database query failed"
   - Diagnostic steps:
     a. Check if the database is running and accessible
     b. Verify the environment variables in the `.env` file
     c. Ensure the database user has the necessary permissions
   - Debug mode: Add `console.log` statements in the `/api/hello` route to log connection details

2. Frontend API Connection Issues:
   - Problem: Frontend unable to connect to the backend API
   - Error message: Network error in the browser console
   - Diagnostic steps:
     a. Check if the backend server is running
     b. Verify the `VITE_API_URL` in the frontend `.env` file
     c. Ensure CORS is properly configured in the backend
   - Debug mode: Use browser developer tools to inspect network requests

### Performance Optimization

- Backend:
  * Monitor database query performance using PostgreSQL's EXPLAIN ANALYZE
  * Implement connection pooling for database connections
  * Use caching mechanisms for frequently accessed data

- Frontend:
  * Implement code splitting and lazy loading for large components
  * Optimize asset sizes using compression and minification
  * Use React.memo or useMemo for expensive computations

## Data Flow

The application follows a typical client-server architecture with a React frontend communicating with a Node.js backend API, which in turn interacts with a PostgreSQL database.

1. User interacts with the React frontend
2. Frontend makes HTTP requests to the backend API
3. Backend API receives requests and processes them
4. If needed, the backend queries the PostgreSQL database
5. Database returns results to the backend
6. Backend processes the data and sends a response to the frontend
7. Frontend updates the UI based on the received data

```
[User] <-> [React Frontend] <-> [Express.js Backend API] <-> [PostgreSQL Database]
```

Important technical considerations:
- The backend uses a connection pool for efficient database interactions
- CORS is enabled on the backend to allow requests from the frontend
- The frontend uses environment variables to configure the API URL

## Infrastructure

The infrastructure for this project is defined using Terraform. Key resources include:

- Lambda:
  * `aws_lambda_function.api`: Hosts the Express.js backend application

- API Gateway:
  * `aws_apigatewayv2_api.lambda`: Provides HTTP API for the Lambda function

- VPC:
  * `aws_vpc.main`: Virtual Private Cloud for isolating resources

- RDS:
  * `aws_db_instance.default`: PostgreSQL database instance

- Security Groups:
  * `aws_security_group.rds`: Controls access to the RDS instance

These resources work together to create a serverless environment for the application, with the API Gateway routing requests to the Lambda function, which then interacts with the RDS database securely within the VPC.