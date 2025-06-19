-- Create the database
CREATE DATABASE IF NOT EXISTS shopping_app;

-- Select the database to use
USE shopping_app;

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

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Home & Garden', 'Home improvement and gardening items'),
('Fashion', 'Clothing and accessories'),
('Sports', 'Sports and outdoor equipment'),
('Books', 'Books and educational materials'),
('Health & Beauty', 'Health and beauty products'),
('Toys', 'Toys and games'),
('Automotive', 'Car accessories and parts');

-- Insert sample products
INSERT INTO products (name, description, image_url, price, sold_count, rating, review_count, delivery_info, seller_info, stock_quantity) VALUES
('Waterproof Sofa Inflatable Bean Bag Chair', 'Comfortable and waterproof bean bag chair perfect for outdoor use', 'https://images.unsplash.com/photo-1743630738181-b0e26c76c74c?q=80&w=680&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', 17.25,  854, 4.8, 141, '44.7% arrive in 3 business days', 'Seller established 1 year ago', 50),
('Butane Torch Lighter Double-Safe Welding', 'Professional grade butane torch with safety features', '🔥', 5.38,  475, 4.9, 56, 'Arrives in 2+ business days', 'High repeat customers store', 30),
('Versatile Shoe Rack Storage Organizer', 'Multi-tier shoe organizer for closet storage', '👟', 7.43,  6559, 4.3, 6959, 'Fast delivery', 'Low item return rate store', 100),
('Compact Speaker Magnetic Levitation', 'Floating speaker with magnetic levitation technology', '🔊', 11.13,  3, 4.7, 28, 'Fast delivery store', 'Reliable seller', 15),
('Wireless Bluetooth Earbuds Pro', 'High-quality wireless earbuds with noise cancellation', '🎧', 23.99,  1247, 4.6, 892, '2-3 business days', 'Top rated seller', 75),
('Smart Watch Fitness Tracker', 'Advanced fitness tracker with heart rate monitoring', '⌚', 34.50,  567, 4.4, 234, '3-5 business days', 'Established store', 40);

-- Link products to categories
INSERT INTO product_categories (product_id, category_id) VALUES
-- Bean bag chair -> Home & Garden
(1, 2),
-- Butane torch -> Automotive
(2, 8),
-- Shoe rack -> Home & Garden
(3, 2),
-- Speaker -> Electronics
(4, 1),
-- Earbuds -> Electronics
(5, 1),
-- Smart watch -> Electronics, Sports, Health & Beauty
(6, 1),
(6, 4),
(6, 6);