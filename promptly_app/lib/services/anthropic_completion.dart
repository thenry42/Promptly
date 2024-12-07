import 'package:flutter/foundation.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:promptly_app/widgets/settings_widget.dart';

Future<String> generateAnthropicCompletion({
  required String model,
  required String prompt,
}) async {

  var tmp = model.split(':');
  var newModel = '${tmp[1]}';
  final client = anthropic.AnthropicClient(apiKey: claudeKey);

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
    return '';
  }
}