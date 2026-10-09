/// What shipping costs and how long it takes.
abstract final class ShippingPolicy {
  /// Standard orders at or above this (discounted) subtotal ship free.
  static const double freeShippingThreshold = 150;

  /// The standard rate below the threshold.
  static const double flatRate = 8;

  /// The express rate, whatever the subtotal.
  static const double expressRate = 12;

  /// Business days a standard delivery takes.
  static const int standardDays = 5;

  /// Business days an express delivery takes.
  static const int expressDays = 2;

  /// Days after delivery in which an item can be returned.
  static const int returnWindowDays = 30;
}
