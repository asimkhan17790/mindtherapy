const express = require('express');
const Mood = require('../models/Mood');
const router = express.Router();

// POST /api/mood - Save mood entry
router.post('/', async (req, res) => {
  try {
    const mood = new Mood(req.body);
    await mood.save();
    res.status(201).json(mood);
  } catch (error) {
    res.status(400).json({ message: 'Error saving mood', error: error.message });
  }
});

// GET /api/mood/user/:userId - Get user's mood history
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const moods = await Mood.find({ userId }).sort({ timestamp: -1 });
    res.json(moods);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching moods', error: error.message });
  }
});

// GET /api/mood/user/:userId/latest - Get user's latest mood
router.get('/user/:userId/latest', async (req, res) => {
  try {
    const { userId } = req.params;
    const mood = await Mood.findOne({ userId }).sort({ timestamp: -1 });
    
    if (!mood) {
      return res.status(404).json({ message: 'No mood entries found for user' });
    }
    
    res.json(mood);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching latest mood', error: error.message });
  }
});

// GET /api/mood/user/:userId/today - Get today's mood entries
router.get('/user/:userId/today', async (req, res) => {
  try {
    const { userId } = req.params;
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
    res.status(500).json({ message: 'Error fetching today\'s moods', error: error.message });
  }
});

module.exports = router;