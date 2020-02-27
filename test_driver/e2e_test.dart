// Imports the Flutter Driver API.
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
    // First, define the Finders and use them to locate widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.


    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });



    test('Select Own profile', () async {

      final bankerTextFinder = find.text("Banker");
      final closeButton = find.byValueKey("close_button");

      await driver.tap(bankerTextFinder);  // acquire focus

      await new Future.delayed(const Duration(seconds : 5));

      final textFinder = find.text("This is your balance!");

      final isExists = await isPresent(textFinder, driver);
      expect(isExists, true);

      await driver.tap(closeButton);
    });

    test('Send money', () async {

      final ayushTextFinder = find.text("Ayush");
      final textFieldFinder = find.byValueKey("transfer_amount");
      final buttonFinder = find.byValueKey("transfer_button");

      await new Future.delayed(const Duration(seconds : 5));

      await driver.tap(ayushTextFinder);  // acquire focus
      await driver.tap(textFieldFinder);  // acquire focus

      await new Future.delayed(const Duration(seconds : 5));

      await driver.enterText('10');  // enter text
      await driver.waitFor(find.text('10'));

      await driver.tap(buttonFinder);

      await new Future.delayed(const Duration(seconds : 5));


      final amountFinder = find.text("5000");
      final isExists = await isPresent(amountFinder, driver);

      expect(isExists, true);

      await new Future.delayed(const Duration(seconds : 5));

    });

    test('Tap a profile', () async {

      final tabButtonFinder = find.byValueKey("profile_page_tab");
      final dropdownButtonFinder = find.byValueKey("dropdown_button");
      final ayushDropdownItemFinder = find.text("Ayush");

      await driver.tap(tabButtonFinder);
      await driver.tap(dropdownButtonFinder);

      await new Future.delayed(const Duration(seconds : 5));


      await driver.tap(ayushDropdownItemFinder);


      final isExists = await isPresent(ayushDropdownItemFinder, driver);

      expect(isExists, true);
    });


  });
}

isPresent(SerializableFinder byValueKey, FlutterDriver driver, {Duration timeout = const Duration(seconds: 1)}) async {
  try {
    await driver.waitFor(byValueKey,timeout: timeout);
    return true;
  } catch(exception) {
    return false;
  }
}