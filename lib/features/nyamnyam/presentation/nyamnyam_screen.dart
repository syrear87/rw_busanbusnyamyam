import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nyam_map_screen.dart';

class NyamNyamScreen extends ConsumerWidget {
  const NyamNyamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0DFCC),
      body: NyamMapScreen(),
    );
  }
}

