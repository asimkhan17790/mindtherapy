const express = require('express');
const Affirmation = require('../models/Affirmation');
const router = express.Router();

// GET /api/affirmations/random - Get random affirmation
router.get('/random', async (req, res) => {
  try {
    const count = await Affirmation.countDocuments();
    
    if (count === 0) {
      // Fallback affirmation if database is empty
      return res.json({
        message: "You are stronger than you think, and you've got this! 💪",
        category: "motivation"
      });
    }
    
    const random = Math.floor(Math.random() * count);
    const affirmation = await Affirmation.findOne().skip(random);
    
    res.json(affirmation);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching affirmation', error: error.message });
  }
});

// GET /api/affirmations - Get all affirmations
router.get('/', async (req, res) => {
  try {
    const affirmations = await Affirmation.find();
    res.json(affirmations);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching affirmations', error: error.message });
  }
});

// POST /api/affirmations - Create new affirmation
router.post('/', async (req, res) => {
  try {
    const affirmation = new Affirmation(req.body);
    await affirmation.save();
    res.status(201).json(affirmation);
  } catch (error) {
    res.status(400).json({ message: 'Error creating affirmation', error: error.message });
  }
});

module.exports = router;