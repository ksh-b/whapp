import 'package:html/dom.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class Engadget extends Publisher {
  @override
  String get homePage => "https://www.engadget.com";

  @override
  String get name => "Engadget";

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      Element? articleElement = document.querySelector(".caas-body");
      String? thumbnail = articleElement
          ?.querySelector("p img")
          ?.attributes["src"];
      String? content = articleElement?.innerHtml;
      return newsArticle.fill(content: content, thumbnail: thumbnail);
    }
    return null;
  }

  @override
  Future<Map<String, String>> get categories async => {
    "News": "news",
    "Reviews": "reviews",
    "Guides": "guides",
    "Gaming": "gaming",
    "Gear": "gear",
    "Entertainment": "entertainment",
    "Tomorrow": "tomorrow",
    "Deals": "deals",
  };

  @override
  Future<Set<NewsArticle?>> categoryArticles({String category = "news", int page = 1}) async {
    Set<NewsArticle> articles = {};
    if(category=="/") category = "/news";
    var response = await http.get(Uri.parse("$homePage$category/page/$page"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements =
          document.querySelectorAll("ul[data-component=LatestStream] li[class]");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h2 a")?.text;
        String? excerpt = articleElement.querySelector("h2+div")?.text;
        String? authorTime = articleElement.querySelector("div[class*=engadgetFontDarkGray]")?.text;
        String? author = authorTime?.split(",")[0].replaceFirst("By ", "");
        String? date = authorTime?.split(",").last.trim();
        String? url = articleElement.querySelector("h2 a")?.attributes["href"];
        String? thumbnail = articleElement
                .querySelector("img[width]")
                ?.attributes["src"];
        String parsedTime = convertToIso8601("$date", "MM.dd.yyyy");

        articles.add(NewsArticle(
          this,
          title ?? "",
          "",
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
    Set<NewsArticle> articles = {};
    var response = await http.get(Uri.parse("https://search.engadget.com/search;?p=$searchQuery&pz=10&fr=engadget&fr2=sb-top&bct=0&b=${(page*10)+1}&pz=10&bct=0&xargs=0"));
    if (response.statusCode == 200) {
      Document document = html_parser.parse(utf8.decode(response.bodyBytes));
      List<Element> articleElements =
      document.querySelectorAll(".compArticleList li");
      for (Element articleElement in articleElements) {
        String? title = articleElement.querySelector("h4 a")?.text;
        String? excerpt = articleElement.querySelector("h4+p")?.text;
        String? author = articleElement.querySelector(".csub span[class*=pr]")?.text;
        String? date = articleElement.querySelector(".csub span[class*=pl]")?.text;
        String? url = articleElement.querySelector("h4 a")?.attributes["href"];
        String? thumbnail = articleElement
            .querySelector(".thmb")
            ?.attributes["src"];
        String parsedTime = convertToIso8601("$date", "MM.dd.yyyy");

        articles.add(NewsArticle(
          this,
          title ?? "",
          "",
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
}
