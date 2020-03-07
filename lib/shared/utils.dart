class Utils {
  bool _isNumeric(String s) {
    if (s == null || s == '') {
      return false;
    }
    return int.parse(s) != null;
  }
}