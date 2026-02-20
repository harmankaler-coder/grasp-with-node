const express = require('express');
const router = express.Router();
const multer = require('multer');
const Note = require('../models/notes');
const fs = require('fs');
const path = require('path');
const auth = require('../middleware/auth');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png',
    'application/octet-stream'
  ];

  const allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png'];

  const ext = require('path').extname(file.originalname).toLowerCase();

  if (
    allowedMimeTypes.includes(file.mimetype) &&
    allowedExtensions.includes(ext)
  ) {
    cb(null, true);
  } else {
    console.log("Invalid file type!", file.mimetype);
    cb(new Error("Only PDF and image files allowed"), false);
  }
};
const upload = multer({
  storage: storage,
  limits: { fileSize: 500 * 1024 },
  fileFilter: fileFilter
});

router.post('/upload_file', auth, (req, res) => {

  upload.array('files')(req, res, async function (err) {

    if (err instanceof multer.MulterError) {
      if (err.code === 'limit_file_size') {
        console.log('File too large!')
        return res.status(400).json({ error: "Max 500KB allowed" });
      }
    }

    if (err && err.message === "Only PDF and image files allowed") {
      console.log('Invalid file type!')
      return res.status(400).json({ error: err.message });
    }
    if (err) {
      console.log('Upload Error: ', err.message)
      return res.status(500).json({ error: err.message });
    }

    try {
      const { title, description } = req.body;

      if (!req.files || req.files.length === 0) {
        return res.status(400).json({ error: "No files uploaded" });
      }

      const fileNames = req.files.map(file => file.filename);

      const note = await Note.create({
        title,
        description,
        file_names: fileNames,
        file_type: req.files[0].mimetype,
        userId: req.userId
      });
      res.json(note);

    } catch (e) {
      console.log(e);
      res.status(500).json({ error: "Upload failed" });
    }
  });
});

router.get('/notes', auth, async (req, res) => {
  try {
    const notes = await Note.find({ userId: req.userId }).sort({ _id: -1 });

    const BASE_URL = process.env.BASE_URL || "http://10.0.2.2:3000";

    const formatted = notes.map(note => ({
      id: note._id,
      title: note.title,
      description: note.description,
      file_urls: note.file_names.map(
        f => `${BASE_URL}/uploads/${f}`
      )
    }));

    res.json(formatted);

  } catch (e) {
    console.log(e);
    res.status(500).json({ error: "Failed to fetch notes" });
  }
});

router.delete('/notes/:id', auth, async (req, res) => {
  try {
    const note = await Note.findOne({ _id: req.params.id, userId: req.userId });

    if (!note) {
      return res.status(404).json({ error: "Note not found" });
    }

    const fs = require('fs');
    const path = require('path');

    if (note.file_names && note.file_names.length > 0) {
      for (let name of note.file_names) {
        const filePath = path.join(
          __dirname,
          '..',
          'uploads',
          name,
        );

        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
    }
    await Note.findByIdAndDelete(req.params.id);

    res.json({ message: "Note deleted" });

  } catch (e) {
    console.log("Delete error:", e.message);
    res.status(500).json({ error: e.message });
  }
});

module.exports = router;
