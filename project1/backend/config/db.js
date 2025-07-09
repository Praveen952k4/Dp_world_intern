import mongoose, { mongo } from "mongoose";

export const connectDB = async () => {
  mongoose
    .connect(
      "mongodb+srv://prxvxzn:i7GYhjnJwSgoyxWz@cluster0.0kual8y.mongodb.net/DP world"
    )
    .then(() => console.log("DB Connected"));
};


