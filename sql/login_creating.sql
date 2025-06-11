-- Create the database
CREATE DATABASE IF NOT EXISTS shopping_app;

-- Select the database to use
USE shopping_app;

-- Create the users table
CREATE TABLE IF NOT EXISTS user_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    google_id VARCHAR(100) UNIQUE,
    facebook_id VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create OTP table

CREATE TABLE IF NOT EXISTS otp_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  code VARCHAR(6),
  expires_at TIMESTAMP,
  is_used BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES user_info(id)
);

-- Verify the table was created
DESCRIBE user_info;

-- Optional: Insert a test user to verify everything works
INSERT IGNORE INTO user_info (email, phone) 
VALUES ('test@example.com', '+1234567890');

-- Check the inserted data
SELECT * FROM user_info;
SELECT * FROM otp_codes;
