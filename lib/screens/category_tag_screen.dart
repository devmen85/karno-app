import 'package:flutter/material.dart';
import '../models/category_tag.dart';
import '../services/woocommerce_api.dart';

class CategoryTagScreen extends StatefulWidget {
  const CategoryTagScreen({super.key});

  @override
  State<CategoryTagScreen> createState() => _CategoryTagScreenState();
}

class _CategoryTagScreenState extends State<CategoryTagScreen> with SingleTickerProviderStateMixin {
  final _api = WooCommerceApi();
  late TabController _tabController;

  List<ProductCategory> _categories = [];
  List<ProductTag> _tags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final categories = await _api.getCategories();
    final tags = await _api.getTags();
    setState(() {
      _categories = categories;
      _tags = tags;
      _loading = false;
    });
  }

  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('دسته‌بندی جدید'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'نام دسته')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('افزودن')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await _api.createCategory(name.trim());
      _load();
    }
  }

  Future<void> _addTagDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('برچسب جدید'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'نام برچسب')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('افزودن')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await _api.createTag(name.trim());
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دسته‌بندی‌ها و برچسب‌ها'),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: 'دسته‌بندی‌ها'),
          Tab(text: 'برچسب‌ها'),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.count} محصول'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _api.deleteCategory(c.id);
                            _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final t = _tags[index];
                      return ListTile(
                        title: Text(t.name),
                        subtitle: Text('${t.count} محصول'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _api.deleteTag(t.id);
                            _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0 ? _addCategoryDialog() : _addTagDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
