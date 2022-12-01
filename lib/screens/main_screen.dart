import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final _itemBox = Hive.box('hiveLearn');
  List<Map<String, dynamic>> _items = [];

  Future<void> _refreshItem() async {
    final data = _itemBox.keys.map((key) {
      final item = _itemBox.get(key);
      return {'key': key, 'name': item['name'], 'quantity': item['quantity']};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
  }

  void _updateItem(int key, Map<String, dynamic> item) {
    _itemBox.put(key, item);
    _refreshItem();
    Navigator.of(context).pop();
  }

  void _createItem(Map<String, dynamic> item) {
    _itemBox.add(item);
    _refreshItem();
    Navigator.of(context).pop();
  }

  void _deleteItem(int key) {
    _itemBox.delete(key);
    _refreshItem();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting Product'),
      ),
    );
  }

  void _showForm(BuildContext ctx, int? key) async {
    if (key != null) {
      final existingItem = _items.firstWhere((item) => item['key'] == key);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      elevation: 5,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 15,
            top: 15,
            left: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Name'),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _quantityController,
                autofocus: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  if (key != null) {
                    _updateItem(key, {
                      'name': _nameController.text.trim(),
                      'quantity': _quantityController.text.trim()
                    });
                  }
                  if (key == null) {
                    _createItem({
                      'name': _nameController.text.trim(),
                      'quantity': _quantityController.text.trim(),
                    });
                  }
                  _nameController.text = '';
                  _quantityController.text = '';
                },
                child:
                    key == null ? const Text('Create') : const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hive'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Text('+'),
      ),
      body: FutureBuilder(
          future: _refreshItem(),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final currentItem = _items[index];
                        return Card(
                          margin: const EdgeInsets.all(20),
                          elevation: 3,
                          color: Colors.orange.shade100,
                          child: ListTile(
                            title: Text(currentItem['name']),
                            subtitle: Text(currentItem['quantity']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () =>
                                        _showForm(context, currentItem['key']),
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () =>
                                        _deleteItem(currentItem['key']),
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
    );
  }
}
