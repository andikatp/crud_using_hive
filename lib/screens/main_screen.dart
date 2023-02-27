import 'package:flutter/material.dart';
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
      return {
        'key': key,
        'name': item['name'],
        'quantity': item['quantity'],
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  void _addItem(Map<String, dynamic> newItem) {
    _itemBox.add(newItem);
    _refreshItem();
  }

  void _deleteItem(int key) {
    _itemBox.delete(key);
    _refreshItem();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleting Item...'),
      duration: Duration(milliseconds: 300),
    ));
  }

  void _updateItem(int key, Map<String, dynamic> newItem) {
    _itemBox.put(key, newItem);
    _refreshItem();
  }

  void _showForm(BuildContext ctx, int? key) {
    if (key != null) {
      final item = _items.firstWhere((item) => item['key'] == key);
      _nameController.text = item['name'];
      _quantityController.text = item['quantity'];
    } else {
      _nameController.text = '';
      _quantityController.text = '';
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: ctx,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Name',
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (key != null) {
                  _updateItem(key, {
                    'name': _nameController.text,
                    'quantity': _quantityController.text,
                  });
                } else {
                  _addItem({
                    'name': _nameController.text,
                    'quantity': _quantityController.text,
                  });
                }
                _nameController.text = '';
                _quantityController.text = '';
                Navigator.pop(context);
              },
              child: Text(key == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Learn'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Text('+'),
      ),
      body: FutureBuilder(
        future: _refreshItem(),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.orange.shade100,
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(_items[index]['name']),
                    subtitle: Text(_items[index]['quantity']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () =>
                                _showForm(context, _items[index]['key']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => _deleteItem(_items[index]['key']),
                            icon: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
