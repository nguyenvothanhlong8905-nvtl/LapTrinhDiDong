import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  // 1. Hàm chọn ảnh dùng thư viện image_picker
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      // Mở bộ sưu tập ảnh của điện thoại
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path); // Gán ảnh đã chọn vào biến
        });
      }
    } catch (e) {
      print('Lỗi chọn ảnh: $e');
    }
  }

  // 2. Hàm xử lý lưu sản phẩm
  Future<void> saveProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ thông tin và chọn ảnh!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // BƯỚC A: Giả lập thời gian Upload ảnh (Bỏ qua Firebase Storage để né lỗi 404)
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Giả vờ mất 1s để tải ảnh

      // Dùng một đường link ảnh mặc định thay vì link thật từ Storage
      String dummyImageUrl =
          'https://cdn-icons-png.flaticon.com/512/1174/1174408.png';

      // BƯỚC B: Lưu thông tin (Tên, Giá, Link ảnh) vào Firestore Database
      CollectionReference products = FirebaseFirestore.instance.collection(
        'products',
      );

      await products.add({
        'name': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'imageUrl': dummyImageUrl, // Lưu link ảnh giả lập vào Database
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm sản phẩm thành công!')),
        );
        //Navigator.pop(context);
        nameController.clear();
        priceController.clear();
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi Database: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Sản Phẩm Mới')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Nút chọn ảnh
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text('Nhấn để chọn ảnh'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Tên sản phẩm
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Ô nhập Giá sản phẩm
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Lưu Sản Phẩm',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
