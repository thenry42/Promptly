import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Encryption {
  static const int _keyLength = 32;
  static const int _iterations = 100000;
  static const int _ivLength = 16;
  
  // ignore: unused_field
  late Uint8List _key;
  
  // Initialize with a key if provided
  Encryption([Uint8List? key]) {
    _key = key ?? Uint8List(_keyLength);
  }

  String generateSalt(int len) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(len, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  Uint8List derivedKey(String input, String salt, int iterations, int keyLength) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(utf8.encode(salt), iterations, keyLength);
    pbkdf2.init(params);
    return pbkdf2.process(utf8.encode(input));
  }

  Uint8List generateRandomIV(int len) {
    final random = Random.secure();
    final ivBytes = List<int>.generate(len, (i) => random.nextInt(256));
    return Uint8List.fromList(ivBytes);
  }

  String aesEncryption(Uint8List key, String plainText, Uint8List ivBytes) {
    final aesKey = encrypt.Key(key);
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String aesDecryption(Uint8List key, String encryptedText, Uint8List ivBytes) {
    final aesKey = encrypt.Key(key);
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(aesKey, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted;
  }

  String persistEncryptedData(String userInput) {
    final salt = generateSalt(_keyLength);
    final keyDerived = derivedKey(userInput, salt, _iterations, _keyLength);
    final ivBytes = generateRandomIV(_ivLength);
    final encryptedText = aesEncryption(keyDerived, userInput, ivBytes);

    final Map<String, String> encryptedData = {
      'salt': salt,
      'iv': base64.encode(ivBytes),
      'ciphertext': encryptedText,
    };
    return json.encode(encryptedData);
  }

  String retrieveEncryptedData(String jsonData, String userInput) {
    final Map<String, dynamic> parsedData = json.decode(jsonData);
    final String salt = parsedData['salt'];
    final String ivBase64 = parsedData['iv'];
    final String ciphertext = parsedData['ciphertext'];
    
    final ivBytes = base64.decode(ivBase64);
    final keyDerived = derivedKey(userInput, salt, _iterations, _keyLength);
    return aesDecryption(keyDerived, ciphertext, ivBytes);
  }
}

/*
void main() {
  final encryption = Encryption();
  const userInput = "One big ass password";
  
  final encryptedData = encryption.persistEncryptedData(userInput);
  final decryptedText = encryption.retrieveEncryptedData(encryptedData, userInput);
  
  print("Encrypted: $encryptedData");
  print("Decrypted: $decryptedText");
}
*/
