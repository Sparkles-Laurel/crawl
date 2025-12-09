import 'package:webdriver/async_io.dart';

/// Provides waiting extension for a webdriver.
extension WebDriverWaits on WebDriver {
  /// Waits until an element is present.
  Future<WebElement> waitFor(
    By by, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 300),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      try {
        final element = await findElement(by);
        return element; // found, return immediately
      } catch (_) {
        // not found yet — keep polling
      }
      await Future.delayed(pollInterval);
    }

    throw TimeoutException(
      null,
      'Element $by not found after ${timeout.inSeconds}s',
    );
  }
}