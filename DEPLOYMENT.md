# HousingNator Deployment Information

## Project Overview
HousingNator is a comprehensive housing rental application that helps users find traditional and non-traditional rental options.

## Infrastructure Setup ✅

### GitHub Repository
- **Repository**: https://github.com/awilber/housingnator
- **Main Branch**: `main` (protected, deployment branch)
- **Development Branch**: `develop` (active development)
- **GitFlow**: Implemented with feature branches merging to develop

### AWS Infrastructure
- **Account ID**: 437878371059
- **Region**: us-east-1 (US East - N. Virginia)
- **ECR Repositories**:
  - `437878371059.dkr.ecr.us-east-1.amazonaws.com/housingnator-client`
  - `437878371059.dkr.ecr.us-east-1.amazonaws.com/housingnator-server`

### EC2 Instance
- **Instance ID**: i-0adc481204ac98347
- **Public IP**: 13.218.129.214
- **Instance Type**: t3.micro
- **Key Pair**: bolaquent-key
- **Security Group**: sg-0c2afdbd33d05cc47 (default)

## CI/CD Pipeline ✅

### GitHub Actions Workflows
1. **CI Workflow** (`.github/workflows/ci.yml`)
   - Runs on push to `main` and `develop`
   - Runs on pull requests to `main` and `develop`
   - Tests: Node.js 18 & 20, linting, type checking, tests, build

2. **Deploy Workflow** (`.github/workflows/deploy.yml`)
   - Runs on push to `main` branch
   - Builds Docker images
   - Pushes to ECR
   - Updates ECS services (when ECS is configured)

### GitHub Secrets Configured
- `AWS_ACCESS_KEY_ID`: AKIAWL44VWLZ5SC33TUJ
- `AWS_SECRET_ACCESS_KEY`: [configured]
- `ECR_REGISTRY`: 437878371059.dkr.ecr.us-east-1.amazonaws.com

## Project Structure ✅

### Workspace Architecture
```
housingnator/
├── client/          # React frontend (Vite + TypeScript)
├── server/          # Express backend (Node.js + TypeScript)
├── shared/          # Shared types and utilities
├── .github/         # GitHub Actions workflows & issue templates
└── docker-compose.yml  # Local development environment
```

### Client Application
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Styling**: CSS with modern features
- **Port**: 3000 (development)
- **Docker**: Nginx-based production container

### Server Application
- **Framework**: Express + TypeScript
- **Database**: PostgreSQL (with Prisma ORM planned)
- **Port**: 4000 (development)
- **Health Check**: `/api/health`
- **Docker**: Node.js-based container

## GitHub Issues & Project Management ✅

### Issue Templates
- **Bug Report**: Comprehensive bug reporting with environment details
- **Feature Request**: Structured feature planning with acceptance criteria
- **Epic**: Large feature planning with business value and dependencies

### Created Issues
- **Epic #1**: Core Housing Search Platform
- **Issue #2**: Basic property search and listing functionality

## Development Workflow

### GitFlow Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Submit PR to `develop`
4. After review, merge to `develop`
5. When ready for release, merge `develop` to `main`
6. `main` branch triggers production deployment

### Local Development
```bash
# Install dependencies
npm install

# Start development servers
npm run dev

# Or use Docker
npm run docker:up
```

### CI/CD Process
1. **Push to develop**: Triggers CI tests
2. **Push to main**: Triggers CI tests + production deployment
3. **Docker images**: Built and pushed to ECR
4. **ECS deployment**: Automatic service updates (when configured)

## Next Steps

### Immediate Tasks
1. Configure ECS cluster and services for production deployment
2. Set up RDS PostgreSQL database
3. Configure Application Load Balancer
4. Implement domain and SSL certificates

### Development Tasks
1. Implement property search functionality (Issue #2)
2. Add user authentication system
3. Create property management interface
4. Add payment processing integration

## Monitoring & Maintenance

### Health Checks
- **Server Health**: http://13.218.129.214:4000/api/health
- **Client Health**: http://13.218.129.214:3000/health

### Security Considerations
- All secrets stored in GitHub Secrets
- Docker containers run as non-root users
- Security headers implemented in nginx
- Rate limiting configured on API endpoints

## Contact Information
- **Project Owner**: Arlon Wilber (awilber@wiredtriangle.com)
- **Repository**: https://github.com/awilber/housingnator
- **AWS Account**: 437878371059