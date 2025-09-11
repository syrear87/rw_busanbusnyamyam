import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부산버스 냠냠'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 검색 기능 구현
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '즐겨찾는 정류장',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('즐겨찾는 정류장 목록이 여기에 표시됩니다.'),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '최근 조회',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('최근 조회한 정류장이 여기에 표시됩니다.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
