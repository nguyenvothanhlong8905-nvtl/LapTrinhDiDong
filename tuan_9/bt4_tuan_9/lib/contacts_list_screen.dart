import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  List<Map<String, dynamic>> _allContacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });
    final contacts = await DBHelper().getContacts();
    setState(() {
      _allContacts = contacts;
      _filteredContacts = contacts;
      _isLoading = false;
    });
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _allContacts;
      });
      return;
    }
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final name = contact['name']?.toString().toLowerCase() ?? '';
        final phone = contact['phone']?.toString() ?? '';
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) || phone.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteContact(int id) async {
    await DBHelper().deleteContact(id);
    _loadContacts();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa danh bạ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Contacts',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContactScreen(),
                ),
              );
              _loadContacts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                ? const Center(child: Text('Không tìm thấy danh bạ nào.'))
                : ListView.separated(
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return Dismissible(
                        key: Key(contact['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteContact(contact['id']);
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: contact['avatar'] != null
                              ? CircleAvatar(
                                  radius: 26,
                                  backgroundImage: MemoryImage(
                                    contact['avatar'],
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.blueAccent
                                      .withOpacity(0.2),
                                  child: Text(
                                    contact['name'] != null &&
                                            contact['name'].isNotEmpty
                                        ? contact['name'][0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          title: Text(
                            contact['name'] ?? 'Không có tên',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(contact['phone'] ?? ''),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddContactScreen(contact: contact),
                              ),
                            );
                            _loadContacts();
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
}
