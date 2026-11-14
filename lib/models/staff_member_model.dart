import '../core/cafe_refs.dart';

/// A kitchen/floor staff account (`staff/{uid}`) or a pending access request
/// (`staffRequests/{uid}`); both documents are keyed by the Auth uid.
class StaffMember {
  const StaffMember({required this.uid, required this.email, this.createdAt});

  final String uid;
  final String email;
  final DateTime? createdAt;

  factory StaffMember.fromFirestore(Map<String, dynamic> data, String uid) =>
      StaffMember(
        uid: uid,
        email: readString(data['email']),
        createdAt: readDate(data['createdAt']),
      );
}
