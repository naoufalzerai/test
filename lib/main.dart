import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'package:fast_csv/fast_csv_ex.dart' as fast_csv_ex;

void main() async {
  final path = 'darija-data';

  final dr = Directory(path);
  final files = await dr.list().toList();

  Set<String> tokens = Set();

  for (int i = 0; i < files.length; i++) {
    var e = files[i];
    tokens.addAll(await ParseFile(e.path));
  }
  var listToken = tokens.toList();
  Random rnd = new Random(150);

  BabelLibrary babelLibrary = BabelLibrary(listToken);
  String hash = 'a'; // Replace with your actual hash
  String bookContent = babelLibrary.generateBook(hash);

  print(bookContent);
  print(babelLibrary.searchForSentence("bikhirdertha 3reDt"));
}

Future<Set<String>> ParseFile(file) async {
  Set<String> words = Set();
  var input = await File(file).readAsString();
  List<List<String>> values = await fast_csv_ex.parse(input);
  // get eng col
  List titles = values[0];
  int indexEn = -1;
  for (int i = 0; i < titles.length; i++) {
    if (titles[i] == "eng" || titles[i] == "english") indexEn = i;
  }

  for (int i = 0; i < values.length; i++) {
    if (indexEn != -1) {
      values[i].remove(values[i][indexEn]);
    }
    values[i] = values[i]
        .map((e) => e.replaceAll(new RegExp(r'[^\w\s]+'), ''))
        .toList();
    var listWords = values[i].map((e) => e.split(' ')).toList();
    if (listWords.isNotEmpty) words.addAll(listWords[0]);
  }

  return words;
}

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

  int searchForSentence(String sentence) {
    for (int shelf = 1; shelf <= shelvesPerWall; shelf++) {
      for (int book = 1; book <= booksPerShelf; book++) {
        int hash = searchInBook(sentence, shelf, book);
        if (hash != -1) {
          return hash;
        }
      }
    }
    return -1; // Return -1 if the sentence is not found in any book
  }

  int searchInBook(String sentence, int shelf, int book) {
    for (int page = 1; page <= totalPages; page++) {
      String pageContent = generatePageContent(sentence, page);
      if (pageContent.contains(sentence)) {
        return hashString('$shelf$book$page');
      }
    }
    return -1; // Return -1 if the sentence is not found in the current book
  }
}
