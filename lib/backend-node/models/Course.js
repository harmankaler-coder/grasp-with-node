const mongoose = require("mongoose");

const QuizSchema = new mongoose.Schema(
  {
    question: { type: String, required: true },
    options: [{ type: String, required: true }],
    correct_option_index: { type: Number, required: true },
  },
  { _id: false }
);

const ChapterSchema = new mongoose.Schema(
  {
    chapter_number: { type: Number, required: true },
    title: { type: String, required: true },

    video_id: { type: String, default: null },
    youtube_search_query: { type: String, default: "" },

    content_text: { type: String, default: "" },

    cheat_sheet_points: [{ type: String }],
    cheat_sheet_text: { type: String, default: "" },

    quiz_data: [QuizSchema],

    is_completed: { type: Boolean, default: false },
  },
  { _id: true }
);

const CourseSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    topic: {
      type: String,
      required: true,
      trim: true,
    },

    chapters: [ChapterSchema],
  },
  { timestamps: true }
);

CourseSchema.index({ userId: 1, createdAt: -1 });
CourseSchema.index({ topic: 1 });
CourseSchema.set("toJSON", {
  virtuals: true,
  versionKey: false,
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
  },
});

ChapterSchema.set("toJSON", {
  virtuals: true,
  versionKey: false,
  transform: function (doc, ret) {
    ret.id = ret._id;
    delete ret._id;
  },
});

module.exports = mongoose.model("Course", CourseSchema);