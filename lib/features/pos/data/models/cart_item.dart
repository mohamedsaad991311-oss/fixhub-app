class CartItem { 
  final String productId; 
  final String name; 
  final double price; 
  int qty; 
  CartItem({required this.productId, required this.name, required this.price, this.qty = 1}); 
  double get total => price * qty; 
} 
