import 'package:klinikkecantikan/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:klinikkecantikan/data_model/blog_response.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';

class BlogRepository {

  Future<BlogResponse> getHomeBlogs() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/get-fitur-blog");
    final response =
    await http.get(url,headers: {
      "App-Language": app_language.$,
    });
    return blogResponseFromJson(response.body);
  }

  Future<BlogResponse> getBlogs({name = "", page = 1}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/get-blog"+
        "?page=${page}&name=${name}");
    final response =
    await http.get(url,headers: {
      "App-Language": app_language.$,
    });
    return blogResponseFromJson(response.body);
  }



}
