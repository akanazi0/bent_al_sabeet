/// Utility class for handling number conversion between Arabic and English numerals.
class NumberUtils {
  /// Maps Arabic numerals (Eastern) to English numerals (Western).
  static const Map<String, String> _arabicToEnglish = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  /// Converts any Arabic numerals in the string to English numerals.
  /// Useful for parsing numbers from keyboard input that might contain Arabic numerals.
  static String convertArabicToEnglish(String input) {
    String result = input;
    _arabicToEnglish.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });
    return result;
  }

  /// Tries to parse an integer from a string that might contain either Arabic or English numerals.
  static int? tryParseInt(String input) {
    final cleaned = convertArabicToEnglish(input.trim());
    return int.tryParse(cleaned);
  }
}
