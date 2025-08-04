const mongoose = require('mongoose');

const affirmationSchema = new mongoose.Schema({
  message: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  category: {
    type: String,
    required: true,
    enum: ['motivation', 'self-love', 'strength', 'gratitude', 'mindfulness'],
    index: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Affirmation', affirmationSchema);