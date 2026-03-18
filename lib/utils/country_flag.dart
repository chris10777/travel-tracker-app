String countryCodeToEmoji(String countryCode) {
  final code = countryCode.trim().toUpperCase();

  if (code.length != 2) return '🏳️';

  final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;

  return String.fromCharCode(firstLetter) +
      String.fromCharCode(secondLetter);
}

