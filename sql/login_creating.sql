-- Create the database
CREATE DATABASE IF NOT EXISTS shopping_app;

-- Select the database to use
USE shopping_app;

-- Create the enhanced users table
CREATE TABLE IF NOT EXISTS user_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uid VARCHAR(100) UNIQUE,  -- Changed from firebaseID to uid
    provider VARCHAR(50),     -- Changed from providerName to provider
    identifier VARCHAR(100),
    photo_url VARCHAR(500),   -- Changed from profile_picture_url to photo_url
    display_name VARCHAR(100),
    password_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
    
    -- Indexes for better performance gonna work on this later, for now we will use the default indexes
    -- INDEX idx_email (email),
    -- INDEX idx_phone (phone),
    -- INDEX idx_google_id (google_id),
    -- INDEX idx_facebook_id (facebook_id),
    -- INDEX idx_is_active (is_active),
    -- INDEX idx_created_at (created_at)

-- Verify the table was created
DESCRIBE user_info;

-- Insert test users to verify everything works
INSERT IGNORE INTO user_info (uid, identifier, provider, display_name) 
VALUES 
    ('1234567890', '+1234567890', 'phone', 'John Doe'),
    ('0987654321', 'jane@example.com', 'gmail', 'Gay Smith'),
    ('8765436789', 'google.user@gmail.com', 'google', 'Mike Johnson');

-- Update Google ID for test user
UPDATE user_info 
SET display_name = 'Mike Tyson' 
WHERE uid = '8765436789';

-- Check the inserted data
SELECT 
    id,
    uid,
    display_name,
    is_active,
    last_login,
    created_at,
    updated_at
FROM user_info 
ORDER BY created_at DESC;

-- Useful queries for your application

-- Find user 
SELECT * FROM user_info 