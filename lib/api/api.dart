import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sunozara/models/artilce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constant.dart';

class ApiService {
  Future<dynamic> providerLogin(String name, String email, String phone,
      String photo, String provider_id, String provider) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.providerLogin);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "image": photo,
        "name": name,
        "mobile": phone,
        "provider": provider,
        "provider_id": provider_id
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> appConfig() async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.appConfig);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> checkSubs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.checkSubs);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getSliders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.sliders);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getcities() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getLocations);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getPopulatCat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.popularCat);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAllCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.allCategories);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getPopularAudios() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.poupolarAudios);
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getPopularProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.poupolarProducts);
    //print(url);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> viewsCountAudio(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.viewsCountAudio);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"id": id.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> delAddress(String aid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.delAddress);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"address_id": aid.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAudioDownload() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getDlAudio);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> delAudioDownload(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.delDlAudio);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "audio_id": audio_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> setAudioDownload(String audio_id, String eid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.setAudioDl);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "audio_id": audio_id.toString(),
        "eid": eid.toString()
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> viewsCountArticle(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];

    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.viewsCountArticle);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"id": id.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getPopularArtciles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.poupolarArticles);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"lang": jsonEncode(selectedLang)}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getRelatedArtciles(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.relatedArticles);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
        "lang": jsonEncode(selectedLang)
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAudioList(String lang, String page) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.relatedArticles);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "page": page.toString(),
        "lang": jsonEncode(selectedLang)
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> delAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.delAccount);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getArticleByCategory(
      String lang, String page, String cat_id, String sort_by) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl +
        ApiConstants.articleByCategory +
        "/" +
        cat_id.toString());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
        "sort_by": sort_by.toString(),
        "page": page.toString()
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAudioByCategory(
      String lang, String page, String cat_id, String sort_by) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl +
        ApiConstants.audioByCategory +
        "/" +
        cat_id.toString());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
        "sort_by": sort_by.toString(),
        "page": page.toString()
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAudioEpisodes(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl +
        ApiConstants.audioEpisodes +
        "/" +
        audio_id.toString());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getArticleReview(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getArticleReview);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"article_id": audio_id.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> updateOnesignal(String subs) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.updateoneSignal);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "sub_id": subs.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> delpostArticleReview(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.delpostArticleReview);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "article_id": audio_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> postArticleReview(
      String audio_id, String rating, String comment, String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.postArticleReview);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "article_id": audio_id.toString(),
        "rating": rating.toString(),
        "comment": comment.toString(),
        "type": type.toString()
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> delpostAudioReview(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.delpostAudioReview);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "audio_id": audio_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> postAudioReview(
      String audio_id, String rating, String comment, String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.postAudioReview);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "audio_id": audio_id.toString(),
        "rating": rating.toString(),
        "comment": comment.toString(),
        "type": type.toString()
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> markFavAudio(String audio_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.markFavAudio);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "audio_id": audio_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getHomeSettingData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.homeCustomSettings);


    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
      }),
    );
    print("token:$token");
    print(jsonEncode(selectedLang));
    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getArticleCatData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.articleCatData);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getFavAudioList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.favAudioList);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getMyArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.myArticles);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> createArticle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.startWriting);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> updateArticle(ArticleModel article, String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl +
        ApiConstants.updateArticle +
        "/" +
        article.article_id.toString());

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "category_id": article.category.toString(),
        "title": article.title.toString(),
        "post_lang": article.language.toString(),
        "description": article.description.toString(),
        "images_id": article.thumb_id.toString(),
        "status": status,
        "tags": jsonEncode(article.tags),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> deleteArticle(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.deleteArticle);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getProducts({String page = "1", String catid = "all"}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getProducts);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "page": page.toString(),
        "catid": catid.toString(),
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getOrder(String id, String item_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getOrder);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
        "item_id": item_id.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> rateOrder(String id, String rate, String remarks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.orderRate);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
        "rate": rate.toString(),
        "remarks": remarks.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> createSubs(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.createSubs);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"id": id.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> subscriptions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.subscriptions);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> cancelOrder(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.cancelOrder);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{"id": id.toString()}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> orders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.myOrders);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> updateProfile(
      String name, String email, String phone, String bio, String photo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.updateProfile);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "name": name.toString(),
        "email": email.toString(),
        "phone": phone.toString(),
        "bio": bio.toString(),
        "photo": photo.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;
      //print(arrayObjsText);
      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> confirmSubs(String id, String pid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.confirmSubs);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
        "payment_id": pid.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> confirmOrder(String id, String pid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.confirmOrder);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": id.toString(),
        "payment_id": pid.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> createOrder(List<String> itemIds, String amount,
      String discount, String coupon, String pmode, String address_id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.createOrder);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "coupon": coupon.toString(),
        "amount": amount.toString(),
        "discount": discount.toString(),
        "payment_mode": pmode.toString(),
        "address_id": address_id.toString(),
        "items": jsonEncode(itemIds),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> applyCoupon(String coupon, String amount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.applyCoupon);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "coupon": coupon.toString(),
        "amount": amount.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> search(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.search);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "key": key.toString(),
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getRelProducts(String pid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getRelatedProducts);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": pid.toString(),
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAuthorInfo(String pid) async {
    //print(pid);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic selectedLang = [];
    if (prefs.getString("selected_langs") != null) {
      dynamic sllangs =
          jsonDecode(prefs.getString("selected_langs").toString());

      selectedLang = sllangs;
    }
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getAuthorInfo);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "id": pid.toString(),
        "lang": jsonEncode(selectedLang),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> getAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.getAddresses);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> updateAddress(
    String aid,
    String house_no,
    String address_line_1,
    String address_line_2,
    String pincode,
    String phone,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.updateAddress);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "address_id": aid.toString(),
        "house_no": house_no.toString(),
        "address_line_1": address_line_1.toString(),
        "address_line_2": address_line_2.toString(),
        "pincode": pincode.toString(),
        "phone": phone.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }

  Future<dynamic> addAddress(
    String house_no,
    String address_line_1,
    String address_line_2,
    String pincode,
    String phone,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("user_token").toString();
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.addAddress);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + token
      },
      body: jsonEncode(<String, String>{
        "house_no": house_no.toString(),
        "address_line_1": address_line_1.toString(),
        "address_line_2": address_line_2.toString(),
        "pincode": pincode.toString(),
        "phone": phone.toString(),
      }),
    );

    if (response.statusCode == 200) {
      var arrayObjsText = response.body;

      var jsonData = jsonDecode(arrayObjsText);

      return jsonData;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to fetch Data.');
    }
  }
}
