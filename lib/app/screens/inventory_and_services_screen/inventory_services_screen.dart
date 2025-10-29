import 'package:flutter/material.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/inventory_table.dart';

class InventoryServicesScreen extends StatelessWidget {
  const InventoryServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildBody());
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(children: [_BuildHeader()]),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // todo - check type and show correct header
        Text('Inventory', style: theme.textTheme.headlineMedium!.copyWith(fontSize: 24)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: headerInfoList.map((HeaderInventoryModelHelper e) => _BuildHeaderContainer(color: e.color, title: e.title, value: e.value)).toList(),
        ),
        const SizedBox(height: 40),
        _BuildInventoryTable(),
      ],
    );
  }
}

class _BuildHeaderContainer extends StatelessWidget {
  const _BuildHeaderContainer({this.value = 'XXX', this.title = 'total', this.color = Colors.lightGreen});

  final String value;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 340,
      height: 43,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: ColorHelper.white.color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: ColorHelper.white.color),
          ),
        ],
      ),
    );
  }
}

class _BuildInventoryTable extends StatelessWidget {
  const _BuildInventoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    return WAInventoryTable(
      orders: products,
      height: 810,
      onDelete: () {
        debugPrint("DELETE from above");
      },
      onEdit: () {
        debugPrint("edit FROM ABOVE");
      },
    );
  }
}

class HeaderInventoryModelHelper {
  HeaderInventoryModelHelper(this.color, this.title, this.value);

  final String value;
  final String title;
  final Color color;
}

List<HeaderInventoryModelHelper> headerInfoList = [
  HeaderInventoryModelHelper(Color.fromRGBO(152, 188, 109, 1), 'total', '123'),
  HeaderInventoryModelHelper(Color.fromRGBO(242, 163, 0, 1), 'low stock', '12'),
  HeaderInventoryModelHelper(Color.fromRGBO(236, 76, 14, 1), 'out of stock', '7'),
];

final List<WAProduct> products = [
  WAProduct(
    id: '123',
    name: "Dog Food Premium",
    description: "High-quality dry food for adult dogs.",
    brandName: "HappyPaws",
    category: "Food",
    tags: ["dog", "food", "dry"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 50,
    price: 29.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.lowStock.title,
  ),
  WAProduct(
    id: '123wew',
    name: "Cat Food Deluxe",
    description: "Nutritious wet food for cats with chicken flavor.",
    brandName: "MeowMix",
    category: "Food",
    tags: ["cat", "food", "wet"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 80,
    price: 19.49,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '12e2w23',
    name: "Dog Collar Leather",
    description: "Adjustable leather collar for medium dogs.",
    brandName: "PetStyle",
    category: "Accessories",
    tags: ["dog", "collar", "leather"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 120,
    price: 14.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '112w23',
    name: "Cat Toy Ball Set",
    description: "Set of 5 colorful play balls for cats.",
    brandName: "FurFun",
    category: "Toys",
    tags: ["cat", "toy", "play"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 200,
    price: 9.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '12asdsa3',
    name: "Dog Bed Cozy",
    description: "Comfortable round dog bed with removable cover.",
    brandName: "SleepyPets",
    category: "Beds",
    tags: ["dog", "bed", "comfort"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 35,
    price: 49.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.lowStock.title,
  ),
  WAProduct(
    id: '21312',
    name: "Cat Scratching Post",
    description: "Durable scratching post for cats with base support.",
    brandName: "Purrfect",
    category: "Furniture",
    tags: ["cat", "scratching", "furniture"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 0,
    price: 39.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.outOfStock.title,
  ),
  WAProduct(
    id: 'dfld',
    name: "Dog Shampoo Gentle",
    description: "Hypoallergenic dog shampoo with aloe vera.",
    brandName: "CleanTail",
    category: "Grooming",
    tags: ["dog", "shampoo", "care"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 75,
    price: 17.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: 'dfvsdvds',
    name: "Cat Litter Clumping",
    description: "Natural clay clumping litter with lavender scent.",
    brandName: "FreshPaw",
    category: "Hygiene",
    tags: ["cat", "litter", "hygiene"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 90,
    price: 24.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '8937862',
    name: "Dog Leash Nylon",
    description: "Durable nylon leash with reflective stitching.",
    brandName: "WalkMate",
    category: "Accessories",
    tags: ["dog", "leash", "walk"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 100,
    price: 15.49,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.inStock.title,
  ),
  WAProduct(
    id: '[sad89]',
    name: "Cat Bed Cozy Cave",
    description: "Soft enclosed bed for cats to nap comfortably.",
    brandName: "NapNest",
    category: "Beds",
    tags: ["cat", "bed", "comfort"],
    image: ImageModel(
      url: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      thumbnail: 'https://ik.imagekit.io/petpals/pet-recipe-images/1000011769_8k55W-Lis.jpg?updatedAt=1728817523683',
      imageId: "img_001",
    ),
    stockQuantity: 30,
    price: 54.99,
    currency: "BAM",
    active: true,
    status: LowStockProductStatus.lowStock.title,
  ),
];
