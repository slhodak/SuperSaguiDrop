require('dotenv').config();
const express = require('express');
const { query, body, validationResult } = require('express-validator');
const Database = require('./database.js');

const app = express();
const port = process.env.SRV_PORT;
const db = new Database();

app.use(express.json())

const validateScoreDataRequest = [
  query('user_name').isString(),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

const validateScoreDataInput = [
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
  res.send({"response": "Yes?"});
});

app.get('/health', (req, res) => {
  res.send({"response": "OK"});
});

app.get('/recentScores', validateScoreDataRequest, async (req, res) => {
  try {
    const userName = req.query.user_name;
    const scoreData = await db.fetchRecentScores(userName);
    console.log(scoreData);
    
    let responseData = scoreData.map(score => ({
      "un": userName,
      "tis": score.ts,
      "ss": score.saguis_saved,
      "ot": score.oncas_tamed,
      "d": score.duration,
      "tos": score.total_score,
    }));
    console.log(responseData);
    res.set('Content-Type', 'application/json');
    res.send(responseData);
    
  } catch (error) {
    console.error(`Error while fetching score: ${error.message}`);
    console.error(error.stack);
    res.status(500).send({"response": "ERR"});
  }
});

app.post('/score', validateScoreDataInput, async (req, res) => {
  try {
    const scoreData = req.body;
    // Save score to db
    const result = await db.insertScore(scoreData);
    res.send({"response": "OK"});

  } catch (error) {
    console.error(`Error while posting score: ${error.message}`);
    console.error(error.stack);
    res.status(500).send({"response": "ERR"});
  }
})

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
