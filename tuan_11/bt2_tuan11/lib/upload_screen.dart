import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  String? _fileName;
  double _progress = 0.0;
  String _uploadStatus = '';

  // Hàm 1: Mở thư viện chọn file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _progress = 0.0;
        _uploadStatus = 'Đã chọn file, sẵn sàng...';
      });
    }
  }

  // Hàm 2: Giả lập quá trình Upload (không cần Firebase)
  void simulateUpload() async {
    if (_selectedFile == null) return;

    setState(() {
      _uploadStatus = 'Đang tải lên...';
      _progress = 0.0;
    });

    // Vòng lặp giả lập tiến trình chạy từ 1 đến 100
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(
        const Duration(milliseconds: 30),
      ); // Đợi một chút xíu
      if (!mounted) return;

      setState(() {
        _progress = i / 100;
      });
    }

    setState(() {
      _uploadStatus = 'Tải lên hoàn tất!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài 2: Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Giao diện hiển thị thẻ file nếu đã chọn
            if (_selectedFile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên file: $_fileName',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Thanh Progress Bar
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 5),

                      // Hiển thị % và Trạng thái
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(_progress * 100).toStringAsFixed(1)} %'),
                          Text(
                            _uploadStatus,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Nút bấm Play để bắt đầu giả lập Upload
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.green,
                            size: 30,
                          ),
                          onPressed: simulateUpload, // Gọi hàm giả lập ở đây
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Nút Chọn File ở cuối màn hình
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Choose File',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
