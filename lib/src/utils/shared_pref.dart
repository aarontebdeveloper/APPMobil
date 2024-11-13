import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  /// Guarda un valor en SharedPreferences bajo una clave específica.
  Future<void> save(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(value));
    } catch (e) {
      print("Error saving value: $e");
    }
  }

  /// Lee un valor de SharedPreferences utilizando la clave especificada.
  Future<T?> read<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(key);
      return jsonString != null ? json.decode(jsonString) as T : null;
    } catch (e) {
      print("Error reading value: $e");
      return null;
    }
  }
  
Future<void> saveUser(User user) async {
  SharedPref sharedPref = SharedPref();
  await sharedPref.save('user', user.toJson());
}
  /// Verifica si existe una clave en SharedPreferences.
  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  /// Elimina un valor de SharedPreferences utilizando la clave especificada.
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  /// Cierra la sesión del usuario y navega a la pantalla de inicio de sesión.
  Future<void> logout(BuildContext context) async {
    await remove('user');
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }
}
