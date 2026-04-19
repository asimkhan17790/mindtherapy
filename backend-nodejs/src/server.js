const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const affirmationRoutes = require('./routes/affirmations');
const moodRoutes = require('./routes/moods');
const taskRoutes = require('./routes/tasks');
const { router: authRoutes } = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['http://localhost:8081', 'http://localhost:3000'];

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
}));
app.use(morgan('short'));
app.use(express.json({ limit: '10kb' }));

// Connect to MongoDB (use MONGODB_URI env var, fallback to local)
const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/mindtherapy';

// Optional: set strictQuery to avoid deprecation warnings in newer Mongoose
mongoose.set('strictQuery', true);

mongoose.connect(mongoUri)
  .then(() => console.log(`Connected to MongoDB (${mongoUri.startsWith('mongodb://localhost') ? 'local' : 'remote'})`))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    // Exit process if DB connection fails in production mode
    // (in dev you may want to fallback to demo mode instead)
    process.exit(1);
  });

// Routes
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/affirmations', apiLimiter, affirmationRoutes);
app.use('/api/mood', apiLimiter, moodRoutes);
app.use('/api/tasks', apiLimiter, taskRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'mindtherapy-api'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Endpoint not found' });
});

app.listen(PORT, () => {
  console.log(`🚀 MindTherapy API running on port ${PORT}`);
});