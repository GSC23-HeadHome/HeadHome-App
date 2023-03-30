extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String parseHTML(String htmlText) {
  print(htmlText);
  RegExp div = RegExp(r"<div\b[^>]*>", multiLine: true, caseSensitive: true);
  htmlText = htmlText.replaceAll(div, '. ');
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
  return htmlText.replaceAll(exp, '');
}
