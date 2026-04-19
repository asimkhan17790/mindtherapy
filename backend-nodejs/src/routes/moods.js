const express = require('express');
const Mood = require('../models/Mood');
const { authenticateToken } = require('./auth');
const router = express.Router();

// POST /api/mood - Save mood entry
router.post('/', authenticateToken, async (req, res) => {
  try {
    const moodData = { ...req.body, userId: req.user._id };
    const mood = new Mood(moodData);
    await mood.save();
    res.status(201).json(mood);
  } catch (error) {
    console.error('Mood save error:', error.message);
    res.status(400).json({ message: 'Error saving mood' });
  }
});

// GET /api/mood/history - Get current user's mood history
router.get('/history', authenticateToken, async (req, res) => {
  try {
    const userId = req.user._id;
    const moods = await Mood.find({ userId }).sort({ timestamp: -1 });
    res.json(moods);
  } catch (error) {
    console.error('Mood history error:', error.message);
    res.status(500).json({ message: 'Error fetching moods' });
  }
});

// GET /api/mood/latest - Get current user's latest mood
router.get('/latest', authenticateToken, async (req, res) => {
  try {
    const userId = req.user._id;
    const mood = await Mood.findOne({ userId }).sort({ timestamp: -1 });

    if (!mood) {
      return res.status(404).json({ message: 'No mood entries found for user' });
    }

    res.json(mood);
  } catch (error) {
    console.error('Latest mood error:', error.message);
    res.status(500).json({ message: 'Error fetching latest mood' });
  }
});

// GET /api/mood/today - Get current user's today's mood entries
router.get('/today', authenticateToken, async (req, res) => {
  try {
    const userId = req.user._id;
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const moods = await Mood.find({
      userId,
      timestamp: { $gte: startOfDay, $lte: endOfDay }
    }).sort({ timestamp: -1 });

    res.json(moods);
  } catch (error) {
    console.error('Today moods error:', error.message);
    res.status(500).json({ message: 'Error fetching today\'s moods' });
  }
});

module.exports = router;