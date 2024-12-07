import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:promptly_app/widgets/settings_widget.dart';

List<anthropic.Model> anthropicModels = [];

Future<List<anthropic.Model>> getAnthropicModels() async {

  if (anthropicModels.isEmpty) {
    try {

      if (claudeKey.isEmpty)
      {
        // Retrieve API KEY from .env
        claudeKey = (await getAnthropicKey())!;
      }

      anthropicModels.add(anthropic.Model.modelId('claude-3-5-sonnet-latest'));
      anthropicModels.add(anthropic.Model.modelId('claude-3-5-haiku-latest'));
      anthropicModels.add(anthropic.Model.modelId('claude-3-opus-latest'));

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Anthropic models: $e');
      }
    }
  }
  return anthropicModels;
}

Future<String?> getAnthropicKey() async
{
  String? res;
  
  if (claudeKey.isEmpty)
  {
    await dotenv.load();
    res = dotenv.env['ANTHROPIC_API_KEY'];
    claudeKey = res!;
    return res;
  }
  return null;
}