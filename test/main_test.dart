import 'package:test/test.dart';
import 'package:monopoly_atm/main.dart';

test('correct answer', () {
  final mainPage = MainPage();
  changeText(true);
  expect(subPageAnswerText, correctAnswerText);
});