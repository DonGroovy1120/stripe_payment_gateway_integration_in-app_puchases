import 'package:dio/dio.dart';

mixin HomeBehavior {
   Dio dio = Dio();
   bool isProcessing = false;
}