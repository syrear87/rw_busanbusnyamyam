import 'package:flutter/material.dart';

class NyamNyamScreen extends StatefulWidget {
  const NyamNyamScreen({super.key});

  @override
  State<NyamNyamScreen> createState() => _NyamNyamScreenState();
}

class _NyamNyamScreenState extends State<NyamNyamScreen> {
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('냠냠')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('🍚 맛집'),
                    selected: _selectedCategory == 0,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = 0);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('☕ 카페'),
                    selected: _selectedCategory == 1,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = 1);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  _selectedCategory == 0
                      ? '맛집 정보가 여기에 표시됩니다.'
                      : '카페 정보가 여기에 표시됩니다.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
