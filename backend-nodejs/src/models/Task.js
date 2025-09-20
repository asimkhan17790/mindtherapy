const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  moodTags: [{
    type: String,
    enum: ['happy', 'neutral', 'sad'],
    // index is provided via taskSchema.index({ moodTags: 1 }) below — avoid field-level and schema-level duplicates
  }],
  category: {
    type: String,
    required: true,
    enum: ['family', 'self-care', 'activity', 'creativity', 'social'],
    index: true
  },
  estimatedMinutes: {
    type: Number,
    min: 1,
    max: 120,
    required: true
  }
}, {
  timestamps: true
});

// Index for mood-based queries
taskSchema.index({ moodTags: 1 });

module.exports = mongoose.model('Task', taskSchema);