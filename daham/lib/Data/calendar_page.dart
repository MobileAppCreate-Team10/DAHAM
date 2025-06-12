import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daham/Data/todo.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<PersonalTodoItem>> _todoEvents = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('todos')
        .get();

    final Map<DateTime, List<PersonalTodoItem>> events = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final map = data['details'] ?? data;

      try {
        final todo = PersonalTodoItem.fromMap(map);
        final date = DateTime.parse(todo.dueDate);
        final key = DateTime(date.year, date.month, date.day);

        if (!events.containsKey(key)) {
          events[key] = [];
        }
        events[key]!.add(todo);
      } catch (e) {
        debugPrint('❌ 날짜 파싱 오류: ${e.toString()}');
      }
    }

    if (mounted) {
      setState(() {
        _todoEvents = events;
      });
    }
  }

  List<PersonalTodoItem> _getTodosForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _todoEvents[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedTodos = _getTodosForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 캘린더'),
        backgroundColor: Colors.deepPurple[50],
      ),
      body: Column(
        children: [
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
            eventLoader: _getTodosForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedTodos.isEmpty
                ? const Center(child: Text('할 일이 없습니다.'))
                : ListView.builder(
                    itemCount: selectedTodos.length,
                    itemBuilder: (context, index) {
                      final todo = selectedTodos[index];
                      return ListTile(
                        title: Text(todo.task),
                        subtitle: Text('우선순위: ${todo.priority}'),
                        trailing: Icon(
                          todo.complete ? Icons.check_circle : Icons.circle_outlined,
                          color: todo.complete ? Colors.green : Colors.grey,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
