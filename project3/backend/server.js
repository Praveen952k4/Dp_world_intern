const express = require('express');
const app = express();
const attendanceRoutes = require('./routes/attendance');
const cors = require('cors');
require('dotenv').config();

app.use(cors());
app.use(express.json());
app.use('/api', attendanceRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});