# Whiskr Pet Shop Admin Panel

A comprehensive Flutter web admin panel for managing pet shop operations, designed to communicate with the Whiskr mobile app.

## Features

### 🔐 Authentication
- Secure login/logout functionality
- User session management
- Role-based access control

### 📊 Dashboard
- Real-time overview of shop performance
- Key metrics and statistics
- Recent orders and low stock alerts
- Quick access to all major functions

### 📦 Inventory Management
- Add, edit, and delete products
- Product categorization (Pet Food, Toys, Accessories, etc.)
- Stock level tracking with low stock alerts
- Product image support
- Search and filter functionality
- Bulk operations

### 🛒 Order Management
- View all orders from mobile app
- Order status updates (Pending → Confirmed → Processing → Shipped → Delivered)
- Customer information display
- Order details and item breakdown
- Order history tracking

### 📈 Analytics & Reports
- Sales revenue tracking
- Order statistics by status
- Product performance metrics
- Low stock product monitoring
- Revenue trends and insights

### 🎨 Modern UI/UX
- Responsive design for all screen sizes
- Material Design 3 components
- Intuitive navigation with drawer and bottom navigation
- Beautiful color scheme and typography
- Loading states and error handling

## Technology Stack

- **Framework**: Flutter Web
- **State Management**: Provider
- **HTTP Client**: Dio
- **UI Components**: Material Design 3
- **Charts**: fl_chart (for future analytics)
- **Local Storage**: SharedPreferences
- **Image Handling**: cached_network_image

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user.dart
│   ├── product.dart
│   └── order.dart
├── providers/        # State management
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   └── order_provider.dart
├── screens/          # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── inventory_screen.dart
│   ├── orders_screen.dart
│   └── analytics_screen.dart
├── widgets/          # Reusable components
│   ├── dashboard_stats_card.dart
│   ├── product_card.dart
│   ├── recent_orders_widget.dart
│   ├── low_stock_products_widget.dart
│   └── add_edit_product_dialog.dart
├── services/         # API communication
│   └── api_service.dart
├── utils/            # Utilities and themes
│   └── app_theme.dart
└── main.dart         # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Chrome browser (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd whiskr_admin_panel
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` constant with your backend API URL
   ```dart
   static const String baseUrl = 'https://your-whiskr-api.com/api';
   ```

4. **Run the application**
   ```bash
   flutter run -d chrome
   ```

### API Configuration

The admin panel expects the following API endpoints:

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user

#### Products
- `GET /products` - Get all products
- `POST /products` - Create new product
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product

#### Orders
- `GET /orders` - Get all orders
- `GET /orders/{id}` - Get specific order
- `PATCH /orders/{id}/status` - Update order status

#### Dashboard
- `GET /dashboard/stats` - Get dashboard statistics
- `GET /dashboard/sales-chart` - Get sales chart data

## Usage Guide

### Login
1. Navigate to the admin panel
2. Enter your email and password
3. Click "Sign In"

### Dashboard
- View key metrics at a glance
- Monitor recent orders and low stock products
- Quick access to all major functions

### Inventory Management
1. Click "Inventory" in the navigation
2. Use search to find specific products
3. Filter by category using the chip filters
4. Click "Add Product" to create new items
5. Click on product cards to edit
6. Use the delete button to remove products

### Order Management
1. Click "Orders" in the navigation
2. View all orders from your mobile app
3. Click the menu button on any order to update status
4. Orders flow: Pending → Confirmed → Processing → Shipped → Delivered

### Analytics
1. Click "Analytics" in the navigation
2. View revenue overview and order statistics
3. Monitor product performance

## Customization

### Colors and Theme
Edit `lib/utils/app_theme.dart` to customize:
- Primary and secondary colors
- Text colors and typography
- Card styles and elevations
- Button styles

### API Integration
Modify `lib/services/api_service.dart` to:
- Add new API endpoints
- Customize request/response handling
- Implement additional authentication methods

### Adding New Features
1. Create new models in `lib/models/`
2. Add providers in `lib/providers/`
3. Create screens in `lib/screens/`
4. Add reusable widgets in `lib/widgets/`

## Deployment

### Web Deployment
1. Build the web version:
   ```bash
   flutter build web
   ```

2. Deploy the `build/web` folder to your web server

### Recommended Hosting
- Firebase Hosting
- Netlify
- Vercel
- AWS S3 + CloudFront

## Security Considerations

- All API calls include authentication tokens
- Sensitive data is stored securely using SharedPreferences
- Input validation on all forms
- Error handling for network failures
- Session management with automatic logout

## Future Enhancements

- [ ] Real-time notifications
- [ ] Advanced analytics with charts
- [ ] Bulk product operations
- [ ] Customer management
- [ ] Sales reports and exports
- [ ] Multi-language support
- [ ] Dark mode toggle
- [ ] Mobile app for admin panel
- [ ] Integration with payment gateways
- [ ] Email notifications for orders

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for Whiskr Pet Shop**
