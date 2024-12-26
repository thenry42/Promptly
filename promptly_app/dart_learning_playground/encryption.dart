import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

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

// Function to persist data: salt, iv, and encrypted text
String persistEncryptedData(Uint8List key, String userInput) {
  final salt = generateSalt(32);
  final keyDerived = derivedKey(userInput, salt, 100000, 32);
  final ivBytes = generateRandomIV(16);

  final encryptedText = aesEncryption(keyDerived, userInput, ivBytes);

  // Combine salt, iv, and encrypted data into a single JSON-like structure
  final Map<String, String> encryptedData = {
    'salt': salt,
    'iv': base64.encode(ivBytes), // Convert IV to base64 for easy storage
    'ciphertext': encryptedText,
  };

  return json.encode(encryptedData); // Serialize data as a JSON string
}

// Function to retrieve and decrypt data
String retrieveEncryptedData(String jsonData, String userInput) {
  final Map<String, dynamic> parsedData = json.decode(jsonData);

  final String salt = parsedData['salt'];
  final String ivBase64 = parsedData['iv'];
  final String ciphertext = parsedData['ciphertext'];

  final ivBytes = base64.decode(ivBase64);
  final keyDerived = derivedKey(userInput, salt, 100000, 32);

  // Decrypt the data using the derived key and IV
  return aesDecryption(keyDerived, ciphertext, ivBytes);
}

int main()
{
  // WORKS AS EXPECTED

  const String userInput = "One big ass password";
  
  // Store encrypted data with salt, IV, and ciphertext
  final encryptedData = persistEncryptedData(Uint8List(32), userInput); 
  print("Encrypted Data (Persisted): $encryptedData");

  // Retrieve and decrypt the stored data
  final decryptedText = retrieveEncryptedData(encryptedData, userInput);
  print("Decrypted text: $decryptedText");
  
  return 0;
}
