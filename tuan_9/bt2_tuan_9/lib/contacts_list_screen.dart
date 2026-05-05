import 'package:flutter/material.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'add_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  List<ContactInfo> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Gọi hàm xin quyền trước khi load danh bạ
    _initializePermissions();
  }

  // Hàm xử lý việc xin quyền từ người dùng
  Future<void> _initializePermissions() async {
    // Yêu cầu quyền truy cập danh bạ
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
    ].request();

    if (statuses[Permission.contacts]!.isGranted) {
      // Nếu được cấp quyền, tiến hành đọc danh bạ
      _loadContacts();
    } else {
      // Nếu bị từ chối, tắt vòng xoay loading và hiện thông báo
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cấp quyền để đọc danh bạ!')),
        );
      }
    }
  }

  // Hàm đọc danh bạ từ hệ thống
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ContactInfo> contacts = await FlutterContactsService.getContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh bạ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddContactScreen(),
                ),
              );
              // Tải lại danh sách sau khi thêm mới một liên hệ
              _initializePermissions();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(child: Text('Không có danh bạ nào.'))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                ContactInfo contact = _contacts[index];
                return ListTile(
                  leading: contact.avatar != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar!),
                        )
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(contact.displayName ?? 'Không có tên'),
                  subtitle: Text(
                    '${(contact.phones != null && contact.phones!.isNotEmpty) ? contact.phones!.first.value ?? 'Không có số' : 'Không có số'}\n'
                    '${(contact.emails != null && contact.emails!.isNotEmpty) ? contact.emails!.first.value ?? 'Không có email' : 'Không có email'}',
                  ),
                );
              },
            ),
    );
  }
}
