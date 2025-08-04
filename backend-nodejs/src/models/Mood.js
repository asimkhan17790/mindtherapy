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
    enum: ['happy', 'neutral', 'sad'],
    index: true
  },
  notes: {
    type: String,
    maxlength: 500
  },
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