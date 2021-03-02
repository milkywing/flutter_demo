import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_demo/utils/cookie_util.dart';

class Resp<T> {
  String status;
  int code;
  String msg;
  T data;
  Response response;

  Resp(this.status, this.code, this.msg, this.data, this.response);

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('==========>Resp<$T><==========\n');
    sb.write('"status":"$status"\n');
    sb.write(',"code":$code\n');
    sb.write(',"msg":"$msg"\n');
    sb.write(',"data":$data\n');
    return sb.toString();
  }
}

class DioUtil {
  factory DioUtil() {
    if (_singleton == null) {
      DioUtil singleton = DioUtil._init();
      _singleton = singleton;
      return singleton;
    }
    return _singleton;
  }

  DioUtil._init() {
    _dio = new Dio(_baseOptions);
    if (_enableCookie) {
      _addCookieManager(_dio);
    }
  }

  /// DioUtil单例
  static DioUtil _singleton;

  /// Dio单例
  static Dio _dio;

  /// Resp [String status]对应的响应字段, 默认：status.
  static String _statusKey = 'status';

  /// Resp [int code]对应的响应字段, 默认：code.
  static String _codeKey = 'code';

  /// Resp [String msg]对应的响应字段, 默认：msg.
  static String _msgKey = 'msg';

  /// Resp [T data]对应的响应字段, 默认：data.
  static String _dataKey = 'data';

  /// base配置
  static BaseOptions _baseOptions = BaseOptions();

  /// 是否debug模式
  static bool _isDebug = false;

  /// 是否使用cookie
  static bool _enableCookie = true;

  /// 设置默认响应字段
  static setRespKey({
    String statusKey,
    String codeKey,
    String msgKey,
    String dataKey,
  }) {
    _statusKey = statusKey ?? _statusKey;
    _codeKey = codeKey ?? _codeKey;
    _msgKey = msgKey ?? _msgKey;
    _dataKey = dataKey ?? _dataKey;
  }

  /// 获取baseOptions
  static BaseOptions getBaseOptions() => _baseOptions;

  /// 设置baseOptions
  static void setBaseOptions(BaseOptions options) {
    _baseOptions = options;
  }

  /// 开启调试模式
  static void enableDebug() {
    _isDebug = true;
  }

  /// 禁用cookie
  static void disableCookie() {
    _enableCookie = false;
  }

  /// 添加cookie管理器
  static void _addCookieManager(Dio dio) async {
    dio.interceptors.add(
      CookieManager(await CookieUtil.pCookieJar),
    );
  }

  /// 添加拦截器
  static void addInterceptor(Interceptor element) {
    _dio?.interceptors?.add(element);
  }

  /// 基本请求方法
  Future<Resp<T>> request<T>(
    String path, {
    String method,
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
  }) async {
    if (method != null && options != null) {
      options = options.merge(method: method.toUpperCase());
    }

    Response response = await _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
    if (_isDebug) {
      _printHttpLog(response);
    }
    Map<String, dynamic> dataMap;
    String _status, _msg;
    int _code;
    T _data;

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        if (response.data is Map) {
          dataMap = response.data;
        } else if (response.data is List) {
          dataMap = {_dataKey: response.data};
        } else {
          dataMap = (response == null ||
                  response.data == null ||
                  response.data.toString().isEmpty)
              ? new Map()
              : json.decode(response.data.toString());
        }
        _status = (dataMap[_statusKey] is int)
            ? dataMap[_statusKey].toString()
            : dataMap[_statusKey];
        _code = (dataMap[_codeKey] is String)
            ? int.tryParse(dataMap[_codeKey])
            : dataMap[_codeKey];
        _msg = dataMap[_msgKey];
        _data = dataMap[_dataKey];

        return new Resp(_status, _code, _msg, _data, response);
      } catch (e) {
        return new Future.error(new DioError(response: response, error: e));
      }
    }
    return new Future.error(new DioError(
      response: response,
      error: 'statusCode: ${response.statusCode}, service error',
      type: DioErrorType.RESPONSE,
    ));
  }

  /// get方法封装
  Future<Resp<T>> fetch<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
  }) async {
    return request(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// post方法封装
  Future<Resp<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
  }) async {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options.merge(
        // todo: 这里考虑使用json？
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8',
      ),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// upload方法封装
  Future<Resp<T>> upload<T>(
    String path, {
    formData,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
  }) async {
    return request(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options.merge(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  /// 日志打印
  static void _printHttpLog(Response response) {
    try {
      print('==========================>Http Log<==========================');
      _logWithTag('response.data type', response.data.runtimeType);
      _logWithTag('method', response.request.method);
      _logWithTag('baseUrl', response.request.baseUrl);
      _logWithTag('path', response.request.path);
      _logWithTag('statusCode', response.statusCode);
      _logWithTag('reqdata', response.request.data);
      _logWithTag('response', response.data, finalLog: true);
      print('========================>Http Log End<========================');
    } catch (e) {
      print('==========================>Log Fail<==========================');
    }
  }

  /// 带标签打印
  static void _logWithTag(String tag, Object value, {bool finalLog = false}) {
    String str = value.toString();
    print('[$tag]:  ' +
        str +
        (finalLog ? '' : '\n------------------------------'));
  }

  /// 创建全新Dio实例
  static Dio newDio(
      {BaseOptions options, bool isDebug = false, bool enableCookie = true}) {
    options = options ?? _baseOptions;
    Dio dio = new Dio(options);
    if (isDebug) {
      dio.interceptors.add(InterceptorsWrapper(
        onResponse: (Response response) async {
          _printHttpLog(response);
          return response; // continue
        },
      ));
    }
    if (enableCookie) {
      _addCookieManager(dio);
    }
    return dio;
  }
}

// void main(List<String> args) async {
//   // Dio dio = DioUtil.newDio(isDebug: true);
//   // Response<Map> response = await dio.request(
//   //   'https://oshinonya.com/apis/apiv10.php',
//   //   queryParameters: {'s': 'python'},
//   // );

//   // DioUtil.enableDebug();
//   // DioUtil dio = DioUtil();
//   // Resp<List> res = await dio.request('https://oshinonya.com/music/music.json');
//   // print(res);
// }