import 'package:daham/Data/todo.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fluttermoji/fluttermoji.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<TodoItemData> todos = [
    TodoItemData(title: "알고리즘", subtitle: "HW1_2 제출하기", checked: true),
    TodoItemData(title: "OS 그룹스터디", subtitle: "상상랩8 / 19:00-", checked: false),
    TodoItemData(title: "새새밥고", subtitle: "학관 14:00-", checked: false),
  ];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _selectedDate = DateTime.now();
  String? _category;

  double get completionRate {
    if (todos.isEmpty) return 0.0;
    final completed = todos.where((t) => t.checked).length;
    return completed / todos.length;
  }

  void _showAddTodoDialog() {
    String newTitle = '';
    String newDescription = '';
    String newCategory = '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          onChanged: (value) => newCategory = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('설명'),
                  TextField(
                    decoration: const InputDecoration(hintText: '제목을 작성해주세요.'),
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
                      todos.add(
                        TodoItemData(
                          title: newTitle,
                          subtitle: newDescription,
                          checked: false,
                        ),
                      );
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
    return SafeArea(
      child: Column(
        children: [
          // 상단 사용자 정보
          Consumer<UserState>(
            builder: (context, userState, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    FluttermojiCircleAvatar(radius: 30),
                    const SizedBox(width: 12),
                    Text(
                      userState.userData['userName'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          // 달력
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
          ),
          // 퍼센트 인디케이터
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 12.0,
            percent: completionRate,
            center: Text(
              "${(completionRate * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            progressColor: Colors.yellow.shade600,
            backgroundColor: Colors.yellow.shade100,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          // 할 일 목록
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
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
                      todos[index] = TodoItemData(
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
    );
  }
}
