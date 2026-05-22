import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'database_helper.dart';

void main() {
  runApp(const BtvnApp());
}

class BtvnApp extends StatelessWidget {
  const BtvnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Danh sách Yêu thích',
      home: MapFavoriteScreen(),
    );
  }
}

class MapFavoriteScreen extends StatefulWidget {
  const MapFavoriteScreen({super.key});

  @override
  _MapFavoriteScreenState createState() => _MapFavoriteScreenState();
}

class _MapFavoriteScreenState extends State<MapFavoriteScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.7769, 106.7009),
    zoom: 12,
  );

  // Xử lý khi nhấn lên bản đồ
  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selected"),
          position: position,
          infoWindow: const InfoWindow(title: "Điểm đang chọn"),
        ),
      );
    });
  }

  // Lưu tọa độ vào SQLite
  Future<void> _saveToFavorites() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chạm vào bản đồ để chọn 1 điểm trước!'),
        ),
      );
      return;
    }

    await DatabaseHelper.instance.saveFavorite(
      "Điểm yêu thích mới",
      _selectedLocation!.latitude.toStringAsFixed(5),
      _selectedLocation!.longitude.toStringAsFixed(5),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thành công vào SQLite!')),
    );
  }

  // Chuyển sang màn hình xem danh sách
  void _openFavoritesList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoriteListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ Yêu thích'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _openFavoritesList,
            tooltip: 'Xem danh sách đã lưu',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _onMapTapped,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _saveToFavorites,
              icon: const Icon(Icons.save),
              label: const Text('LƯU ĐIỂM NÀY VÀO YÊU THÍCH'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH HIỂN THỊ DANH SÁCH TỪ SQLITE
// ==========================================
class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  _FavoriteListScreenState createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final data = await DatabaseHelper.instance.getFavorites();
    setState(() {
      _favorites = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách đã lưu')),
      body: _favorites.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu nào.'))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final item = _favorites[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(item['name']),
                    subtitle: Text(
                      "Lat: ${item['destination_lat']} | Lng: ${item['destination_lng']}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
