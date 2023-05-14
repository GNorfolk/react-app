const express = require("express");
const connection = require('./database.js')

const app = express();app.listen(3001, () => {
  console.log("Server running on port 3001");
});

app.get("/health-check", (req, res, next) => {
  res.json("backend response")
})

app.get("/users", (req, res, next) => {
  connection.query('SELECT * FROM users ORDER BY id asc', function (err, rows) {
    if (err) {
      console.log("err: ", err)
      res.json({error: err})
    } else {
      res.json(rows)
    }
  })
})

module.exports = app