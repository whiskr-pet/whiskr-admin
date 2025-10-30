import 'package:flutter/material.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/text_fields/wa_custom_search_text.dart';
import 'package:w_components/wa_custom_inventory_data_widget/wa_custom_inventory_data_widget.dart';
import 'package:w_components/wa_inventory_table/wa_inventory_table.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_stats_model.dart';

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
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 16.0, desktop: 24.0, widescreen: 32.0);

    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        children: [
          _BuildHeader(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
          const _BuildInventoryTable(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 22.0, desktop: 24.0, widescreen: 28.0);
    final isTablet = Responsive.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inventory', style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize)),
        SizedBox(height: Responsive.value(context: context, mobile: 25.0, tablet: 20.0, desktop: 25.0, widescreen: 30.0)),
        Card(
          color: ColorHelper.white.color,
          child: SizedBox(
            height: Responsive.value(context: context, mobile: 320.0, tablet: 370.0, desktop: 330.0, widescreen: 370.0),
            child: isTablet ? _buildTabletLayout(context) : _buildDesktopLayout(context),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _BuildAddInventoryOrServiceButton()),
              const SizedBox(width: 12),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: WASearchTextField(onChanged: _handleSearch),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: InventorySummaryWidget(
              stats: InventoryStats(total: 123, lowStock: 12, outOfStock: 7),
              onTotalTap: () => debugPrint('Total tapped'),
              onLowStockTap: () => debugPrint('Low stock tapped'),
              onOutOfStockTap: () => debugPrint('Out of stock tapped'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final summaryWidth = Responsive.value(context: context, mobile: 800.0, tablet: 600.0, desktop: 800.0, widescreen: 900.0);
    final controlsWidth = Responsive.value(context: context, mobile: 500.0, tablet: 400.0, desktop: 400.0, widescreen: 550.0);
    final spacing = Responsive.value(context: context, mobile: 50.0, tablet: 30.0, desktop: 50.0, widescreen: 60.0);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: summaryWidth,
            child: InventorySummaryWidget(
              stats: InventoryStats(total: 123, lowStock: 12, outOfStock: 7),
              onTotalTap: () => print('Total tapped'),
              onLowStockTap: () => print('Low stock tapped'),
              onOutOfStockTap: () => print('Out of stock tapped'),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _BuildAddInventoryOrServiceButton(),
                SizedBox(
                  width: controlsWidth,
                  child: const WASearchTextField(onChanged: _handleSearch),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _handleSearch(String value) {
    debugPrint("Searching for: $value");
  }
}

class _BuildAddInventoryOrServiceButton extends StatelessWidget {
  const _BuildAddInventoryOrServiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.value(context: context, mobile: 45.0, tablet: 45.0, desktop: 45.0, widescreen: 48.0);
    final isTablet = Responsive.isTablet(context);

    return SizedBox(
      width: isTablet ? null : Responsive.value(context: context, mobile: 500.0, tablet: null, desktop: 500.0, widescreen: 550.0),
      height: buttonHeight,
      child: CommonButton(onPressed: () {}, buttonTitle: '+ Add Inventory', buttonType: PPButtonType.web, showBorder: false),
    );
  }
}

class _BuildInventoryTable extends StatelessWidget {
  const _BuildInventoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    final tableHeight = Responsive.value(context: context, mobile: 640.0, tablet: 500.0, desktop: 640.0, widescreen: 720.0);

    return WAInventoryTable(
      orders: products,
      height: tableHeight,
      onDelete: () {
        debugPrint("DELETE from above");
      },
      onEdit: () {
        debugPrint("edit FROM ABOVE");
      },
    );
  }
}

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
];
