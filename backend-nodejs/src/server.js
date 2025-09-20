const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const affirmationRoutes = require('./routes/affirmations');
const moodRoutes = require('./routes/moods');
const taskRoutes = require('./routes/tasks');
const { router: authRoutes } = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

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
app.use('/api/auth', authRoutes);
app.use('/api/affirmations', affirmationRoutes);
app.use('/api/mood', moodRoutes);
app.use('/api/tasks', taskRoutes);

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