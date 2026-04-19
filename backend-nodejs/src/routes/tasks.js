const express = require('express');
const Task = require('../models/Task');
const { authenticateToken } = require('./auth');
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
    console.error('Task suggestions error:', error.message);
    res.status(500).json({ message: 'Error fetching task suggestions' });
  }
});

// GET /api/tasks - Get all tasks
router.get('/', async (req, res) => {
  try {
    const tasks = await Task.find();
    res.json(tasks);
  } catch (error) {
    console.error('Tasks fetch error:', error.message);
    res.status(500).json({ message: 'Error fetching tasks' });
  }
});

// POST /api/tasks - Create new task (auth required)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const task = new Task(req.body);
    await task.save();
    res.status(201).json(task);
  } catch (error) {
    console.error('Task create error:', error.message);
    res.status(400).json({ message: 'Error creating task' });
  }
});

// GET /api/tasks/category/:category - Get tasks by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const tasks = await Task.find({ category });
    res.json(tasks);
  } catch (error) {
    console.error('Tasks by category error:', error.message);
    res.status(500).json({ message: 'Error fetching tasks by category' });
  }
});

module.exports = router;