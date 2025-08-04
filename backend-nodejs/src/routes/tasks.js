const express = require('express');
const Task = require('../models/Task');
const router = express.Router();

// GET /api/tasks/suggestions - Get task suggestions based on mood
router.get('/suggestions', async (req, res) => {
  try {
    const { mood } = req.query;
    let query = {};
    
    if (mood) {
      query.moodTags = { $in: [mood] };
    }
    
    const tasks = await Task.find(query).limit(5);
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching task suggestions', error: error.message });
  }
});

// GET /api/tasks - Get all tasks
router.get('/', async (req, res) => {
  try {
    const tasks = await Task.find();
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching tasks', error: error.message });
  }
});

// POST /api/tasks - Create new task
router.post('/', async (req, res) => {
  try {
    const task = new Task(req.body);
    await task.save();
    res.status(201).json(task);
  } catch (error) {
    res.status(400).json({ message: 'Error creating task', error: error.message });
  }
});

// GET /api/tasks/category/:category - Get tasks by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const tasks = await Task.find({ category });
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching tasks by category', error: error.message });
  }
});

module.exports = router;