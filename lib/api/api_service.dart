import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // POST request
  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    print("calling this api ...");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      // print("API RESPONSE FROM ${url} ===> ${response.body}");

      // Optional: You can handle or log response codes but not throw here
      //_handleResponse(response);

      return response;
    } on SocketException {
      throw Exception("No Internet connection");
    } on FormatException {
      throw Exception("Bad response format");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // GET request
  Future<http.Response> get(String url) async {
    print("calling this api ...");
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      // print("API RESPONSE FROM ${url} ===> ${response.body}");
      //_handleResponse(response);
      return response;
    } on SocketException {
      throw Exception("No Internet connection");
    } on FormatException {
      throw Exception("Bad response format");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // PATCH request
  Future<http.Response> patch(String url, Map<String, dynamic> data) async {
    print("calling this api ...");
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      // print("API RESPONSE FROM ${url} ===> ${response.body}");
      //_handleResponse(response);
      return response;
    } on SocketException {
      throw Exception("No Internet connection");
    } on FormatException {
      throw Exception("Bad response format");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }

  // // Optional: if you want, handle error based on caller logic instead of throwing here
  // void _handleResponse(http.Response response) {
  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     return;
  //   }
  //   // If you want, log or record the issue but don't throw
  //   print("HTTP error ${response.statusCode}: ${response.reasonPhrase}");
  // }
}
