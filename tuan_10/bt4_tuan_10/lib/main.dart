import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const BaiTap4App());
}

class BaiTap4App extends StatelessWidget {
  const BaiTap4App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Bài tập 4 - Chọn Điểm',
      home: MapSelectionScreen(),
    );
  }
}

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  final TextEditingController _destinationController = TextEditingController();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  // Khởi tạo lấy vị trí ban đầu để đưa camera về chỗ người dùng
  Future<void> _initCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
  }

  // Yêu cầu 1: Cho phép chọn điểm trên bản đồ bằng cách nhấn
  void _onMapTapped(LatLng position) {
    setState(() {
      // Cập nhật text ô nhập liệu
      _destinationController.text =
          "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";

      // Đánh dấu marker mới
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selected_destination"),
          position: position,
          infoWindow: const InfoWindow(title: "Điểm đích đã chọn"),
        ),
      );
    });
  }

  // Yêu cầu 2: Lấy vị trí hiện tại làm điểm đích
  Future<void> _setDestinationToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng bật GPS!')));
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _destinationController.text =
          "${currentLatLng.latitude.toStringAsFixed(5)}, ${currentLatLng.longitude.toStringAsFixed(5)}";

      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("current_destination"),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: "Đích đến (Vị trí hiện tại)"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ), // Đổi màu xanh cho dễ nhận diện
        ),
      );
    });

    // Di chuyển camera về vị trí đó
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài tập 4: Chọn điểm đích')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _destinationController,
              readOnly: true, // Chỉ cho hiển thị, chống nhập tay
              decoration: InputDecoration(
                labelText: 'Tọa độ điểm đích',
                border: const OutlineInputBorder(),
                // Nút bấm lấy vị trí hiện tại ngay trong thanh TextField
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.blue),
                  onPressed: _setDestinationToCurrentLocation,
                  tooltip: 'Dùng vị trí hiện tại làm đích',
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled:
                  false, // Ẩn nút mặc định để dùng nút custom ở trên
              onTap: _onMapTapped, // Kích hoạt sự kiện chạm
            ),
          ),
        ],
      ),
    );
  }
}
