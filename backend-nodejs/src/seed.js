/**
 * Database seed script — populates MongoDB with initial affirmations and tasks.
 * Usage: node src/seed.js
 * Options: node src/seed.js --clear  (clears existing data before seeding)
 */

require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const Affirmation = require('./models/Affirmation');
const Task = require('./models/Task');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/mindtherapy';
const shouldClear = process.argv.includes('--clear');

// ─── Seed Data ───────────────────────────────────────────────────────────────

const affirmations = [
  // Motivation
  { message: "You are stronger than you think, and you've got this! 💪", category: 'motivation' },
  { message: "Every small step forward is progress worth celebrating ✨", category: 'motivation' },
  { message: "You have survived every difficult day so far. Today is no different.", category: 'motivation' },
  { message: "Your potential is limitless. Keep going, even when it feels hard.", category: 'motivation' },
  { message: "Challenges are just opportunities to grow stronger 🌱", category: 'motivation' },
  { message: "You are capable of amazing things — believe it.", category: 'motivation' },

  // Self-love
  { message: "You deserve love and kindness, especially from yourself 💖", category: 'self-love' },
  { message: "You are enough, exactly as you are right now.", category: 'self-love' },
  { message: "Be gentle with yourself. You are doing the best you can.", category: 'self-love' },
  { message: "Your worth is not measured by your productivity. You matter simply by being.", category: 'self-love' },
  { message: "Treat yourself with the same compassion you'd give a dear friend 🫶", category: 'self-love' },
  { message: "You are worthy of rest, joy, and good things.", category: 'self-love' },

  // Strength
  { message: "This feeling is temporary. You will get through this 🌈", category: 'strength' },
  { message: "You have faced hard things before — and you rose. You will rise again.", category: 'strength' },
  { message: "Difficult roads often lead to beautiful destinations.", category: 'strength' },
  { message: "Your resilience is your superpower. It has carried you this far.", category: 'strength' },
  { message: "Even on hard days, you are still moving forward.", category: 'strength' },
  { message: "You are braver than you believe, stronger than you seem 🦁", category: 'strength' },

  // Gratitude
  { message: "There is beauty in this moment, even if it's hard to see.", category: 'gratitude' },
  { message: "Gratitude turns what we have into enough 🙏", category: 'gratitude' },
  { message: "Notice three things around you that bring you peace.", category: 'gratitude' },
  { message: "Your presence is a gift to those who love you.", category: 'gratitude' },
  { message: "Even small joys deserve to be celebrated.", category: 'gratitude' },
  { message: "Today holds the possibility of something good happening.", category: 'gratitude' },

  // Mindfulness
  { message: "Take a deep breath. You belong here and you matter 🫶", category: 'mindfulness' },
  { message: "You don't have to carry everything alone. One breath at a time.", category: 'mindfulness' },
  { message: "This moment is the only one that truly exists. You are here. That is enough.", category: 'mindfulness' },
  { message: "Let go of what you cannot control. Focus on what you can. 🌿", category: 'mindfulness' },
  { message: "Peace is not the absence of problems — it's the presence of calm within them.", category: 'mindfulness' },
  { message: "Ground yourself. Feel your feet on the floor. You are safe.", category: 'mindfulness' },
];

