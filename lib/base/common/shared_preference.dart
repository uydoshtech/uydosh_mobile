import "package:encrypt_shared_preferences/provider.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract class ISharedPreference {
  static SharedPreferences? get sharedPreferences => _sharedPreferences;
  static EncryptedSharedPreferences? get secureStorage => _secureStorage;
  static SharedPreferences? _sharedPreferences;
  static EncryptedSharedPreferences? _secureStorage;

  static Future<void> setupSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _secureStorage = EncryptedSharedPreferences.getInstance();
  }

  Future<dynamic> getValue(String key);

  Future<bool> setValueString(String key, dynamic value);
}

class SharedPreference implements ISharedPreference {
  @override
  Future<dynamic> getValue(String key) async {
    return ISharedPreference.sharedPreferences?.get(key);
  }

  @override
  Future<bool> setValueString(String key, value) {
    return ISharedPreference.sharedPreferences!.setString(key, value);
  }
}
