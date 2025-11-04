/// Provides filtering extension for numbers.
library;

enum Exclusion {
  none, left, right, both
}

extension NumExtension on num {
  /// Checks if a given number is between [lower] and [upper]
  /// [exclusive] determines whether the upper and lower ends should be
  /// included or excluded. 
  bool between(num lower, num upper, {Exclusion exclusion = Exclusion.none}) {
    if(exclusion == Exclusion.both) {
      return (this > lower) && (this < upper);
    } else if(exclusion == Exclusion.left) {
      return (this > lower) && (this <= upper);
    } else if(exclusion == Exclusion.right) {
      return (this >= lower) && (this < upper);
    } else if(exclusion == Exclusion.none) {}
    
    return (this >= lower) && (this <= upper);
  }
}