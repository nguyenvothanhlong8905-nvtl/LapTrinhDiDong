import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'db_helper.dart';

class AddContactScreen extends StatefulWidget {
  final Map<String, dynamic>? contact; // Nhận dữ liệu nếu ở chế độ Sửa
  const AddContactScreen({super.key, this.contact});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _avatarFile;
  Uint8List? _existingAvatarBytes;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.contact!['name'] ?? '';
      _phoneController.text = widget.contact!['phone'] ?? '';
      _emailController.text = widget.contact!['email'] ?? '';
      _existingAvatarBytes = widget.contact!['avatar'];
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
        _existingAvatarBytes = null; // Bỏ ảnh cũ nếu người dùng chọn ảnh mới
      });
    }
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên và số điện thoại không được để trống!'),
        ),
      );
      return;
    }

    final contactData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'avatar': _avatarFile != null
          ? await _avatarFile!.readAsBytes()
          : _existingAvatarBytes,
    };

    if (_isEditing) {
      await DBHelper().updateContact(widget.contact!['id'], contactData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật danh bạ thành công!')),
      );
    } else {
      await DBHelper().insertContact(contactData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm danh bạ thành công!')));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa danh bạ' : 'Thêm danh bạ'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _avatarFile != null
                    ? FileImage(_avatarFile!) as ImageProvider
                    : (_existingAvatarBytes != null
                          ? MemoryImage(_existingAvatarBytes!)
                          : null),
                child: (_avatarFile == null && _existingAvatarBytes == null)
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Lưu', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
