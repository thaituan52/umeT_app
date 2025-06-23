USE shopping_app;

-- Insert test users to verify everything works
INSERT IGNORE INTO user_info (uid, identifier, provider, display_name) 
VALUES 
    ('1234567890', '+1234567890', 'phone', 'John Doe'),
    ('0987654321', 'jane@example.com', 'gmail', 'Gay Smith'),
    ('8765436789', 'google.user@gmail.com', 'google', 'Mike Johnson');
    
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
('Waterproof Sofa Inflatable Bean Bag Chair', 'Comfortable and waterproof bean bag chair perfect for outdoor use', 'https://images.unsplash.com/photo-1653251307042-c5821df9d527?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', 17.25,  854, 4.8, 141, '44.7% arrive in 3 business days', 'Seller established 1 year ago', 50),
('Butane Torch Lighter Double-Safe Welding', 'Professional grade butane torch with safety features', 'https://images.unsplash.com/photo-1569702958265-5939ae06ee8b?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8QnV0YW5lJTIwVG9yY2glMjBMaWdodGVyfGVufDB8fDB8fHww', 5.38,  475, 4.9, 56, 'Arrives in 2+ business days', 'High repeat customers store', 30),
('Versatile Shoe Rack Storage Organizer', 'Multi-tier shoe organizer for closet storage', 'https://plus.unsplash.com/premium_photo-1748120990496-0c0e37de5dad?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8U2hvZSUyMFJhY2slMjBTdG9yYWdlfGVufDB8fDB8fHww', 7.43,  6559, 4.3, 6959, 'Fast delivery', 'Low item return rate store', 100),
('Compact Speaker Magnetic Levitation', 'Floating speaker with magnetic levitation technology', 'https://images.unsplash.com/photo-1631728126283-73d842f4f4d8?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fGNvbXBhY3QlMjBTcGVha2VyfGVufDB8fDB8fHww', 11.13,  3, 4.7, 28, 'Fast delivery store', 'Reliable seller', 15),
('Wireless Bluetooth Earbuds Pro', 'High-quality wireless earbuds with noise cancellation', 'https://plus.unsplash.com/premium_photo-1677158265072-5d15db9e23b2?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8Qmx1ZXRvb3RoJTIwRWFyYnVkc3xlbnwwfHwwfHx8MA%3D%3D', 23.99,  1247, 4.6, 892, '2-3 business days', 'Top rated seller', 75),
('Smart Watch Fitness Tracker', 'Advanced fitness tracker with heart rate monitoring', 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8U21hcnQlMjBXYXRjaHxlbnwwfHwwfHx8MA%3D%3D', 34.50,  567, 4.4, 234, '3-5 business days', 'Established store', 40);


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