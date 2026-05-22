import 'package:flutter/material.dart';
import 'route_finder_screen.dart';

void main() {
  runApp(const RouteFinderApp());
}

class RouteFinderApp extends StatelessWidget {
  const RouteFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Route Finder', home: RouteFinderScreen());
  }
}
