const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// In-memory data for demo
const affirmations = [
  {
    id: '1',
    message: "You are stronger than you think, and you've got this! 💪",
    category: 'motivation'
  },
  {
    id: '2', 
    message: "You deserve love and kindness, especially from yourself 💖",
    category: 'self-love'
  },
  {
    id: '3',
    message: "This feeling is temporary. You will get through this 🌈",
    category: 'strength'
  },
  {
    id: '4',
    message: "Take a deep breath. You belong here and you matter 🫶",
    category: 'mindfulness'
  },
  {
    id: '5',
    message: "Every small step forward is progress worth celebrating ✨",
    category: 'motivation'
  }
];

const tasks = [
  {
    id: '1',
    title: 'Call someone you love',
    description: 'Reach out to family or friends. Connection heals the heart.',
    moodTags: ['sad', 'neutral'],
    category: 'family',
    estimatedMinutes: 10
  },
  {
    id: '2',
    title: 'Take 5 deep breaths',
    description: 'Focus on your breathing and be present in this moment.',
    moodTags: ['sad', 'neutral'],
    category: 'self-care',
    estimatedMinutes: 5
  },
  {
    id: '3',
    title: 'Go for a 10-minute walk',
    description: 'Fresh air and movement can shift your energy.',
    moodTags: ['neutral', 'sad'],
    category: 'activity',
    estimatedMinutes: 10
  },
  {
    id: '4',
    title: 'Write 3 things you\'re grateful for',
    description: 'Gratitude shifts our perspective to abundance.',
    moodTags: ['neutral', 'happy'],
    category: 'self-care',
    estimatedMinutes: 5
  },
  {
    id: '5',
    title: 'Listen to your favorite song',
    description: 'Music can lift your spirits and connect you to joy.',
    moodTags: ['sad', 'neutral', 'happy'],
    category: 'activity',
    estimatedMinutes: 5
  },
  {
    id: '6',
    title: 'Do a 2-minute meditation',
    description: 'Even a short practice can bring peace and clarity.',
    moodTags: ['sad', 'neutral'],
    category: 'self-care',
    estimatedMinutes: 2
  },
  {
    id: '7',
    title: 'Text a friend you haven\'t talked to',
    description: 'Reconnecting can bring unexpected joy to both of you.',
    moodTags: ['neutral', 'happy'],
    category: 'social',
    estimatedMinutes: 5
  }
];

let moods = [];

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'mindtherapy-api',
    message: 'Running with in-memory data for demo'
  });
});

// Affirmations
app.get('/api/affirmations/random', (req, res) => {
  const randomIndex = Math.floor(Math.random() * affirmations.length);
  const affirmation = affirmations[randomIndex];
  res.json(affirmation);
});

app.get('/api/affirmations', (req, res) => {
  res.json(affirmations);
});

// Moods
app.post('/api/mood', (req, res) => {
  const mood = {
    id: Date.now().toString(),
    ...req.body,
    timestamp: new Date().toISOString()
  };
  moods.unshift(mood); // Add to beginning
  res.status(201).json(mood);
});

app.get('/api/mood/user/:userId', (req, res) => {
  const { userId } = req.params;
  const userMoods = moods.filter(mood => mood.userId === userId);
  res.json(userMoods);
});

app.get('/api/mood/user/:userId/latest', (req, res) => {
  const { userId } = req.params;
  const userMoods = moods.filter(mood => mood.userId === userId);
  
  if (userMoods.length === 0) {
    return res.status(404).json({ message: 'No mood entries found for user' });
  }
  
  res.json(userMoods[0]);
});

// Tasks
app.get('/api/tasks/suggestions', (req, res) => {
  const { mood } = req.query;
  let suggestions;
  
  if (mood) {
    suggestions = tasks.filter(task => task.moodTags.includes(mood));
  } else {
    suggestions = tasks;
  }
  
  // Limit to 5 suggestions and randomize
  const shuffled = suggestions.sort(() => 0.5 - Math.random());
  res.json(shuffled.slice(0, 5));
});

app.get('/api/tasks', (req, res) => {
  res.json(tasks);
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Endpoint not found' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`🚀 MindTherapy API running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`✨ Random affirmation: http://localhost:${PORT}/api/affirmations/random`);
  console.log(`📝 Task suggestions: http://localhost:${PORT}/api/tasks/suggestions?mood=sad`);
  console.log(`💾 Using in-memory data for demo`);
});