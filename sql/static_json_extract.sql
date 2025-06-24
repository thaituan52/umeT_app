USE shopping_app;



SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'id', id,
        'uid', uid,
        'provider', provider,
        'identifier', identifier,
        'photo_url', photo_url,
        'address', address,
        'display_name', display_name,
        'is_active', is_active,
        'last_login', DATE_FORMAT(last_login, '%Y-%m-%dT%H:%i:%sZ'),
        'created_at', DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%sZ'),
        'updated_at', DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%sZ')
    )
) FROM user_info;



SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'id', id,
        'name', name,
        'description', description,
        'is_active', is_active,
        'created_at', DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%sZ'),
        'updated_at', DATE_FORMAT(updated_at, '%Y-%m-%dT%H:%i:%sZ')
    )
) FROM categories;


SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'id', p.id,
        'name', p.name,
        'description', p.description,
        'image_url', p.image_url,
        'price', p.price,
        'sold_count', p.sold_count,
        'rating', p.rating,
        'review_count', p.review_count,
        'delivery_info', p.delivery_info,
        'seller_info', p.seller_info,
        'stock_quantity', p.stock_quantity,
        'is_active', p.is_active,
        'created_at', DATE_FORMAT(p.created_at, '%Y-%m-%dT%H:%i:%sZ'),
        'updated_at', DATE_FORMAT(p.updated_at, '%Y-%m-%dT%H:%i:%sZ'),
        'categories', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', c.id,
                    'name', c.name,
                    'description', c.description,
                    'is_active', c.is_active,
                    'created_at', DATE_FORMAT(c.created_at, '%Y-%m-%dT%H:%i:%sZ'),
                    'updated_at', DATE_FORMAT(c.updated_at, '%Y-%m-%dT%H:%i:%sZ')
                )
            )
            FROM product_categories pc
            JOIN categories c ON pc.category_id = c.id
            WHERE pc.product_id = p.id
        )
    )
) FROM products p;


SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'id', o.id,
        'user_id', o.user_id,
        'status', o.status,
        'total_amount', o.total_amount,
        'shipping_address', o.shipping_address,
        'billing_method', o.billing_method,
        'contact_phone', o.contact_phone,
        'created_at', DATE_FORMAT(o.created_at, '%Y-%m-%dT%H:%i:%sZ'),
        'updated_at', DATE_FORMAT(o.updated_at, '%Y-%m-%dT%H:%i:%sZ'),
        'items', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', oi.id,
                    'product_id', oi.product_id,
                    'quantity', oi.quantity,
                    'price_per_unit', oi.price_per_unit,
                    'created_at', DATE_FORMAT(oi.created_at, '%Y-%m-%dT%H:%i:%sZ')
                )
            )
            FROM order_items oi
            WHERE oi.order_id = o.id
        )
    )
) FROM orders o;