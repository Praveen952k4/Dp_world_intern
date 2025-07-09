import express from "express";
import cors from "cors";
import { connectDB } from "./config/db.js";

import "dotenv/config.js";


//config
const app = express();
const PORT = 4000;

//middleware
app.use(express.json());
app.use(cors());

connectDB();

app.get("/", (req, res) => {
  res.send("API working");
});

app.listen(PORT, () =>
  console.log(`Server Running @ http://localhost:4000/...`)
);
