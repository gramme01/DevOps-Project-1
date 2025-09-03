const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

// Routes
app.get("/", (req, res) => {
  res.json({ message: "Hello DevOps Assessment!" });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    service: "node-app",
    uptime: process.uptime(),
  });
});

app.get("/api/version", (req, res) => {
  res.json({
    version: "1.0.0",
    description: "DevOps Assessment Node.js API",
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
