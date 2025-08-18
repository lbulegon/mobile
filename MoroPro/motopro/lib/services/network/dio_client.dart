// lib/services/network/dio_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:motopro/services/local_storage.dart';
import 'package:motopro/utils/app_config.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  static Dio get dio => _i._build();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl, // host puro
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  bool _isRefreshing = false;
  final List<_Pending> _queue = [];

  Dio _build() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opt, h) async {
        final t = await LocalStorage.getAccessToken();
        if (t != null && t.isNotEmpty) {
          opt.headers['Authorization'] = 'Bearer $t';
        }
        h.next(opt);
      },
      onResponse: (res, h) {
        // debug opcional:
        // print('✅ ${res.requestOptions.method} ${res.requestOptions.uri} -> ${res.statusCode}');
        h.next(res);
      },
      onError: (e, h) async {
        final is401 = e.response?.statusCode == 401;
        final retried = e.requestOptions.extra['__retried__'] == true;
        if (is401 && !retried) {
          final completer = Completer<Response>();
          _queue.add(_Pending(e.requestOptions, completer));
          if (!_isRefreshing) {
            _isRefreshing = true;
            try {
              await _refreshToken();
              final newAccess = await LocalStorage.getAccessToken();
              for (final p in _queue) {
                final ro = p.req;
                ro.extra['__retried__'] = true;
                ro.headers = Map.of(ro.headers);
                if (newAccess != null && newAccess.isNotEmpty) {
                  ro.headers['Authorization'] = 'Bearer $newAccess';
                } else {
                  ro.headers.remove('Authorization');
                }
                try {
                  final resp = await _dio.fetch(ro);
                  p.complete.complete(resp);
                } catch (err) {
                  p.complete.completeError(err);
                }
              }
            } catch (_) {
              await LocalStorage.clearAll();
              for (final p in _queue) {
                p.complete.completeError(DioException(
                  requestOptions: p.req,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: p.req,
                    statusCode: 401,
                    data: {'detail': 'token_expired_or_invalid'},
                  ),
                ));
              }
            } finally {
              _queue.clear();
              _isRefreshing = false;
            }
          }
          try {
            final r = await completer.future;
            return h.resolve(r);
          } catch (err) {
            return h.reject(err is DioException ? err : e);
          }
        }
        h.next(e);
      },
    ));
    return _dio;
  }

  Future<void> _refreshToken() async {
    final refresh = await LocalStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw Exception('Sem refresh token');
    }
    final resp = await _dio.post(
      AppConfig.refreshToken, // ex: /api/v1/token/refresh/
      data: {'refresh': refresh},
      options: Options(headers: {'Authorization': null}),
    );
    final newAccess = resp.data['access'] ?? resp.data['access_token'];
    final newRefresh = resp.data['refresh'] ?? resp.data['refresh_token'];
    if (newAccess == null || (newAccess is String && newAccess.isEmpty)) {
      throw Exception('Refresh não retornou access token');
    }
    await LocalStorage.setTokensIfPresent(
      access: newAccess is String ? newAccess : null,
      refresh: newRefresh is String ? newRefresh : null,
    );
  }
}

class _Pending {
  final RequestOptions req;
  final Completer<Response> complete;
  _Pending(this.req, this.complete);
}
