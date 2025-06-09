import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ✅ 날짜별 할 일 목록을 저장하는 Map
  Map<DateTime, List<TodoItemData>> todoMap = {};

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // ✅ 현재 선택된 날짜의 할 일 목록 반환
  List<TodoItemData> get _selectedTodos {
    final key = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return todoMap[key] ?? [];
  }

  // ✅ 현재 날짜의 완료 비율
  double get completionRate {
    if (_selectedTodos.isEmpty) return 0.0;
    final completed = _selectedTodos.where((t) => t.checked).length;
    return completed / _selectedTodos.length;
  }

  void _showAddTodoDialog() {
    String newTitle = '';
    String newDescription = '';
    String newCategory = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('새로운 리스트 생성'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('제목'),
              TextField(
                decoration: const InputDecoration(hintText: '제목을 작성해주세요.'),
                onChanged: (value) => newTitle = value,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('날짜'),
                        Text("${_selectedDate.toLocal()}".split(' ')[0]),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Category'),
                      onChanged: (value) => newCategory = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('설명'),
              TextField(
                decoration: const InputDecoration(hintText: '설명을 작성해주세요.'),
                onChanged: (value) => newDescription = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newTitle.isNotEmpty) {
                setState(() {
                  final dateKey = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                  );
                  final newTodo = TodoItemData(
                    title: newTitle,
                    subtitle: newDescription,
                    checked: false,
                  );
                  if (!todoMap.containsKey(dateKey)) {
                    todoMap[dateKey] = [];
                  }
                  todoMap[dateKey]!.add(newTodo);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 사용자 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text('사용자명', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            // 달력
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.week,
              headerVisible: false,
            ),
            const SizedBox(height: 20),
            // 퍼센트 인디케이터
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 12.0,
              percent: completionRate,
              center: Text(
                "${(completionRate * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: Colors.yellow.shade600,
              backgroundColor: Colors.yellow.shade100,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 16),
            // 할 일 목록
            Expanded(
              child: ListView.builder(
                itemCount: _selectedTodos.length,
                itemBuilder: (context, index) {
                  final todo = _selectedTodos[index];
                  return CheckboxListTile(
                    title: Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      todo.subtitle,
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: todo.checked,
                    onChanged: (value) {
                      setState(() {
                        _selectedTodos[index] = TodoItemData(
                          title: todo.title,
                          subtitle: todo.subtitle,
                          checked: value ?? false,
                        );
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue),
      ),
      bottomNavigationBar: const TestNaV(),
    );
  }
}

// 하단 네비게이션
class TestNaV extends StatelessWidget {
  const TestNaV({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.groups), label: '그룹'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: '채팅'),
        BottomNavigationBarItem(
          icon: CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/user.png'),
          ),
          label: 'MY',
        ),
      ],
    );
  }
}

// 할 일 데이터 클래스
class TodoItemData {
  final String title;
  final String subtitle;
  final bool checked;

  TodoItemData({
    required this.title,
    required this.subtitle,
    required this.checked,
  });
}
