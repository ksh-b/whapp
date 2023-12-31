import 'package:intl/intl.dart';
import 'package:whapp/model/article.dart';
import 'package:whapp/model/publisher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:whapp/utils/time.dart';

class BBC extends Publisher {
  @override
  String get name => "BBC";

  @override
  String get homePage => "https://www.bbc.com";

  @override
  Future<Map<String, String>> get categories => extractCategories();

  Future<Map<String, String>> extractCategories() async {
    return {
      "World": "world",
      "Asia": "asia",
      "UK": "uk",
      "Business": "business",
      "Technology": "technology",
      "Science": "science",
    };
  }

  Map<String, String> uuidMap() {
    return {
      "world": "8467c0e0-584b-41de-9682-756b311216b5",
      "asia": "070fca6a-b5c7-4b7f-8834-1c989fd40297",
      "uk": "082101b1-72b1-4e45-943d-29d6dc6f97b4",
      "business": "19a1d11b-1755-4f97-8747-0c9534336a47",
    };
  }

  Map<String, Map<String, String>> topicMap() {
    return {
      "technology": {
        "topic": "cd1qez2v2j2t",
        "urn": "b2790c4d-d5c4-489a-84dc-be0dcd3f5252",
      },
      "science": {
        "topic": "c43v9644301t",
        "urn": "0e18053e-731e-400a-a5b4-0f4088c74fd0",
      },
    };
  }

  Future<Set<NewsArticle>> extractBatch(String id, int page) async {

    Set<NewsArticle> articlesData = {};
    String apiUrl = "https://push.api.bbci.co.uk/batch?"
        "t=/data/bbc-morph-lx-commentary-data-paged/about/$id/"
        "isUk/false/limit/20/nitroKey/lx-nitro/pageNumber/$page/version/1.5.6";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        var articles = data["payload"][0]["body"]["results"];
        for (var article in articles) {
          var title = article['title'];
          var author = article.containsKey("contributor")?article['contributor']["name"]:"";
          var thumbnail = article["image"]["href"];
          var time = article["lastPublished"];
          var articleUrl = article['url'];
          var excerpt = article['summary'];
          articlesData.add(NewsArticle(
            this,
            title ?? "",
            "",
            excerpt,
            author ?? "",
            articleUrl,
            thumbnail ?? "",
            parseDateString(time?.trim() ?? ""),
          ));
        }
      }

