// ignore: file_names
import 'package:daham/Data/todo.dart';
import 'package:daham/Pages/test/assistant_chat.dart';
import 'package:daham/Provider/export.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final todoData = Provider.of<TodoState>(context);
    final userState = Provider.of<UserState>(context);
    final todoList = todoData.todoList;
    double completionRate =
        todoList!.isEmpty
            ? 0.0
            : todoList.where((todo) => todo.complete).length / todoList.length;

    return SafeArea(
      child: Column(
        children: [
          // 상단 사용자 정보
          Padding(
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
          ),
          SizedBox(height: 20),
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

          SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 60.0,
            lineWidth: 12.0,
            percent: completionRate,
            center: SizedBox(
              width: 120,
              height: 120,
              child: Lottie.asset(
                completionRate == 1
                    ? 'assets/lottie/star_face.json'
                    : 'assets/lottie/working.json',
              ),
            ),
            progressColor: Colors.yellow.shade600,
            backgroundColor: Colors.yellow.shade100,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          // 할 일 목록
          SizedBox(height: 30),
          if (todoList != null)
            Expanded(
              child: TodoSector(
                todoList: todoList,
                todoData: todoData,
                userState: userState,
              ),
            ),
        ],
      ),
    );
  }
}

class TodoSector extends StatelessWidget {
  const TodoSector({
    super.key,
    required this.todoList,
    required this.todoData,
    required this.userState,
  });

  final List<PersonalTodoItem> todoList;
  final TodoState todoData;
  final UserState userState;

  @override
  Widget build(BuildContext context) {
    return GroupedListView<dynamic, String>(
      elements: todoList,
      groupBy: (todo) => (todo.complete as bool) ? '완료' : '진행중',
      groupSeparatorBuilder:
          (String group) => Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                group,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      itemBuilder:
          (context, todo) => Card(
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: todo.complete,
              title: Text(todo.task),
              onChanged: (value) {
                todoData.changeCompleteTodo(userState.userData['uid'], todo.id);
              },
            ),
          ),
      order: GroupedListOrder.DESC,
    );
  }
}

class UserTodoFAB extends StatefulWidget {
  const UserTodoFAB({super.key});

  @override
  State<UserTodoFAB> createState() => _UserTodoFABState();
}

class _UserTodoFABState extends State<UserTodoFAB> {
  bool _canelFAB = false;

  @override
  Widget build(BuildContext context) {
    final geminiApiKey =
        Provider.of<GeminiProvider>(listen: false, context).geminiApiKey;

    return _canelFAB != true
        ? SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          activeBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
          children: [
            SpeedDialChild(
              child: Icon(Icons.edit),
              label: '직접 추가',
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text('TO DO'),
                        content: TextFormField(
                          decoration: InputDecoration(label: Text('Title')),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('닫기'),
                          ),
                        ],
                      ),
                );
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.auto_awesome),
              label: 'AI assitant',
              onTap: () async {
                if (geminiApiKey == null) {
                  assert(false, "geminiApiKey is NULL");
                } else {
                  setState(() {
                    _canelFAB = true;
                  });
                  showBottomSheet(
                    context: context,
                    builder: (_) => SizedBox(height: 80, child: InputChat()),
                  ).closed.then((_) {
                    setState(() {
                      _canelFAB = false;
                    });
                  });
                }
              },
            ),
          ],
        )
        : FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              _canelFAB = false;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          },
          child: const Icon(Icons.close),
        );
  }
}
