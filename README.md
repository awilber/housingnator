# HousingNator

A comprehensive housing rental application that helps users find traditional and non-traditional rental options.

## Features

- **Traditional Rentals**: Apartments, houses, condos through standard rental channels
- **Non-Traditional Options**: Short-term rentals, co-living spaces, rent-to-own, housing cooperatives
- **Advanced Search**: Filter by location, price, amenities, rental type, and more
- **User Profiles**: Save searches, bookmark properties, application tracking
- **Property Management**: For landlords and property managers
- **Real-time Updates**: Property availability and pricing updates

## Tech Stack

- **Frontend**: React with TypeScript, Tailwind CSS
- **Backend**: Node.js with Express, TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: OAuth 2.0 with social providers
- **Cloud**: AWS (ECS, RDS, S3, CloudFront)
- **CI/CD**: GitHub Actions with automated testing and deployment

## Development

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- Docker and Docker Compose
- AWS CLI configured

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/arlonwilber/housingnator.git
   cd housingnator
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your configuration
   ```

4. **Start development servers**
   ```bash
   npm run dev
   ```

### Available Scripts

- `npm run dev` - Start both client and server in development mode
- `npm run build` - Build all workspaces for production
- `npm run test` - Run all tests
- `npm run lint` - Run linting across all workspaces
- `npm run typecheck` - Run TypeScript type checking

### Docker Development

```bash
# Build and start all services
npm run docker:up

# Stop all services
npm run docker:down
```

## Project Structure

```
housingnator/
├── client/          # React frontend application
├── server/          # Express backend API
├── shared/          # Shared types and utilities
├── .github/         # GitHub Actions workflows
├── docker-compose.yml
└── package.json
```

## Deployment

The application is automatically deployed to AWS when changes are pushed to the `main` branch. The deployment pipeline includes:

1. **Build & Test**: All workspaces are built and tested
2. **Docker Images**: Client and server are containerized
3. **AWS ECR**: Images are pushed to Elastic Container Registry
4. **ECS Deployment**: Services are updated with new images
5. **Health Checks**: Deployment verification and rollback if needed

## Contributing

1. Create a feature branch from `develop`
2. Make your changes with appropriate tests
3. Submit a pull request to `develop`
4. After review and approval, changes will be merged

## License

MIT License - see [LICENSE](LICENSE) for details