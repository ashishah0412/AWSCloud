const express = require("express");
const app = express();
const port = 80;

app.get("/service2", (req, res) => {
  res.send("Hello from Service 2 (Node.js Express)!");
});

app.listen(port, () => {
  console.log(`Service 2 listening at http://localhost:${port}`);
});


