import 'dart:convert';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  final String apiUrl ='https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill';
  final String apiKey = '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'; // Replace with your API key

Future<String> sendMessage(String message) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({'inputs': message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Handle error messages returned by the API
      if (data is Map && data.containsKey('error')) {
        return 'Error: ${data['error']}';
      }

      // Parse the response if it's a List
      if (data is List && data.isNotEmpty && data[0].containsKey('generated_text')) {
        return data[0]['generated_text'];
      } else {
        return 'Unexpected response format: $data';
      }
    } else {
      return 'Error: ${response.body}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}

}
