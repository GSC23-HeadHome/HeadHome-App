/// Adds various methods to the [String] class.
extension StringCasingExtension on String {
  /// Converts the first character of a string to uppercase and the remaining characters to lowercase.
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  /// Converts the first character of each word in the string to uppercase,
  /// and the rest of the characters are in lowercase.
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

/// Takes in a [htmlText] string and returns a parsed string without html tags.
String parseHTML(String htmlText) {
  RegExp div = RegExp(r"<div\b[^>]*>", multiLine: true, caseSensitive: true);
  htmlText = htmlText.replaceAll(div, '. ');
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '');
}
