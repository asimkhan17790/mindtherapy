const mongoose = require('mongoose');

const moodSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  moodType: {
    type: String,
    required: true,
    enum: ['amazing', 'happy', 'good', 'neutral', 'low', 'sad', 'anxious', 'angry', 'tired', 'stressed'],
    index: true
  },
  notes: {
    type: String,
    maxlength: 500
  },
  intensity: {
    type: Number,
    min: 1,
    max: 5,
    default: 3
  },
  tags: [{
    type: String,
    enum: ['work', 'family', 'friends', 'health', 'exercise', 'sleep', 'food', 'weather', 'social', 'alone', 'creative', 'learning', 'traveling']
  }],
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: true
});

// Index for efficient queries
moodSchema.index({ userId: 1, timestamp: -1 });

module.exports = mongoose.model('Mood', moodSchema);