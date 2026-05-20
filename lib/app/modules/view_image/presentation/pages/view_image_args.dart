import 'dart:typed_data';
import '../../../home/data/wallaper_response_modle.dart';

class ViewImageArgs {
  final Wallpaper wallInfo;
  final Uint8List? imageBytes;

  ViewImageArgs({
    required this.wallInfo,
    this.imageBytes,
  });
}