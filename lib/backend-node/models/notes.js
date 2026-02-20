const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
    userId : {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
    },
    file_names: [{
        type: String,
        required: true
    }],
    file_type: {
        type: String,
        required: true
    },
    created_at: {
        type: Date,
        default: Date.now
    }
});

noteSchema.set('toJSON', {
    virtuals: true,
    versionKey: false,
    transform: function (doc, ret) {
        ret.id = ret._id;
        delete ret._id;
    }
});

module.exports = mongoose.model('Note', noteSchema);