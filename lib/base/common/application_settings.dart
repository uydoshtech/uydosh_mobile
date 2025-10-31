abstract class IApplicationSettings {
  static String currentLang = "uz";
  void switchLanguage(String lang);
}

class ApplicationSettings implements IApplicationSettings {
  @override
  void switchLanguage(String lang) {
    // TODO
  }
}
