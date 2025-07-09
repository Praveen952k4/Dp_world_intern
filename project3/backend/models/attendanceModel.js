const pool = require('../db');

const insertAttendanceRecord = async (data) => {
  const {
    employee_id,
    employee_name,
    timestamp,
    action,
    selected_location,
    gps_coordinates,
    admin_override,
    address,
    company_code
  } = data;

  const query = `INSERT INTO employee_attendance 
    (employee_id, employee_name, timestamp, action, selected_location, gps_coordinates, admin_override, address, company_code)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`;

  const values = [
    employee_id,
    employee_name,
    timestamp,
    action,
    selected_location,
    gps_coordinates,
    admin_override,
    address,
    company_code
  ];

  const result = await pool.query(query, values);
  return result;
};

module.exports = { insertAttendanceRecord };