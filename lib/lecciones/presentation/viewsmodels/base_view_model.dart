import 'package:flutter/foundation.dart';
import 'package:integrador/core/error/failure.dart';

enum ViewState { initial, loading, loaded, error, empty }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.initial;
  Failure? _failure;
  bool _disposed = false;

  // Getters
  ViewState get state => _state;
  Failure? get failure => _failure;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;
  bool get isLoaded => _state == ViewState.loaded;
  String? get errorMessage => _failure?.message;

  // State management
  void setState(ViewState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  void setLoading() => setState(ViewState.loading);
  void setLoaded() => setState(ViewState.loaded);
  void setEmpty() => setState(ViewState.empty);

  void setError(Failure failure) {
    if (_disposed) return;
    _failure = failure;
    setState(ViewState.error);
  }

  void clearError() {
    if (_disposed) return;
    _failure = null;
    if (_state == ViewState.error) {
      setState(ViewState.initial);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}