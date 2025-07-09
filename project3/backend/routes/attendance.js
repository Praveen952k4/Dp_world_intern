const express = require('express');
const router = express.Router();
const { recordPunch } = require('../controllers/attendanceController');

router.post('/attendance', recordPunch);

module.exports = router;