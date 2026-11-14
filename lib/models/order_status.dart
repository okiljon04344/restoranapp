/// Order lifecycle:
/// `pending -> preparing -> ready -> served -> paid`, with `cancelled`
/// reachable from `pending` and `preparing`.
abstract final class OrderStatus {
  static const pending = 'pending';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const served = 'served';
  static const paid = 'paid';
  static const cancelled = 'cancelled';

  static const all = [pending, preparing, ready, served, paid, cancelled];

  /// Statuses that keep a table occupied (the bill is still open).
  static const active = [pending, preparing, ready, served];

  /// Statuses the kitchen still has to work on.
  static const kitchen = [pending, preparing, ready];

  static const _transitions = <String, Set<String>>{
    pending: {preparing, cancelled},
    preparing: {ready, cancelled},
    ready: {served},
    served: {paid},
  };

  static bool canTransition(String from, String to) =>
      _transitions[from]?.contains(to) ?? false;

  static bool isActive(String status) => active.contains(status);

  /// Maps status values written by earlier versions of the app onto the
  /// current lifecycle so old documents keep rendering.
  static String normalize(Object? raw) {
    switch (raw) {
      case 'cooking':
        return preparing;
      case 'delivered':
        return served;
      case 'completed':
        return paid;
    }
    return raw is String && all.contains(raw) ? raw : pending;
  }
}
