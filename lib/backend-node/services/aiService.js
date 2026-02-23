const { ChatGroq } = require("@langchain/groq");
const { PromptTemplate } = require("@langchain/core/prompts");
const { google } = require('googleapis');
require('dotenv').config();

const llm = new ChatGroq({
    apiKey: process.env.GROQ_API_KEY,
    model: "llama-3.3-70b-versatile",
    temperature: 0.3,
    maxTokens: 8000,
});

const youtube = google.youtube({
    version: 'v3',
    auth: process.env.YOUTUBE_API_KEY
});

function parseJsonOutput(text) {
    try {
        let cleanText = text.replace(/```json/g, "").replace(/```/g, "").trim();
        return JSON.parse(cleanText);
    } catch (e) {
        console.error("JSON Parse Error:", text.substring(0, 100) + "...");
        throw new Error("Failed to parse AI response as JSON.");
    }
}

async function searchYoutube(query) {
    try {
        const response = await youtube.search.list({
            part: 'snippet',
            maxResults: 1,
            q: query + " educational tutorial",
            type: 'video'
        });

        if (response.data.items && response.data.items.length > 0) {
            return response.data.items[0].id.videoId;
        }
    } catch (error) {
        console.error(`YouTube Error for '${query}':`, error.message);
    }
    return "dQw4w9WgXcQ";
}

async function generateCourseService(topic) {
    console.log(`\nRunning Groq for: ${topic}`);

    const template = `
    You are an expert university professor. Create a 5-chapter course on: "{topic}".

    RETURN ONLY RAW JSON. NO MARKDOWN. NO \`\`\`json TAGS.

    Structure:
    {{
      "topic": "Topic Name",
      "chapters": [
        {{
          "chapter_number": 1,
          "title": "Chapter Title",
          "youtube_search_query": "Search query for video",
          "content_markdown": "Detailed content (approx 500 words). Use ## for headers.",
          "cheat_sheet_points": ["Point 1", "Point 2", "Point 3", "Point 4", "Point 5"],
          "quiz": [
             {{ "question": "Q1", "options": ["A", "B", "C", "D"], "correct_option_index": 0 }},
             {{ "question": "Q2", "options": ["A", "B", "C", "D"], "correct_option_index": 1 }},
             {{ "question": "Q3", "options": ["A", "B", "C", "D"], "correct_option_index": 2 }},
             {{ "question": "Q4", "options": ["A", "B", "C", "D"], "correct_option_index": 3 }},
             {{ "question": "Q5", "options": ["A", "B", "C", "D"], "correct_option_index": 4 }}
          ]
        }}
      ]
    }}
  `;

    const prompt = PromptTemplate.fromTemplate(template);
    const chain = prompt.pipe(llm);

    let courseData = null;
    for (let attempt = 1; attempt <= 2; attempt++) {
        try {
            console.log(`   Attempt ${attempt}...`);

            const response = await chain.invoke({ topic });

            courseData = parseJsonOutput(response.content);

            if (!courseData.chapters || !Array.isArray(courseData.chapters)) {
                throw new Error("Invalid structure: missing chapters array");
            }

            console.log("JSON Parsed Successfully");
            break;
        } catch (e) {
            console.error(`Attempt ${attempt} failed:`, e.message);
            if (attempt === 2) throw new Error("AI failed to generate valid data.");
        }
    }

    console.log("Fetching Videos");
    const videoPromises = courseData.chapters.map(ch => searchYoutube(ch.youtube_search_query));
    const videoIds = await Promise.all(videoPromises);

    courseData.chapters = courseData.chapters.map((ch, index) => {
        let points = ch.cheat_sheet_points || [];
        while (points.length < 5) points.push("Review full content for details.");
        points = points.slice(0, 5);

        return {
            ...ch,
            video_id: videoIds[index],
            cheat_sheet_points: points,
            cheat_sheet_text: points.join('\n'),
            content_text: ch.content_markdown,
            quiz_data: ch.quiz
        };
    });

    return courseData;
}

module.exports = { generateCourseService };