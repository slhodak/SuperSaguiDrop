require('dotenv').config();
const express = require('express');
const { body, validationResult } = require('express-validator');
const Database = require('./database.js');

const app = express();
const port = process.env.SRV_PORT;
const db = new Database();

app.use(express.json())

const validateScoreData = [
    body('user_name').isString(),
    body('ts').isInt(),
    body('saguisSaved').isInt(),
    body('oncasTamed').isInt(),
    body('duration').isInt(),
    body('totalScore').isInt(),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        next();
    }
];

app.get('/', (req, res) => {
  res.send({"response": "None"});
});

app.get('/health', (req, res) => {
  res.send({"response": "OK"})
})

app.post('/score', validateScoreData, async (req, res) => {
  try {
    const scoreData = req.body;
    // Save score to db
    const result = await db.insertScore(scoreData)
    res.send({"response": "OK"})
    
  } catch (error) {
    console.error(`Error while posting score: ${error.message}`)
    console.error(error.stack)
    res.send({"response": "ERR"})
  }
})

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});


// Utils
function parseScore(scorePayload) {

}