import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/woocommerce_api.dart';

/// If [product] is null, this screen creates a new product.
/// Otherwise it edits the existing one.
class ProductEditScreen extends StatefulWidget {
  final Product? product;
  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = WooCommerceApi();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;
  bool _manageStock = true;
  String _stockStatus = 'instock';
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.regularPrice ?? '');
    _stockController = TextEditingController(text: p?.stockQuantity.toString() ?? '0');
    _descController = TextEditingController(text: p?.description ?? '');
    _manageStock = p?.manageStock ?? true;
    _stockStatus = p?.stockStatus ?? 'instock';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final product = Product(
      id: widget.product?.id ?? 0,
      name: _nameController.text.trim(),
      slug: widget.product?.slug ?? '',
      type: widget.product?.type ?? 'simple',
      status: widget.product?.status ?? 'publish',
      description: _descController.text.trim(),
      shortDescription: widget.product?.shortDescription ?? '',
      regularPrice: _priceController.text.trim(),
      salePrice: widget.product?.salePrice ?? '',
      price: _priceController.text.trim(),
      stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
      stockStatus: _stockStatus,
      manageStock: _manageStock,
      imageUrls: widget.product?.imageUrls ?? [],
      categoryIds: widget.product?.categoryIds ?? [],
    );

    try {
      if (_isEditing) {
        await _api.updateProduct(widget.product!.id, product);
      } else {
        await _api.createProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در ذخیره محصول')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف محصول'),
        content: const Text('آیا از حذف این محصول مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await _api.deleteProduct(widget.product!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش محصول' : 'محصول جدید'),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام محصول', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'الزامی' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'قیمت (تومان)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'الزامی' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('مدیریت موجودی انبار'),
              value: _manageStock,
              onChanged: (v) => setState(() => _manageStock = v),
            ),
            if (_manageStock)
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'تعداد موجودی', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _stockStatus,
              decoration: const InputDecoration(labelText: 'وضعیت موجودی', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'instock', child: Text('موجود')),
                DropdownMenuItem(value: 'outofstock', child: Text('ناموجود')),
                DropdownMenuItem(value: 'onbackorder', child: Text('پیش‌سفارش')),
              ],
              onChanged: (v) => setState(() => _stockStatus = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'توضیحات', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
