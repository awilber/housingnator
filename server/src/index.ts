import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { config } from 'dotenv';

// Load environment variables
config();

const app = express();
const PORT = process.env.PORT || 4000;

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

// Middleware
app.use(limiter);
app.use(helmet());
app.use(compression());
app.use(morgan('combined'));
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  });
});

// Basic API routes
app.get('/api', (req, res) => {
  res.json({
    message: 'HousingNator API',
    version: '1.0.0',
    documentation: '/api/docs',
  });
});

// Properties endpoint (placeholder)
app.get('/api/properties', (req, res) => {
  res.json({
    properties: [
      {
        id: 1,
        title: 'Modern Downtown Apartment',
        type: 'apartment',
        category: 'traditional',
        price: 2500,
        location: 'Downtown Seattle',
        bedrooms: 2,
        bathrooms: 2,
        amenities: ['parking', 'gym', 'pool'],
      },
      {
        id: 2,
        title: 'Co-living Space in Tech Hub',
        type: 'co-living',
        category: 'non-traditional',
        price: 1200,
        location: 'South Lake Union',
        bedrooms: 1,
        bathrooms: 1,
        amenities: ['workspace', 'community-events', 'cleaning-service'],
      },
    ],
    total: 2,
    page: 1,
    limit: 10,
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method,
  });
});

// Error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 HousingNator API server running on port ${PORT}`);
  console.log(`📚 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🏠 Properties: http://localhost:${PORT}/api/properties`);
});

export default app;