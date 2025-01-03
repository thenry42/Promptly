import 'ChatMessage.dart';
import 'package:flutter/material.dart';

class LLM
{  
  late int    id;
  late String name;
  late String description;
  late Object model;
  late String modelName;
  late int maxTokens;
  late Icon icon;
  List<ChatMessage> messages = [];

  // TO DO :
  // generateMessageRequest()
  // generateStreamRequest()
  // fetchModelDetails()
  // getModelIcon()

}