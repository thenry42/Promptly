// metadata.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'Encryption.dart';
import 'Chat.dart';

class MetaData {
  static const String _anthropicKeyPref = 'anthropic_api_key';
  static const String _openAIKeyPref = 'openai_api_key';
  static const String _masterKey = 'hello'; // Replace with your app's master key
  
  String? anthropicKey;
  String? openAIKey;
  List<Chat> chatList = [];
  final Encryption _encryption = Encryption();

  // Singleton pattern
  static final MetaData _instance = MetaData._internal();
  
  factory MetaData() {
    return _instance;
  }
  
  MetaData._internal();

  // Get keys from storage
  static Future<void> getKeysFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final instance = MetaData();
    
    try {
      // Retrieve and decrypt Anthropic key
      final encryptedAnthropic = prefs.getString(_anthropicKeyPref);
      if (encryptedAnthropic != null) {
        instance.anthropicKey = instance._encryption.retrieveEncryptedData(
          encryptedAnthropic,
          _masterKey
        );
      }
      
      // Retrieve and decrypt OpenAI key
      final encryptedOpenAI = prefs.getString(_openAIKeyPref);
      if (encryptedOpenAI != null) {
        instance.openAIKey = instance._encryption.retrieveEncryptedData(
          encryptedOpenAI,
          _masterKey
        );
      }
    } catch (e) {
      print('Error decrypting keys: $e');
      // Handle decryption errors appropriately
      await deleteKeys(anthropic: true, openAI: true);
    }
  }

  // Save keys to storage
  static Future<void> saveKeys({String? anthropicKey, String? openAIKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final instance = MetaData();
    
    try {
      if (anthropicKey != null) {
        final encryptedAnthropic = instance._encryption.persistEncryptedData(anthropicKey);
        await prefs.setString(_anthropicKeyPref, encryptedAnthropic);
        instance.anthropicKey = anthropicKey;
      }
      
      if (openAIKey != null) {
        final encryptedOpenAI = instance._encryption.persistEncryptedData(openAIKey);
        await prefs.setString(_openAIKeyPref, encryptedOpenAI);
        instance.openAIKey = openAIKey;
      }
    } catch (e) {
      print('Error encrypting keys: $e');
      // Handle encryption errors appropriately
      rethrow;
    }
  }

  // Delete keys from storage
  static Future<void> deleteKeys({bool anthropic = false, bool openAI = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final instance = MetaData();
    
    if (anthropic) {
      await prefs.remove(_anthropicKeyPref);
      instance.anthropicKey = null;
    }
    
    if (openAI) {
      await prefs.remove(_openAIKeyPref);
      instance.openAIKey = null;
    }
  }
}
