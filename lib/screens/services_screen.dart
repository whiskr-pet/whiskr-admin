import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../models/service_offering.dart';
import '../utils/app_theme.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Offered'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onTypeSelected,
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(value: 'all', child: Text('All Types')),
              PopupMenuItem(value: 'grooming', child: Text('Grooming')),
              PopupMenuItem(value: 'walking', child: Text('Walking')),
              PopupMenuItem(value: 'training', child: Text('Training')),
              PopupMenuItem(value: 'boarding', child: Text('Boarding')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _showAddEditDialog, label: const Text('Add Service'), icon: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search services...',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (String value) => Provider.of<ServiceProvider>(context, listen: false).setSearchQuery(value),
            ),
          ),
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (BuildContext context, ServiceProvider provider, Widget? child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading services',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: provider.loadServices, child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                final List<ServiceOffering> services = provider.filteredServices;
                if (services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.room_service_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          provider.searchQuery.isNotEmpty ? 'No services found' : 'No services yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.searchQuery.isNotEmpty ? 'Try adjusting your search terms' : 'Add your first service to get started',
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                        ),
                        if (provider.searchQuery.isEmpty) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(onPressed: _showAddEditDialog, icon: const Icon(Icons.add), label: const Text('Add Service')),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadServices,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.25,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: services.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ServiceOffering service = services[index];
                      return _ServiceCard(
                        service: service,
                        onTap: () => _showDetails(service),
                        onEdit: () => _showAddEditDialog(service: service),
                        onDelete: () => _confirmDelete(service),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onTypeSelected(String value) => Provider.of<ServiceProvider>(context, listen: false).setSelectedType(value);

  Future<void> _confirmDelete(ServiceOffering service) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final bool success = await Provider.of<ServiceProvider>(context, listen: false).deleteService(service.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service deleted')));
      }
    }
  }

  void _showDetails(ServiceOffering service) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(service.name),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${service.type}'),
              Text('Price: \$${service.price.toStringAsFixed(2)}'),
              if (service.durationMinutes != null) Text('Duration: ${service.durationMinutes} min'),
              const SizedBox(height: 8),
              Text('Status: ${service.isActive ? 'Active' : 'Inactive'}'),
              const SizedBox(height: 12),
              Text('Description: ${service.description}'),
              if (service.tags.isNotEmpty) ...[const SizedBox(height: 8), Text('Tags: ${service.tags.join(', ')}')],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showAddEditDialog(service: service);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({ServiceOffering? service}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _AddEditServiceDialog(service: service),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceOffering service;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({required this.service, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.room_service, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Switch(value: service.isActive, onChanged: (_) {}),
                ],
              ),
              const Spacer(),
              Text(service.type.toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text('\$${service.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18)),
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddEditServiceDialog extends StatefulWidget {
  final ServiceOffering? service;
  const _AddEditServiceDialog({this.service});

  @override
  State<_AddEditServiceDialog> createState() => _AddEditServiceDialogState();
}

class _AddEditServiceDialogState extends State<_AddEditServiceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  String _type = 'grooming';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(text: widget.service != null ? widget.service!.price.toStringAsFixed(2) : '');
    _durationController = TextEditingController(text: widget.service?.durationMinutes?.toString() ?? '');
    _type = widget.service?.type ?? 'grooming';
    _isActive = widget.service?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.service != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Service' : 'Add Service'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (String? value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  onChanged: (String? value) => setState(() => _type = value ?? 'grooming'),
                  items: const [
                    DropdownMenuItem(value: 'grooming', child: Text('Grooming')),
                    DropdownMenuItem(value: 'walking', child: Text('Walking')),
                    DropdownMenuItem(value: 'training', child: Text('Training')),
                    DropdownMenuItem(value: 'boarding', child: Text('Boarding')),
                  ],
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Price', prefixText: '\$', border: OutlineInputBorder()),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return 'Please enter a price';
                    final double? parsed = double.tryParse(value);
                    if (parsed == null) return 'Please enter a valid number';
                    if (parsed < 0) return 'Price must be positive';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(value: _isActive, onChanged: (bool v) => setState(() => _isActive = v), title: const Text('Active')),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Create')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final double price = double.parse(_priceController.text.trim());
    final int? duration = _durationController.text.trim().isEmpty ? null : int.tryParse(_durationController.text.trim());
    final ServiceOffering draft = ServiceOffering(
      id: widget.service?.id ?? 'service_${DateTime.now().millisecondsSinceEpoch}',
      shopId: 'demo_shop_1',
      name: _nameController.text.trim(),
      type: _type,
      description: _descriptionController.text.trim(),
      price: price,
      durationMinutes: duration,
      tags: const <String>[],
      isActive: _isActive,
      imageUrl: null,
      createdAt: widget.service?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final ServiceProvider provider = Provider.of<ServiceProvider>(context, listen: false);
    if (widget.service == null) {
      await provider.createService(draft);
    } else {
      await provider.updateService(widget.service!.id, draft);
    }

    if (mounted) Navigator.of(context).pop();
  }
}
