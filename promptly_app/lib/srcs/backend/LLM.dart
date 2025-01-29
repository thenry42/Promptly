import 'ChatMessage.dart';
import 'Anthropic.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'Ollama.dart';
import 'OpenAI.dart';
import 'package:flutter/material.dart';

class LLM
{  
  late int    id;
  late String name;
  late String description;
  late Object model;
  late String modelName;
  late Icon icon;
  List<ChatMessage> messages = [];

  anthropicsdk.Model? anthropicModel;
  openai.OpenAIModelModel? openaiModel;
  ollama.Model? ollamaModel;


  // TO DO :
  // generateMessageRequest()
  // generateStreamRequest()
  // fetchModelDetails()
  // getModelIcon()

}