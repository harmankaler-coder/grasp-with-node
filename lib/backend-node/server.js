const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const notesRoutes = require('./routes/notesRoutes');
const authRoutes = require('./routes/auth_routes');
const auth = require('./middleware/auth');

require('dotenv').config();

const { generateCourseService } = require('./services/aiService');
const Course = require('./models/Course');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);
app.use('/uploads', express.static('uploads'));
app.use('/', notesRoutes);

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error('MongoDB Error:', err.message));

app.post('/generate_course', auth, async (req, res) => {
    console.log("Generating Course...");
  try {
    const { topic } = req.body;
    console.log(`AI Generating for topic: ${topic}`);

    const courseData = await generateCourseService(topic);

    const course = await Course.create({
      ...courseData,
      userId: req.userId
    });

    res.json(course);
  } catch (e) {
    console.error("Generate Error:", e.message);
    res.status(500).json({ error: e.message });
  }
});

app.get('/courses', auth, async (req, res) => {
  try {
    const courses = await Course.find({ userId: req.userId }).sort({ _id: -1 });
    res.json(courses);
  } catch (e) {
    res.status(500).json({ error: "Failed to fetch history" });
  }
});

app.get('/courses/:id', auth, async (req, res) => {
  try {
    const course = await Course.findOne({ _id: req.params.id, userId: req.userId });

    if (!course) return res.status(404).json({ error: "Course not found" });
    res.json(course.chapters);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});