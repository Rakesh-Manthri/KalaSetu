import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/services/api_client.dart';
import 'package:kalasetu_app/services/http_api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  return dio;
});

/// Direct HTTP client linked to the FastAPI Python backend
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return HttpApiClient(dio);
});

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