const tasks = [
  // ── Family & Connection ──────────────────────────────────────────────────
  {
    title: 'Call someone you love',
    description: 'Reach out to a family member or close friend. Even a 5-minute check-in can lift both your spirits. Connection is one of the most powerful healers.',
    moodTags: ['sad', 'low', 'anxious', 'stressed'],
    category: 'family',
    estimatedMinutes: 10,
  },
  {
    title: 'Send a kind message',
    description: 'Text or message someone and let them know you\'re thinking of them. A small act of love creates ripples of warmth.',
    moodTags: ['neutral', 'good', 'happy'],
    category: 'family',
    estimatedMinutes: 5,
  },
  {
    title: 'Share a meal with someone',
    description: 'Invite someone to eat together — even virtually. Sharing food is one of the oldest forms of human connection.',
    moodTags: ['sad', 'low', 'neutral'],
    category: 'family',
    estimatedMinutes: 30,
  },
  {
    title: 'Write a letter to a loved one',
    description: 'Write a heartfelt letter to someone who matters to you — you don\'t have to send it. Express appreciation, love, or whatever is on your heart.',
    moodTags: ['sad', 'low', 'neutral', 'good'],
    category: 'family',
    estimatedMinutes: 20,
  },

  // ── Self-care ────────────────────────────────────────────────────────────
  {
    title: 'Take 5 deep breaths',
    description: 'Breathe in slowly for 4 counts, hold for 4, release for 4. Repeat 5 times. This simple practice activates your body\'s calming response.',
    moodTags: ['anxious', 'stressed', 'angry', 'sad'],
    category: 'self-care',
    estimatedMinutes: 5,
  },
  {
    title: 'Write 3 things you\'re grateful for',
    description: 'Gratitude rewires the brain toward positivity. Think of three things — big or small — that you appreciate right now.',
    moodTags: ['neutral', 'good', 'happy', 'amazing'],
    category: 'self-care',
    estimatedMinutes: 5,
  },
  {
    title: 'Take a warm shower or bath',
    description: 'Warmth soothes the nervous system. Let the water wash away tension. Take your time — this is care for your body and mind.',
    moodTags: ['sad', 'stressed', 'tired', 'anxious'],
    category: 'self-care',
    estimatedMinutes: 20,
  },
  {
    title: 'Drink a glass of water',
    description: 'Sometimes the simplest acts of self-care matter most. Hydrate your body — it\'s an act of love toward yourself.',
    moodTags: ['tired', 'low', 'neutral', 'stressed'],
    category: 'self-care',
    estimatedMinutes: 2,
  },
  {
    title: 'Spend 10 minutes doing nothing',
    description: 'Give yourself permission to just be. No phone, no tasks. Sit quietly and let your mind rest. You deserve stillness.',
    moodTags: ['stressed', 'anxious', 'tired', 'angry'],
    category: 'self-care',
    estimatedMinutes: 10,
  },
  {
    title: 'Journal your feelings',
    description: 'Write whatever comes to mind without judgment. Getting thoughts out of your head and onto paper can bring surprising clarity and relief.',
    moodTags: ['sad', 'anxious', 'angry', 'stressed', 'neutral'],
    category: 'self-care',
    estimatedMinutes: 15,
  },

  // ── Activity ─────────────────────────────────────────────────────────────
  {
    title: 'Go for a 10-minute walk',
    description: 'Fresh air and gentle movement can shift your energy and clear your head. You don\'t need a destination — just move.',
    moodTags: ['neutral', 'low', 'tired', 'sad'],
    category: 'activity',
    estimatedMinutes: 10,
  },
  {
    title: 'Do a 5-minute stretch',
    description: 'Roll your shoulders, stretch your arms, reach for the sky. Tension lives in the body — releasing it helps your mind too.',
    moodTags: ['tired', 'stressed', 'low', 'neutral'],
    category: 'activity',
    estimatedMinutes: 5,
  },
  {
    title: 'Dance to one song',
    description: 'Put on a song that makes you feel something and just move. No rules, no judgment. Let your body express what words can\'t.',
    moodTags: ['good', 'happy', 'amazing', 'neutral'],
    category: 'activity',
    estimatedMinutes: 5,
  },
  {
    title: 'Step outside for fresh air',
    description: 'Even 2 minutes outside can reset your nervous system. Feel the air, look at the sky. Nature is always there to receive you.',
    moodTags: ['anxious', 'stressed', 'tired', 'sad'],
    category: 'activity',
    estimatedMinutes: 5,
  },
  {
    title: 'Do 10 jumping jacks',
    description: 'Quick movement releases endorphins. A short burst of activity can shift your mood almost instantly.',
    moodTags: ['low', 'tired', 'sad', 'neutral'],
    category: 'activity',
    estimatedMinutes: 3,
  },

  // ── Creativity ───────────────────────────────────────────────────────────
  {
    title: 'Listen to your favorite song',
    description: 'Music has a direct line to emotion. Put on a song that lifts you, comforts you, or simply makes you feel understood.',
    moodTags: ['sad', 'low', 'neutral', 'good'],
    category: 'creativity',
    estimatedMinutes: 5,
  },
  {
    title: 'Doodle or draw freely',
    description: 'Grab any pen and paper and draw without any goal. Let your hand move however it wants. Creative flow is therapeutic.',
    moodTags: ['neutral', 'good', 'anxious', 'stressed'],
    category: 'creativity',
    estimatedMinutes: 10,
  },
  {
    title: 'Write a poem or a few lines',
    description: 'Don\'t worry about it being good. Just let words flow. Poetry gives form to feelings that are hard to explain.',
    moodTags: ['sad', 'neutral', 'good', 'low'],
    category: 'creativity',
    estimatedMinutes: 15,
  },
  {
    title: 'Cook or bake something',
    description: 'Creating food is grounding and satisfying. The focus required gives your mind a break, and you get something delicious at the end.',
    moodTags: ['good', 'happy', 'amazing', 'neutral'],
    category: 'creativity',
    estimatedMinutes: 30,
  },
  {
    title: 'Watch a comforting show or movie',
    description: 'There\'s real value in comfort media. Let yourself be held by a story. Rest your mind with something familiar and warm.',
    moodTags: ['tired', 'sad', 'low', 'anxious'],
    category: 'creativity',
    estimatedMinutes: 45,
  },

  // ── Social ───────────────────────────────────────────────────────────────
  {
    title: 'Share how you\'re feeling with someone',
    description: 'Tell one trusted person how you\'re doing today — honestly. Being seen and heard is deeply healing.',
    moodTags: ['sad', 'anxious', 'low', 'stressed'],
    category: 'social',
    estimatedMinutes: 15,
  },
  {
    title: 'Do something kind for a stranger',
    description: 'Hold a door, give a compliment, or smile at someone. Small acts of kindness benefit the giver as much as the receiver.',
    moodTags: ['good', 'happy', 'amazing', 'neutral'],
    category: 'social',
    estimatedMinutes: 5,
  },
  {
    title: 'Plan something to look forward to',
    description: 'Anticipation itself is joyful. Plan a small treat, outing, or activity — even something a week away can lighten today.',
    moodTags: ['neutral', 'good', 'low', 'sad'],
    category: 'social',
    estimatedMinutes: 10,
  },
  {
    title: 'Join an online community or group',
    description: 'Connect with others who share your interests or experiences. You don\'t have to go through things alone.',
    moodTags: ['low', 'sad', 'neutral', 'anxious'],
    category: 'social',
    estimatedMinutes: 20,
  },
];

