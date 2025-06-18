import 'package:flutter/material.dart';

class Product { //model for products so that I can put to db later like user
  final int id;
  final String name;
  final String? image;
  final double price;
  final int sold; //soldNum
  final double rating;
  //final int reviews; //considerable
  final String deliveryInfo;
  final String sellerInfo;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    // required this.originalPrice,
    required this.sold,
    required this.rating,
    // required this.reviews,
    // this.isLocal = false,
    // this.isFathersDayDeal = false,
    // this.isClearanceDeal = false,
    // this.isAd = false,
    required this.deliveryInfo,
    required this.sellerInfo,
  });
}


class DatabaseService { //gonna bring it to another file later + make temp data to use rn
  static List<Product> _products = [
    Product(
      id: 1,
      name: "Waterproof Sofa Inflatable Bean Bag Chair",
      image: "🛋️",
      price: 17.25,
      //originalPrice: 25.00,
      sold: 854,
      rating: 4.8,
      //reviews: 141,
      //isLocal: true,
      deliveryInfo: "44.7% arrive in 3 business days",
      sellerInfo: "Seller established 1 year ago",
    ),
    Product(
      id: 2,
      name: "Butane Torch Lighter Double-Safe Welding",
      image: "🔥",
      price: 5.38,
      //originalPrice: 12.99,
      sold: 475,
      rating: 4.9,
      //reviews: 56,
      //isLocal: true,
      //isFathersDayDeal: true,
      //isAd: true,
      deliveryInfo: "Arrives in 2+ business days",
      sellerInfo: "High repeat customers store",
    ),
    Product(
      id: 3,
      name: "Versatile Shoe Rack Storage Organizer",
      image: "👟",
      price: 7.43,
      //originalPrice: 15.99,
      sold: 6559,
      rating: 4.3,
      //reviews: 6959,
      //isLocal: true,
      //isClearanceDeal: true,
      deliveryInfo: "Fast delivery",
      sellerInfo: "Low item return rate store",
    ),
    Product(
      id: 4,
      name: "Compact Speaker Magnetic Levitation",
      image: "🔊",
      price: 11.13,
      //originalPrice: 29.99,
      sold: 3,
      rating: 4.7,
      //reviews: 28,
      //isLocal: true,
      //isFathersDayDeal: true,
      deliveryInfo: "Fast delivery store",
      sellerInfo: "Reliable seller",
    ),
    Product(
      id: 5,
      name: "Wireless Bluetooth Earbuds Pro",
      image: "🎧",
      price: 23.99,
      //originalPrice: 59.99,
      sold: 1247,
      rating: 4.6,
      //reviews: 892,
      //isLocal: true,
      deliveryInfo: "2-3 business days",
      sellerInfo: "Top rated seller",
    ),
    Product(
      id: 6,
      name: "Smart Watch Fitness Tracker",
      image: "⌚",
      price: 34.50,
      //originalPrice: 89.99,
      sold: 567,
      rating: 4.4,
      //reviews: 234,
      //isLocal: true,
      deliveryInfo: "3-5 business days",
      sellerInfo: "Established store",
    ),
  ];

  static List<Product> getAllProducts() => _products;

  static void addProduct(Product product) {
    _products.add(product);
  }
}




  class ProductCard extends StatelessWidget {
    final Product product;
    final VoidCallback onTap;
    final VoidCallback onAddToCart;

    const ProductCard({
      super.key,
      required this.product,
      required this.onTap,
      required this.onAddToCart,
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 140, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      product.image ?? '',
                      style: TextStyle(fontSize: 60),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.deliveryInfo,
                      style: TextStyle(fontSize: 10, color: Colors.green[600]),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : (index < product.rating ? Icons.star_half : Icons.star_border),
                            color: Colors.orange[400],
                            size: 12,
                          );
                        }),
                        SizedBox(width: 4),
                        Text(
                          "${product.rating}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      product.sellerInfo,
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[600],
                                ),
                              ),
                              Text(
                                "${product.sold} sold",
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,

                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }
  }

  class ProductDetailsModel extends StatelessWidget {
    final Product product;
    final VoidCallback onAddToCart;
    final VoidCallback onBuyNow;

    const ProductDetailsModel({
      super.key,
      required this.product,
      required this.onAddToCart,
      required this.onBuyNow,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 24, color: Colors.orange[600]),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < product.rating.floor()
                        ? Icons.star
                        : (index < product.rating ? Icons.star_half : Icons.star_border),
                    color: Colors.orange[400],
                    size: 16,
                  );
                }),
                SizedBox(width: 8),
                Text("${product.rating}"),
              ],
            ),
            SizedBox(height: 10),
            Text(product.deliveryInfo),
            SizedBox(height: 10),
            Text(product.sellerInfo),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[400],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Add to Cart", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 158, 129, 163),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text("Buy Now", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  