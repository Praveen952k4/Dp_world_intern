const { insertAttendanceRecord } = require('../models/attendanceModel');

const recordPunch = async (req, res) => {
  try {
    const result = await insertAttendanceRecord(req.body);
    res.status(200).json({ message: 'Punch recorded successfully', result });
  } catch (err) {
    console.error('Error in recordPunch:', err);
    res.status(500).json({ error: 'Failed to record punch' });
  }
};

module.exports = { recordPunch };
