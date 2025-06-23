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
    address VARCHAR(500),
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


-- Check the inserted data
-- SELECT 
--     id,
--     uid,
--     display_name,
--     is_active,
--     last_login,
--     created_at,
--     updated_at
-- FROM user_info 
-- ORDER BY created_at DESC;








-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    price DECIMAL(10, 2) NOT NULL,
    sold_count INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.0,
    review_count INT DEFAULT 0,
    delivery_info VARCHAR(255),
    seller_info VARCHAR(255),
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create product_categories junction table for many-to-many relationship
CREATE TABLE IF NOT EXISTS product_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_category (product_id, category_id)
);



