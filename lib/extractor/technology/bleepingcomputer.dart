import 'package:html/dom.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class BleepingComputer extends Publisher {
  @override
  String get homePage => "https://www.bleepingcomputer.com";

  @override
  String get name => "BleepingComputer";

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse(newsArticle.url));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      Element? articleElement = document.querySelector(".articleBody");
      String? thumbnail = "";
      String? content = articleElement?.innerHtml;
      return newsArticle.fill(content: content, thumbnail: thumbnail,);
    }
    return null;
  }

  @override
  bool get hasSearchSupport => false;

  @override
  Future<Map<String, String>> get categories async => {};

  @override
  Future<Set<NewsArticle?>> categoryArticles({String category = "", int page = 1}) async {
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse(page!=1?"$homePage/news/page/$page":"$homePage/news/"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements =
          document.querySelectorAll("#bc-home-news-main-wrap > li");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h4")?.text;
        String? excerpt = articleElement.querySelector("p")?.text;
        String? author = articleElement.querySelector(".author")?.text;
        String? url = articleElement.querySelector("h4 a")?.attributes["href"];
        String? thumbnail = articleElement
                .querySelector(".bc_latest_news_img img")
                ?.attributes["src"];
        String? content = "";
        String? date = articleElement.querySelector(".bc_news_date")?.text;
        String? time = articleElement.querySelector(".bc_news_time")?.text;
        String parsedTime = convertToIso8601("$date $time", "MMMM dd, yyyy hh:mm a");

        articles.add(NewsArticle(
          this,
          title ?? "",
          content,
          excerpt ?? "",
          author ?? "",
          url ?? "",
          thumbnail ?? "",
          parseDateString(parsedTime),
        ));
      }
    }
    return articles;
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles({required String searchQuery, int page = 1}) async{
    return {};
  }
}
