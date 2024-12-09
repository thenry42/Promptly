import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;

List<anthropic.Model> anthropicModels = const [
  anthropic.Model.modelId('claude-3-5-sonnet-latest'),
  anthropic.Model.modelId('claude-3-5-haiku-latest'),
  anthropic.Model.modelId('claude-3-opus-latest'),
];

String ANTHROPIC_API_KEY = '';

Future<void> getAnthropicKey() async {
  String? res;
  if (ANTHROPIC_API_KEY.isEmpty) {
    await dotenv.load();
    res = dotenv.env['ANTHROPIC_API_KEY'];
    ANTHROPIC_API_KEY = res!;
  }
}

Future<String> generateAnthropicCompletion({
  required String model,
  required String prompt,
}) async {

  var tmp = model.split(':');
  var newModel = tmp[1];
  final client = anthropic.AnthropicClient(apiKey: ANTHROPIC_API_KEY);

  try {

    final res = await client.createMessage(
      request: anthropic.CreateMessageRequest(
        model: anthropic.Model.modelId(newModel),
        maxTokens: 1024,
        messages: [
            anthropic.Message(
              role: anthropic.MessageRole.user,
              content: anthropic.MessageContent.text(prompt),
            ),
          ],
        ),
      );

    return (res.content.text);
  } catch (e) {
    if (kDebugMode) {
      print('Error generating completion: $e');
    }
    return 'FATAL ERROR';
  }
}