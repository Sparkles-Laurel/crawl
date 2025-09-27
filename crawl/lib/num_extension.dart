/// Provides filtering extension for numbers.
library;

extension NumExtension on num {
  /// Checks if a given number is between [lower] and [upper]
  /// [exclusive] determines whether the upper and lower ends should be
  /// included or excluded. 
  bool between(num lower, num upper, {bool exclusive = false}) {
    if(exclusive) {
      return (this > lower) && (this < upper);
    }

    return (this >= lower) && (this <= upper);
  }
}