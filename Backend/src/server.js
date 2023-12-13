const express = require('express');
require('dotenv').config();

const app = express();
const port = process.env.SRV_PORT;

const { insertScore } = require('./database.js');

app.use(express.json())

app.get('/', (req, res) => {
  res.send({"response": "None"});
});

app.get('/health', (req, res) => {
  res.send({"response": "OK"})
})

app.post('/score', async (req, res) => {
  try {
    const payload = req.body;
    // Save score to db
    const result = await insertScore(payload)
    res.send({"response": "OK"})
  } catch {
    res.send({"response": "ERR"})
  }
})

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});


// Utils
function parseScore(scorePayload) {

}