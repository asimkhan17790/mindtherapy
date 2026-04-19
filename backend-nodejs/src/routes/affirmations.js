const express = require('express');
const Affirmation = require('../models/Affirmation');
const { authenticateToken } = require('./auth');
const router = express.Router();

// GET /api/affirmations/random - Get random affirmation
router.get('/random', async (req, res) => {
  try {
    // Use aggregation with $sample for a truly random document
    const docs = await Affirmation.aggregate([{ $sample: { size: 1 } }]);

    if (!docs || docs.length === 0) {
      // Fallback affirmation if database is empty
      return res.json({
        message: "You are stronger than you think, and you've got this! 💪",
        category: "motivation"
      });
    }

    res.json(docs[0]);
  } catch (error) {
    console.error('Affirmation fetch error:', error.message);
    res.status(500).json({ message: 'Error fetching affirmation' });
  }
});

// GET /api/affirmations - Get all affirmations
router.get('/', async (req, res) => {
  try {
    const affirmations = await Affirmation.find();
    res.json(affirmations);
  } catch (error) {
    console.error('Affirmations fetch error:', error.message);
    res.status(500).json({ message: 'Error fetching affirmations' });
  }
});

// POST /api/affirmations - Create new affirmation (auth required)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const affirmation = new Affirmation(req.body);
    await affirmation.save();
    res.status(201).json(affirmation);
  } catch (error) {
    console.error('Affirmation create error:', error.message);
    res.status(400).json({ message: 'Error creating affirmation' });
  }
});

module.exports = router;