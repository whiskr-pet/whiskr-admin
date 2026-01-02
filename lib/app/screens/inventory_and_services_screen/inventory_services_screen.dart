import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/text_fields/wa_custom_search_text.dart';
import 'package:w_components/wa_custom_inventory_data_widget/wa_custom_inventory_data_widget.dart';
import 'package:w_components/wa_inventory_table/wa_inventory_table.dart';
import 'package:w_components/wa_services_table/wa_services_table.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:w_utils/w_utils.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';
import 'package:wa_inventory_services_module/models/wa_services_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_search_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_service_offered_search_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_services_screen_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/service_offered_utils/service_offered_action_utils.dart';

import '../../../localization_models/localization_models.dart';
import '../../helpers/utils/inventory_utils/inventory_action_utils.dart';
import '../../providers/texts_provider.dart';
import 'inventory/inventory_filters.dart';

class InventoryServicesScreen extends StatefulWidget {
  const InventoryServicesScreen({super.key});

  @override
  State<InventoryServicesScreen> createState() => _InventoryServicesScreenState();
}

class _InventoryServicesScreenState extends State<InventoryServicesScreen> {
  late WAInventorySearchProvider searchProvider;
  late WaServiceOfferedSearchProvider serviceSearchProvider;
  bool? _isTypeShop;

  @override
  void initState() {
    super.initState();
    searchProvider = WAInventorySearchProvider();
    serviceSearchProvider = WaServiceOfferedSearchProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialData();
    });
  }

  Future<void> _getInitialData() async {
    final WAInventoryServicesProvider provider = context.read<WAInventoryServicesProvider>();
    final WAServicesProvider serviceOffersProvider = context.read<WAServicesProvider>();
    final bool isTypeShop = await ServiceTypeService.getServiceType();
    setState(() {
      _isTypeShop = isTypeShop;
    });
    provider.setLoading(true);
    if (isTypeShop) {
      await Future.wait([provider.getInventoryStats(), provider.getAllProducts(), provider.getInventoryCategories(), provider.getInventoryTags()]);
    } else {
      await Future.wait([serviceOffersProvider.getAllOffers(), serviceOffersProvider.getServiceOfferedTags(), serviceOffersProvider.getServiceOfferedCategories()]);
    }
    provider.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while determining service type
    if (_isTypeShop == null) {
      return Scaffold(body: Center(child: LoadingAnimationHelper.loading));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: searchProvider),
        ChangeNotifierProvider.value(value: serviceSearchProvider),
      ],
      builder: (context, child) {
        return Scaffold(body: _BuildBody(isTypeShop: _isTypeShop!));
      },
    );
  }

  @override
  void dispose() {
    searchProvider.dispose();
    serviceSearchProvider.dispose();
    super.dispose();
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({required this.isTypeShop});

  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 32.0, desktop: 40.0, widescreen: 48.0);
    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        children: [
          _BuildHeader(isTypeShop: isTypeShop),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
          isTypeShop ? _BuildInventoryTable() : _BuildServicesTable(),
          const SizedBox(height: 30),
          const _BuildPaginationControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({required this.isTypeShop});

  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 28.0, desktop: 32.0, widescreen: 36.0);
    final isTablet = Responsive.isTablet(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
    final ServiceOfferedText serviceTexts = TextsProvider.of(context)!.serviceOfferedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isTypeShop ? texts.inventoryTitle : serviceTexts.serviceOfferedServicesTitle, style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize)),
        SizedBox(height: Responsive.value(context: context, mobile: 25.0, tablet: 20.0, desktop: 25.0, widescreen: 30.0)),
        AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, child: isTablet ? _buildTabletLayout(context) : _buildDesktopLayout(context)),
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
              Expanded(child: _BuildAddInventoryOrServiceButton(isTypeShop: isTypeShop)),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: WASearchTextField(onChanged: (String value) => InventoryActionUtils.handleSearch(value, context)),
                ),
              ),
            ],
          ),
          if (isTypeShop)
            Consumer<WAInventoryServicesProvider>(
              builder: (BuildContext context, WAInventoryServicesProvider provider, child) {
                return InventoryFiltersWidget(availableCategories: provider.inventoryCategories, availableTags: provider.inventoryTags);
              },
            ),
          const SizedBox(height: 16),
          if (isTypeShop)
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
    final controlsWidth = Responsive.value(context: context, mobile: 500.0, tablet: 400.0, desktop: 400.0, widescreen: 550.0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: controlsWidth,
                child: WASearchTextField(
                  onChanged: (String value) => isTypeShop ? InventoryActionUtils.handleSearch(value, context) : ServiceOfferedActionUtils.handleSearch(value, context),
                ),
              ),
              _BuildAddInventoryOrServiceButton(isTypeShop: isTypeShop),
            ],
          ),
          const SizedBox(height: 20),
          if (isTypeShop)
            Consumer<WAInventoryServicesProvider>(
              builder: (BuildContext context, WAInventoryServicesProvider provider, child) {
                return InventoryFiltersWidget(availableCategories: provider.inventoryCategories, availableTags: provider.inventoryTags);
              },
            ),
        ],
      ),
    );
  }
}

class _BuildAddInventoryOrServiceButton extends StatelessWidget {
  const _BuildAddInventoryOrServiceButton({required this.isTypeShop});

