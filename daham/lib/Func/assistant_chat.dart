import 'package:daham/Func/gemini_assistant.dart';
import 'package:daham/Pages/MyTodo/todo_dialog.dart';
import 'package:flutter/material.dart';

class InputChat extends StatefulWidget {
  const InputChat({super.key});

  @override
  State<InputChat> createState() => _InputChatState();
}

class _InputChatState extends State<InputChat> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false; // 로딩 상태 변수

  void _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final gemini = GeminiTodoAssistant();
      final todoJson = await gemini.parseTaskFromChat(text);
      // final todoJson = {
      //   "task": "test",
      //   "details": {"time": '2시'},
      // };
      _controller.clear();
      showTodoDialog(context: context, json: todoJson);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _focusNode.unfocus();
    }
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요',
                border: InputBorder.none,
              ),
              onSubmitted: _handleSend,
              enabled: !_isLoading,
            ),
          ),
          _isLoading
              ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSend(_controller.text),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildInputBar();
  }
}

class DialogTODO extends StatelessWidget {
  const DialogTODO({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
