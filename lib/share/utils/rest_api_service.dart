import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'device_service.dart';

class RestApiService {
  static const String DOMAIN_API = 'https://api.petslife.com.vn/api/';

  static Future<void> checkInternet() async {
    bool isOnline = await DeviceService.hasNetwork();
    if(isOnline != true) {
      print('---------------------------------------');
      EasyLoading.dismiss();
    }
  }
  static Map<String, String> getHeaders() {
    Map<String, String> requestHeaders = {};
    return requestHeaders;
  }

  static Future<Map<String, dynamic>> getAPI(String path,[Map<String, String>? queryParameters]) async {
    checkInternet();
    final uri = Uri.parse(DOMAIN_API + path).replace(queryParameters: queryParameters);
    print('======================================');
    print('Method: GET');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('queryParameters: $queryParameters');
    final response = await get(uri, headers: getHeaders());
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return {};
  }

  static Future<List<Map<String, dynamic>>> getListAPI(String path,[Map<String, String>? queryParameters]) async {
    checkInternet();
    final uri = Uri.parse(DOMAIN_API + path).replace(queryParameters: queryParameters);
    print('======================================');
    print('Method: GET');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('queryParameters: $queryParameters');
    final response = await get(uri, headers: getHeaders());
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return [];
  }

  static Future<Map<String, dynamic>> patchAPI(String path,[Object? body]) async {
    checkInternet();
    final uri = Uri.parse(DOMAIN_API + path);
    print('======================================');
    print('Method: POST');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('body: $body');
    final response = await patch(uri, headers: getHeaders(), body: body);
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return {};
  }

  static Future<List<Map<String, dynamic>>> patchListAPI(String path,[Object? body]) async {
    checkInternet();
    final uri = Uri.parse(DOMAIN_API + path);
    print('======================================');
    print('Method: POST');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('body: $body');
    final response = await patch(uri, headers: getHeaders(), body: body);
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return [];
  }

  static Future<Map<String, dynamic>> postAPI(String path,[Object? body]) async {
    checkInternet();
    final uri = Uri.parse(DOMAIN_API + path);
    print('======================================');
    print('Method: POST');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('body: $body');
    final response = await post(uri, headers: getHeaders(), body: body);
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return json;
  }

  static Future<Map<String, dynamic>> putAPI(String path,int? id,[Object? body]) async {
    checkInternet();
    String urlString = DOMAIN_API + path;
    if(id != null) {
      urlString += '/$id';
    }
    final uri = Uri.parse('${urlString}');
    print('======================================');
    print('Method: PUT');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    print('body: $body');
    final response = await put(uri, headers: getHeaders(), body: body);
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    print("json: ${json}");
    return {};
  }

  static Future<Map<String, dynamic>> deleteAPI(String path,int id) async {
    checkInternet();
    final uri = Uri.parse('${DOMAIN_API + path}/${id}');
    print('======================================');
    print('Method: DELETE');
    print('uri: $uri');
    print('headers: ${getHeaders()}');
    final response = await delete(uri, headers: getHeaders());
    print('++++++++++++++++++++++++++++++++++++++');
    Map<String, dynamic> json = jsonDecode(response.body);
    return json;
  }
}