import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class BabelLibrary {
  static const int totalPages = 400;
  static const int wordsPerPage = 300;
  static const int booksPerShelf = 12;
  static const int shelvesPerWall = 9;

  List<String> customVocabulary;

  BabelLibrary(this.customVocabulary);

  String generateBook(String hash) {
    List<String> pages = generatePages(hash);
    return pages.join('\n\n');
  }

  List<String> generatePages(String hash) {
    List<String> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(generatePage(hash, i));
    }
    return pages;
  }

  String generatePage(String hash, int pageNumber) {
    String pageContent = generatePageContent(hash, pageNumber);
    return 'Page $pageNumber:\n$pageContent';
  }

  String generatePageContent(String hash, int pageNumber) {
    String seed = hash + pageNumber.toString();
    List<String> randomWords = generateRandomWords(seed);
    return randomWords.join(' ');
  }

  List<String> generateRandomWords(String seed) {
    Random random = Random(hashString(seed));
    List<String> randomWords = [];

    for (int i = 0; i < wordsPerPage; i++) {
      int randomIndex = random.nextInt(customVocabulary.length);
      randomWords.add(customVocabulary[randomIndex]);
    }

    return randomWords;
  }

  int hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);
    return int.parse(digest.toString().substring(0, 8), radix: 16);
  }
}

void main() {
  List<String> customVocabulary = [
    'word1',
    'word2',
    'word3', /* add more words */
  ];

  BabelLibrary babelLibrary = BabelLibrary(customVocabulary);

  String hash = 'your_hash_here'; // Replace with your actual hash
  String bookContent = babelLibrary.generateBook(hash);

  print(bookContent);
}