    return articlesData;
  }

  Future<Set<NewsArticle>> extractTopic(
      String topicId, String groupResourceId, int page) async {
    Set<NewsArticle> articlesData = {};
    String apiUrl = 'https://www.bbc.com/wc-data/container/topic-stream?'
        'adSlotType=mpu_middle&enableDotcomAds=true&isUk=false'
        '&lazyLoadImages=true&pageNumber=$page&pageSize=10'
        '&promoAttributionsToSuppress=["/news","/news/front_page"]'
        '&showPagination=true&title=Latest News'
        '&tracking={"groupName":"Latest News","groupType":"topic stream",'
        '"groupResourceId":"urn:bbc:vivo:curation:$groupResourceId",'
        '"groupPosition":5,"topicId":"$topicId"}'
        '&urn=urn:bbc:vivo:curation:$groupResourceId';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      var articles = data["posts"];
      for (var article in articles) {
        var title = article['headline'];
        var author = article['contributor'] ?? "";
        var thumbnail = article["image"]["src"];
        var time = convertToIso8601(article["timestamp"]);
        var articleUrl = article['url'];
        var excerpt = "";
        articlesData.add(NewsArticle(
          this,
          title ?? "",
          "",
          excerpt,
          author ?? "",
          articleUrl,
          thumbnail ?? "",
          parseDateString(time),
        ));
      }
    }
    return articlesData;
  }

  String convertToIso8601(String inputTime) {
    DateTime today = DateTime.now();
    DateFormat inputFormat = DateFormat('HH:mm dd MMMM yyyy');
    DateTime parsedTime;

    try {
      if (inputTime
          .split(" ")
          .length == 3) { // 04:20 20 December
        parsedTime = inputFormat.parse('$inputTime ${today.year.toString()}');
      } else if (inputTime
          .split(" ")
          .length == 1) { // 20 December
        parsedTime =
            inputFormat.parse('00:00 $inputTime ${today.year.toString()}');
      } else if (inputTime
          .split(" ")
          .length == 2) { // 20 December 2020
        parsedTime = inputFormat.parse('00:00 $inputTime');
      } else { // 04:20
        String fullDate =
            "${DateFormat('dd').format(today)} ${DateFormat('MMMM').format(
            today)} ${DateFormat('yyyy').format(today)}";
        parsedTime = inputFormat.parse('$inputTime ${fullDate.toString()}');
      }
      String iso8601Format = DateFormat('yyyy-MM-ddTHH:mm:ss').format(
          parsedTime);
      return iso8601Format;
    } catch (e) {
      return inputTime;
    }
  }

  @override
  Future<NewsArticle?> article(NewsArticle newsArticle) async {
    var response = await http.get(Uri.parse("$homePage${newsArticle.url}"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var article = document.querySelector('.article__main:nth-child(1)');
      var titleElement = article?.querySelector('h1');
      var excerptElement = article?.querySelector('div b');
      var timeElement = article?.querySelector('time');
      var thumbnailElement = article?.querySelector('img');
      var authorElement = article?.querySelector("div[class*=TextContributorName]");
      var title = titleElement?.text;
      var content = article?.innerHtml;
      var author = authorElement?.text.replaceFirst("By ", "");
      var excerpt = excerptElement?.text;
      var thumbnail = thumbnailElement?.attributes["src"];
      var time = timeElement?.attributes["datetime"];
      
      return NewsArticle(
        this,
        title ?? "",
        content ?? "",
        excerpt ?? "",
        author ?? "",
        newsArticle.url,
        thumbnail ?? "",
        parseDateString(time?.trim() ?? ""),
      );
    }
    return null;
  }

  @override
  Future<Set<NewsArticle?>> articles({
    String category = "world",
    int page = 1,
  }) async {
    return super.articles(category: category, page: page);
  }

  @override
  Future<Set<NewsArticle?>> categoryArticles({
    String category = "/",
    int page = 1,
  }) async {
    if (category == "/") {
      category = "world";
    }
    Map uuidMap_ = uuidMap();
    Map topicMap_ = topicMap();
    if(uuidMap_.containsKey(category)) {
      return extractBatch(uuidMap_[category], page);
    } else if (topicMap_.containsKey(category)) {
      return extractTopic(topicMap_[category]["topic"], topicMap_[category]["urn"], page);
    }
    return {};
  }

  @override
  Future<Set<NewsArticle?>> searchedArticles({
    required String searchQuery,
    int page = 1,
  }) async {
    Set<NewsArticle?> articles = {};
    var response = await http.get(Uri.parse("https://www.bbc.co.uk/search?q=$searchQuery&page=$page"));
    if (response.statusCode == 200) {
      var document = html_parser.parse(utf8.decode(response.bodyBytes));

      var articleElements = document.querySelectorAll('li div[data-testid]');
      for (var element in articleElements) {
        var titleElement = element.querySelector('a span');
        var thumbnailElement = element.querySelector('img');
        var articleUrlElement = element.querySelector('a');
        var excerptElement = element.querySelector('p[class*=Paragraph]');
        var timeElement = element.querySelector('span[class*=MetadataText]');
        var title = titleElement?.text;
        var author = "";
        var excerpt = excerptElement?.text;
        var thumbnail = thumbnailElement?.attributes["src"];
        var time = timeElement?.text;
        var articleUrl = articleUrlElement?.attributes["href"];

        if (time!=null) {
          time = convertToIso8601(time);
        }

        articles.add(NewsArticle(
          this,
          title ?? "",
          "",
          excerpt ?? "",
          author,
          articleUrl?.replaceFirst(homePage, "") ?? "",
          thumbnail ?? "",
          parseDateString(time?.trim() ?? ""),
        ));
      }
    }
    return articles;
  }
}
