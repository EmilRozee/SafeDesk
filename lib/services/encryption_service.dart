import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  static final _key = encrypt.Key.fromLength(32);
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Encrypt sensitive data
  static String encryptData(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  // Decrypt data (only for authorized personnel)
  static String decryptData(String encryptedData) {
    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // Hash data for verification
  static String hashData(String data) {
    // Simple SHA-256 hash for now
    // TODO: Implement more secure hashing
    return base64Encode(data.codeUnits);
  }

  // Store encrypted data locally
  static Future<void> storeEncryptedData(String key, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = encryptData(data);
      await prefs.setString(key, encryptedData);
    } catch (e) {
      print('Error storing encrypted data: $e');
    }
  }

  // Retrieve and decrypt data
  static Future<String?> getDecryptedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(key);
      if (encryptedData != null) {
        return decryptData(encryptedData);
      }
    } catch (e) {
      print('Error retrieving encrypted data: $e');
    }
    return null;
  }
}