-- Create the database
CREATE DATABASE IF NOT EXISTS shopping_app;

-- Select the database to use
USE shopping_app;

-- Create the enhanced users table
CREATE TABLE IF NOT EXISTS user_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    google_id VARCHAR(100) UNIQUE,
    facebook_id VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_picture_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for better performance
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_google_id (google_id),
    INDEX idx_facebook_id (facebook_id),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at)
);

-- Verify the table was created
DESCRIBE user_info;

-- Insert test users to verify everything works
INSERT IGNORE INTO user_info (email, phone, first_name, last_name, email_verified) 
VALUES 
    ('test@example.com', '+1234567890', 'John', 'Doe', TRUE),
    ('jane@example.com', '+0987654321', 'Jane', 'Smith', FALSE),
    ('google.user@gmail.com', NULL, 'Mike', 'Johnson', TRUE);

-- Update Google ID for test user
UPDATE user_info 
SET google_id = 'google_123456789' 
WHERE email = 'google.user@gmail.com';

-- Check the inserted data
SELECT 
    id,
    email,
    phone,
    google_id,
    facebook_id,
    first_name,
    last_name,
    is_active,
    email_verified,
    phone_verified,
    last_login,
    created_at,
    updated_at
FROM user_info 
ORDER BY created_at DESC;

-- Useful queries for your application

-- Find user by email
SELECT * FROM user_info WHERE email = 'test@example.com';

-- Find user by Google ID
SELECT * FROM user_info WHERE google_id = 'google_123456789';

-- Find user by phone
SELECT * FROM user_info WHERE phone = '+1234567890';

-- Get all active users
SELECT * FROM user_info WHERE is_active = TRUE;

-- Get users who haven't verified their email
SELECT * FROM user_info WHERE email_verified = FALSE AND email IS NOT NULL;