// ─── Seed Logic ───────────────────────────────────────────────────────────────

async function seed() {
  console.log('Connecting to MongoDB...');
  await mongoose.connect(MONGODB_URI);
  console.log('Connected.\n');

  if (shouldClear) {
    console.log('Clearing existing data...');
    await Affirmation.deleteMany({});
    await Task.deleteMany({});
    console.log('Cleared.\n');
  }

  // Seed affirmations (skip if already have data and not clearing)
  const existingAffirmations = await Affirmation.countDocuments();
  if (existingAffirmations > 0 && !shouldClear) {
    console.log(`Affirmations: ${existingAffirmations} already exist — skipping. Use --clear to reseed.`);
  } else {
    const inserted = await Affirmation.insertMany(affirmations);
    console.log(`Affirmations: inserted ${inserted.length}`);
  }

  // Seed tasks (skip if already have data and not clearing)
  const existingTasks = await Task.countDocuments();
  if (existingTasks > 0 && !shouldClear) {
    console.log(`Tasks: ${existingTasks} already exist — skipping. Use --clear to reseed.`);
  } else {
    const inserted = await Task.insertMany(tasks);
    console.log(`Tasks: inserted ${inserted.length}`);
  }

  console.log('\nSeed complete.');
  await mongoose.disconnect();
}

seed().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
