const express = require('express');
const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// JWT Secret (should be in environment variables)
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key';

// Middleware to verify JWT token
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  let token = authHeader && authHeader.split(' ')[1];

  // Ensure token is a string and trim whitespace
  if (token && typeof token === 'string') {
    token = token.trim();
  }

  if (!token) {
    return res.status(401).json({ message: 'Access token required' });
  }

  try {
    // Support demo tokens produced by the web client when Google ID token is not available
    // Format: "google-demo-token-<googleId>" (case-insensitive prefix)
    const DEMO_PREFIX = 'google-demo-token-';
    if (typeof token === 'string' && token.toLowerCase().startsWith(DEMO_PREFIX)) {
      const demoId = token.slice(DEMO_PREFIX.length);
      // Trim demoId as well
      const demoIdTrimmed = demoId.trim();
      const demoUserId = demoIdTrimmed;
      let demoUser = await User.findOne({ googleId: demoUserId });
      if (!demoUser) {
        // Create a lightweight demo user record so routes that expect a user work seamlessly
        demoUser = new User({
          googleId: demoUserId,
          email: `${demoUserId}@demo.local`,
          name: `Demo User ${demoUserId}`,
          isActive: true,
          lastLogin: new Date()
        });
        await demoUser.save();
      }
      req.user = demoUser;
      return next();
    }
    
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(decoded.userId);
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({ message: 'Invalid token' });
  }
};

// Google Sign-In endpoint
router.post('/google-signin', async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: 'ID token is required' });
    }

    // Verify Google ID token
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const googleId = payload['sub'];
    const email = payload['email'];
    const name = payload['name'];
    const picture = payload['picture'];

    // Find or create user
    let user = await User.findOne({ googleId });

    if (!user) {
      // Check if user exists with same email
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        // Update existing user with Google ID
        user = await User.findByIdAndUpdate(
          existingUser._id,
          {
            googleId,
            name,
            picture,
            lastLogin: new Date()
          },
          { new: true }
        );
      } else {
        // Create new user
        user = new User({
          googleId,
          email,
          name,
          picture,
          lastLogin: new Date()
        });
        await user.save();
      }
    } else {
      // Update last login and other info
      user.lastLogin = new Date();
      user.name = name;
      user.picture = picture;
      await user.save();
    }

    // Generate JWT token
    const accessToken = jwt.sign(
      { userId: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        picture: user.picture,
        preferences: user.preferences
      },
      accessToken
    });

  } catch (error) {
    console.error('Google sign-in error:', error);
    res.status(400).json({
      success: false,
      message: 'Invalid Google token or authentication failed'
    });
  }
});

// Get current user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = req.user;
    res.json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        picture: user.picture,
        preferences: user.preferences,
        createdAt: user.createdAt,
        lastLogin: user.lastLogin
      }
    });
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch profile' });
  }
});

// Update user preferences
router.put('/preferences', authenticateToken, async (req, res) => {
  try {
    const { preferences } = req.body;
    const userId = req.user._id;

    const user = await User.findByIdAndUpdate(
      userId,
      { preferences },
      { new: true }
    );

    res.json({
      success: true,
      preferences: user.preferences
    });
  } catch (error) {
    console.error('Preferences update error:', error);
    res.status(500).json({ success: false, message: 'Failed to update preferences' });
  }
});

// Sign out endpoint
router.post('/signout', authenticateToken, async (req, res) => {
  try {
    // For JWT, we don't need to do server-side logout
    // Client should remove the token
    res.json({ success: true, message: 'Signed out successfully' });
  } catch (error) {
    console.error('Sign out error:', error);
    res.status(500).json({ success: false, message: 'Sign out failed' });
  }
});

// Verify token endpoint
router.get('/verify', authenticateToken, async (req, res) => {
  res.json({
    success: true,
    valid: true,
    userId: req.user._id
  });
});

module.exports = { router, authenticateToken };