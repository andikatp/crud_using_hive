import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final _hiveLearn = Hive.box('hiveLearn');
  List<Map<String, dynamic>> _items = [];

  Future<void> _refreshItem() async {
    final data = _hiveLearn.keys.map((key) {
      final item = _hiveLearn.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _hiveLearn.add(newItem);
    _refreshItem();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _hiveLearn.put(itemKey, item);
    _refreshItem();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _hiveLearn.delete(itemKey);
    _refreshItem();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Item has been deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(hintText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          'name': _nameController.text.trim(),
                          'quantity': _quantityController.text.trim()
                        });
                      }
                      if (itemKey == null) {
                        _createItem({
                          'name': _nameController.text,
                          'quantity': _quantityController.text
                        });
                      }
                      //clear text field
                      _nameController.text = '';
                      _quantityController.text = '';
                      Navigator.pop(ctx);
                    },
                    child: itemKey == null
                        ? const Text('Create New')
                        : const Text('Update')),
                const SizedBox(height: 10),
              ]),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Text('+'),
      ),
      body: FutureBuilder(
        future: _refreshItem(),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final currentItem = _items[index];
                  return Card(
                    color: Colors.orange.shade100,
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        currentItem['name'],
                      ),
                      subtitle: Text(currentItem['quantity'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () =>
                                  _showForm(context, currentItem['key']),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () => _deleteItem(currentItem['key']),
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