  final bool isTypeShop;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.value(context: context, mobile: 45.0, tablet: 45.0, desktop: 45.0, widescreen: 48.0);
    final isTablet = Responsive.isTablet(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
    final ServiceOfferedText serviceTexts = TextsProvider.of(context)!.serviceOfferedText;

    return SizedBox(
      width: isTablet ? null : Responsive.value(context: context, mobile: 500.0, tablet: null, desktop: 500.0, widescreen: 550.0),
      height: buttonHeight,
      child: CommonButton(
        onPressed: () async => isTypeShop
            ? await InventoryActionUtils.onAddInventoryItem(context.read<WAInventoryServicesProvider>(), context)
            : await ServiceOfferedActionUtils.onAddServiceOffered(context.read<WAServicesProvider>(), context),
        buttonTitle: isTypeShop ? texts.addInventoryButton : serviceTexts.serviceOfferedAddService,
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

    return Consumer2<WAInventoryServicesProvider, WAInventorySearchProvider>(
      builder: (context, inventoryProvider, searchProvider, child) {
        final bool isSearchMode = inventoryProvider.isSearchMode;
        final bool isLoading = isSearchMode ? searchProvider.isLoading : inventoryProvider.isLoading;
        final List<WAProduct> products = isSearchMode ? searchProvider.items : inventoryProvider.products;
        final String? error = isSearchMode ? searchProvider.error : null;

        if (isLoading) {
          return SizedBox(
            height: tableHeight,
            child: Center(child: LoadingAnimationHelper.loading),
          );
        }

        if (error != null) {
          return SizedBox(
            height: tableHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => searchProvider.refresh(), child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        if (products.isEmpty) {
          return SizedBox(
            height: tableHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(isSearchMode ? 'No products found' : 'No products available', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  if (isSearchMode) ...[const SizedBox(height: 8), Text('Try adjusting your search', style: TextStyle(fontSize: 14, color: Colors.grey[500]))],
                ],
              ),
            ),
          );
        }

        return WAInventoryTable(
          orders: products,
          height: tableHeight,
          onDelete: (String id, String inventoryName) async {
            helper.showDeleteDialog(context, id, inventoryName);
          },
          onEdit: (WAProduct product) async {
            await InventoryActionUtils.onEditInventory(product, inventoryProvider, context);
            if (isSearchMode) {
              await searchProvider.refresh();
            } else {
              await inventoryProvider.getAllProducts();
            }
          },
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

    return Consumer2<WAInventoryServicesProvider, WAInventorySearchProvider>(
      builder: (context, inventoryProvider, searchProvider, child) {
        final bool isSearchMode = inventoryProvider.isSearchMode;

        final int currentPage = isSearchMode ? searchProvider.currentPage : inventoryProvider.currentPage;
        final int totalPages = isSearchMode ? searchProvider.totalPages : inventoryProvider.totalPages;
        final bool hasPrevious = isSearchMode ? searchProvider.hasPreviousPage : inventoryProvider.hasPreviousPage;
        final bool hasNext = isSearchMode ? searchProvider.hasNextPage : inventoryProvider.hasNextPage;

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
                  onPressed: hasPrevious
                      ? () {
                          if (isSearchMode) {
                            searchProvider.previousPage();
                          } else {
                            inventoryProvider.loadPreviousPage();
                          }
                        }
                      : null,
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
                  onPressed: hasNext
                      ? () {
                          if (isSearchMode) {
                            searchProvider.nextPage();
                          } else {
                            inventoryProvider.loadNextPage();
                          }
                        }
                      : null,
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
    final ServiceOfferedText serviceTexts = TextsProvider.of(context)!.serviceOfferedText;

    return Consumer2<WAServicesProvider, WaServiceOfferedSearchProvider>(
      builder: (context, serviceOfferedProvider, searchProvider, child) {
        final bool isSearchMode = serviceOfferedProvider.isSearchMode;
        final bool isLoading = isSearchMode ? searchProvider.isLoading : serviceOfferedProvider.isLoading;
        final List<WAServiceOfferedModel> offers = isSearchMode ? searchProvider.items : serviceOfferedProvider.serviceOfferedList;
        final String? error = isSearchMode ? searchProvider.error : null;

        if (isLoading) {
          return SizedBox(
            height: tableHeight,
            child: Center(child: LoadingAnimationHelper.loading),
          );
        }

        if (error != null) {
          return SizedBox(
            height: tableHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('${serviceTexts.serviceOfferedErrorPrefix}: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => searchProvider.refresh(), child: Text(serviceTexts.serviceOfferedRetry)),
                ],
              ),
            ),
          );
        }

        if (offers.isEmpty) {
          return SizedBox(
            height: tableHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isSearchMode ? serviceTexts.serviceOfferedNoOffersFound : serviceTexts.serviceOfferedNoOffersAvailable,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  if (isSearchMode) ...[const SizedBox(height: 8), Text(serviceTexts.serviceOfferedTryAdjustingSearch, style: TextStyle(fontSize: 14, color: Colors.grey[500]))],
                ],
              ),
            ),
          );
        }

        return WaServicesTable(
          services: offers,
          height: tableHeight,
          onDelete: (String id, String serviceName) {
            helper.showDeleteDialogServiceOffered(context, id, serviceName);
          },
          onEdit: (WAServiceOfferedModel offer) async {
            await ServiceOfferedActionUtils.onEditOffer(offer, serviceOfferedProvider, context);
          },
        );
      },
    );
  }
}
