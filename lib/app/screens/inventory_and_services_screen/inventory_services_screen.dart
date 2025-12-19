import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/text_fields/wa_custom_search_text.dart';
import 'package:w_components/wa_custom_inventory_data_widget/wa_custom_inventory_data_widget.dart';
import 'package:w_components/wa_inventory_table/wa_inventory_table.dart';
import 'package:w_components/wa_services_table/wa_services_table.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';
import 'package:wa_inventory_services_module/models/wa_services_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_services_screen_helper.dart';

import '../../../localization_models/localization_models.dart';
import '../../helpers/utils/inventory_utils/inventory_action_utils.dart';
import '../../providers/texts_provider.dart';

class InventoryServicesScreen extends StatefulWidget {
  const InventoryServicesScreen({super.key});

  @override
  State<InventoryServicesScreen> createState() => _InventoryServicesScreenState();
}

class _InventoryServicesScreenState extends State<InventoryServicesScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialData();
    });
    super.initState();
  }

  Future<void> _getInitialData() async {
    final WAInventoryServicesProvider provider = context.read<WAInventoryServicesProvider>();
    provider.setLoading(true);
    await Future.wait([provider.getInventoryStats(), provider.getAllProducts()]);
    provider.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildBody());
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0);
    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        children: [
          _BuildHeader(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
          _BuildInventoryTable(),
          const SizedBox(height: 30),
          const _BuildPaginationControls(),
          // todo when BE is ready
          // _BuildServicesTable(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 36.0);
    final isTablet = Responsive.isTablet(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.inventoryTitle, style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize)),
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
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: WASearchTextField(
                    onChanged: (String value) {
                      _handleSearch(value, context);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(
              builder: (BuildContext context, WAInventoryServicesProvider provider, Widget? child) {
                return InventorySummaryWidget(
                  stats: provider.inventoryStats,
                  onTotalTap: () => provider.clearStatusFilter(),
                  onLowStockTap: () => provider.setStatusFilter(LowStockProductStatus.lowStock),
                  onOutOfStockTap: () => provider.setStatusFilter(LowStockProductStatus.outOfStock),
                );
              },
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
            child: Consumer(
              builder: (BuildContext context, WAInventoryServicesProvider provider, Widget? child) {
                return InventorySummaryWidget(
                  stats: provider.inventoryStats,
                  onTotalTap: () => provider.clearStatusFilter(),
                  onLowStockTap: () => provider.setStatusFilter(LowStockProductStatus.lowStock),
                  onOutOfStockTap: () => provider.setStatusFilter(LowStockProductStatus.outOfStock),
                );
              },
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
                  child: WASearchTextField(
                    onChanged: (String value) {
                      _handleSearch(value, context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _handleSearch(String value, BuildContext context) {
    context.read<WAInventoryServicesProvider>().updateSearchQuery(value);
  }
}

class _BuildAddInventoryOrServiceButton extends StatelessWidget {
  const _BuildAddInventoryOrServiceButton();

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.value(context: context, mobile: 45.0, tablet: 45.0, desktop: 45.0, widescreen: 48.0);
    final isTablet = Responsive.isTablet(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    return SizedBox(
      width: isTablet ? null : Responsive.value(context: context, mobile: 500.0, tablet: null, desktop: 500.0, widescreen: 550.0),
      height: buttonHeight,
      child: CommonButton(
        onPressed: () async => await InventoryActionUtils.onAddInventoryItem(context.read<WAInventoryServicesProvider>(), context),
        buttonTitle: texts.addInventoryButton,
        buttonType: PPButtonType.web,
        showBorder: false,
      ),
    );
  }
}

class _BuildInventoryTable extends StatelessWidget {
  _BuildInventoryTable();
  final InventoryServicesHelper helper = InventoryServicesHelper();

  @override
  Widget build(BuildContext context) {
    final tableHeight = Responsive.value(context: context, mobile: 640.0, tablet: 500.0, desktop: 640.0, widescreen: 720.0);

    return Selector<WAInventoryServicesProvider, bool>(
      selector: (_, provider) => provider.isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return Center(child: LoadingAnimationHelper.loading);
        }
        return WAInventoryTable(
          orders: context.watch<WAInventoryServicesProvider>().products,
          height: tableHeight,
          onDelete: (String id, String inventoryName) {
            helper.showDeleteDialog(context, id, inventoryName);
          },
          onEdit: (WAProduct product) async => await InventoryActionUtils.onEditInventory(product, context.read<WAInventoryServicesProvider>(), context),
        );
      },
    );
  }
}

class _BuildPaginationControls extends StatelessWidget {
  const _BuildPaginationControls();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    return Consumer<WAInventoryServicesProvider>(
      builder: (context, provider, child) {
        final currentPage = provider.currentPage;
        final totalPages = provider.totalPages;
        final hasPrevious = provider.hasPreviousPage;
        final hasNext = provider.hasNextPage;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: Responsive.value(context: context, mobile: 0.0, tablet: 0.0, desktop: 0.0, widescreen: 0.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.value(context: context, mobile: 20.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0),
              vertical: Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 24.0, widescreen: 28.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PaginationButton(
                  icon: Icons.chevron_left_rounded,
                  label: isMobile ? null : texts.inventoryPreviousButton,
                  onPressed: hasPrevious ? () => provider.loadPreviousPage() : null,
                  isEnabled: hasPrevious,
                  width: isMobile ? 48 : 140,
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 28.0, widescreen: 32.0),
                    vertical: Responsive.value(context: context, mobile: 10.0, tablet: 12.0, desktop: 14.0, widescreen: 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: ColorHelper.green300.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        texts.inventoryPage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: ColorHelper.greenWeb.color, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '$currentPage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 16.0),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        texts.inventoryPageOf,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 15.0),
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalPages',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 16.0),
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                _PaginationButton(
                  icon: Icons.chevron_right_rounded,
                  label: isMobile ? null : texts.inventoryNextButton,
                  onPressed: hasNext ? () => provider.loadNextPage() : null,
                  isEnabled: hasNext,
                  isNext: true,
                  width: isMobile ? 48 : 140,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaginationButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isNext;
  final double width;

  const _PaginationButton({required this.icon, this.label, this.onPressed, required this.isEnabled, this.isNext = false, required this.width});

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width,
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isEnabled
                ? (_isHovered
                      ? LinearGradient(
                          colors: [ColorHelper.greenWeb.color, ColorHelper.greenWeb.color.withValues(alpha: 0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [ColorHelper.greenWeb.color.withValues(alpha: 0.1), ColorHelper.greenWeb.color.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ))
                : null,
            color: widget.isEnabled ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isEnabled ? (_isHovered ? ColorHelper.greenWeb.color : ColorHelper.greenWeb.color.withValues(alpha: 0.3)) : Colors.grey[300]!,
              width: _isHovered && widget.isEnabled ? 2 : 1.5,
            ),
            boxShadow: _isHovered && widget.isEnabled ? [BoxShadow(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.isNext && widget.label != null)
                Icon(widget.icon, size: 20, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
              if (widget.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400],
                  ),
                ),
              ],
              if (widget.label == null) Icon(widget.icon, size: 24, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
              if (widget.isNext && widget.label != null)
                Icon(widget.icon, size: 20, color: widget.isEnabled ? (_isHovered ? Colors.white : ColorHelper.greenWeb.color) : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildServicesTable extends StatelessWidget {
  _BuildServicesTable();
  final InventoryServicesHelper helper = InventoryServicesHelper();

  @override
  Widget build(BuildContext context) {
    final tableHeight = Responsive.value(context: context, mobile: 640.0, tablet: 500.0, desktop: 640.0, widescreen: 720.0);

    return WaServicesTable(
      services: _localServices,
      height: tableHeight,
      onDelete: (String id, String serviceName) {
        // helper.showDeleteDialog(context, id, serviceName);
      },
      onEdit: (String id) {
        debugPrint("edit FROM ABOVE");
      },
    );
  }
}

final List<WAServiceModel> _localServices = [
  WAServiceModel(
    id: '1',
    name: 'Basic Bath & Brush',
    description: 'Includes bath, blow dry, brushing, and light trimming. Perfect for quick clean-ups.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/bath_brush.jpg', thumbnail: 'https://example.com/thumbs/bath_brush.jpg'),
    price: 25.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '2',
    name: 'Full Grooming Package',
    description: 'Complete grooming with bath, haircut, nail trim, ear cleaning, and paw care.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/full_grooming.jpg', thumbnail: 'https://example.com/thumbs/full_grooming.jpg'),
    price: 45.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '3',
    name: 'Puppy Intro Grooming',
    description: 'Gentle introduction to grooming for puppies. Includes light wash, brushing, and nail trimming.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/puppy_groom.jpg', thumbnail: 'https://example.com/thumbs/puppy_groom.jpg'),
    price: 20.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '4',
    name: 'De-Shedding Treatment',
    description: 'Reduces shedding with deep conditioning, brushing, and blowout using special tools.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/deshedding.jpg', thumbnail: 'https://example.com/thumbs/deshedding.jpg'),
    price: 35.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '5',
    name: 'Nail Clipping & Paw Care',
    description: 'Quick nail trim, paw pad cleaning, and moisturizing treatment.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/nail_care.jpg', thumbnail: 'https://example.com/thumbs/nail_care.jpg'),
    price: 15.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '6',
    name: 'Ear Cleaning & Hygiene',
    description: 'Safe and gentle ear cleaning to remove dirt and reduce odor or infection risk.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/ear_clean.jpg', thumbnail: 'https://example.com/thumbs/ear_clean.jpg'),
    price: 10.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '7',
    name: 'Teeth Brushing & Breath Freshener',
    description: 'Brushing with pet-safe toothpaste and finishing spray for fresh breath.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/teeth_clean.jpg', thumbnail: 'https://example.com/thumbs/teeth_clean.jpg'),
    price: 12.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '8',
    name: 'Spa & Aromatherapy Bath',
    description: 'Relaxing spa bath with natural oils and aromatherapy massage for pets.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/spa_bath.jpg', thumbnail: 'https://example.com/thumbs/spa_bath.jpg'),
    price: 50.0,
    currency: 'BAM',
    active: true,
  ),
];
