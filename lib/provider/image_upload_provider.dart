import 'package:arm_group_chat/enum/image_view_state.dart';
import 'package:flutter/foundation.dart';

class ImageUploadProvider with ChangeNotifier {
  ImageViewState _ImageViewState = ImageViewState.IDLE;
  ImageViewState get getImageViewState => _ImageViewState;

  void setToLoading() {
    _ImageViewState = ImageViewState.LOADING;
    notifyListeners();
  }

  void setToIdle() {
    _ImageViewState = ImageViewState.IDLE;
    notifyListeners();
  }
}
