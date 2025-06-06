import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiProvider with ChangeNotifier {
  String? _geminiApiKey;
  String? get geminiApiKey => _geminiApiKey;

  Future<void> loadApiKey() async {
    _geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    if (_geminiApiKey == null) {
      print('GEMINI_API_KEY not found in .env file');
    }
    notifyListeners();
  }
}
