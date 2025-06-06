import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가

class GeminiTodoAssistant {
  late final GenerativeModel _model;

  GeminiTodoAssistant() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("Gemini API Key not found. Check your .env file.");
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    ); // 모델 선택
  }

  Future<Map<String, dynamic>?> parseTaskFromChat(String userMessage) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 동적으로 현재 날짜를 프롬프트에 주입
    final prompt = """
    You are a helpful and efficient assistant for a TODO list application.
    Your primary task is to extract a task description, and optional due date, priority, and details from user messages.

    **Rules:**
    1.  **Response Format:** Always respond ONLY with a JSON object.
    2.  **Task Description:** Extract the main task the user wants to add.
    3.  **Due Date:**
        * If a date/time is mentioned (e.g., "tomorrow", "next Monday", "2025-12-31", "오전 9시"), convert it to 'YYYY-MM-DD' format.
        * **Assume today's date is $today.** // <-- 여기에서 현재 날짜가 주입됩니다.
        * If no due date is specified, the value should be `null`.
    4.  **Priority:**
        * If the user explicitly states high priority (e.g., "important", "urgent", "must do", "중요해", "꼭 해야 해"), set priority to "High".
        * If the user implies low urgency (e.g., "나중에", "언제든"), set priority to "Low".
        * Otherwise, set priority to "Medium".
    5.  **Details:**  
        - Extract any additional information such as subject, location, participants, prerequisite tasks, etc.  
        - The "details" field must be a JSON object with key-value pairs.  
        - If there is no extra information, use an empty object: {}

    **Output Schema:**
    ```json
    {
      "task": "string",
      "details": {
        // key-value pairs, e.g. "subject", "location", "participants", "prerequisite"
      },
      "due_date": "YYYY-MM-DD or null",
      "priority": "High" | "Medium" | "Low"
    }
    ```

    **Examples:**

    User: "내일 아침 9시까지 팀 회의 준비"
    Output: ```json
    {
      "task": "팀 회의 준비",
      "due_date": "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 1)))}",
      "priority": "High"
    }
    ```

    User: "집에 가서 장보기"
    Output: ```json
    {
      "task": "장보기",
      "due_date": null,
      "priority": "Medium"
    }
    ```

    User: "다음주 월요일까지 보고서 제출해야 해. 이건 중요해."
    Output: ```json
    {
      "task": "보고서 제출",
      "due_date": "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: (8 - DateTime.now().weekday) % 7 + 1)))}", // 다음 월요일 계산
      "priority": "High"
    }
    ```

    User: "그냥 운동해야지"
    Output: ```json
    {
      "task": "운동하기",
      "due_date": null,
      "priority": "Medium"
    }
    ```

    User: "나중에 시간될때 책 읽기"
    Output: ```json
    {
      "task": "책 읽기",
      "due_date": null,
      "priority": "Low"
    }
    ```
    User: "$userMessage"
    Output:

    **Examples:**

    User: "운영체제 과제 제출하고 나서 팀플 회의, 장소는 상상랩8"
    Output: ```json
    {
      "task": "팀플 회의",
      "details": {
        "prerequisite": "운영체제 과제 제출",
        "location": "상상랩8"
      },
      "due_date": null,
      "priority": "Medium"
    }
    ```
    """;

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final rawText = response.text;

      // JSON 파싱
      if (rawText != null) {
        // 백틱(```json ... ```)으로 묶인 JSON 문자열만 추출
        final jsonMatch = RegExp(
          r"```json\s*([\s\S]*?)\s*```",
        ).firstMatch(rawText);
        if (jsonMatch != null && jsonMatch.groupCount >= 1) {
          String jsonString = jsonMatch.group(1)!;
          // 불필요한 줄바꿈 제거 (모델에 따라 발생할 수 있음)
          jsonString = jsonString.replaceAll('\n', '');

          final parsedData = json.decode(jsonString) as Map<String, dynamic>;
          return parsedData;
        } else {
          print("JSON block not found in Gemini response: $rawText");
          return null;
        }
      }
    } catch (e) {
      print("Error calling Gemini API: $e");
    }
    return null;
  }
}
