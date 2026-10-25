import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_universal_app/features/auth/domain/auth_provider.dart';

void main() {
  group('StaffRole.isGrantedBy', () {
    test('denies users without claims', () {
      expect(StaffRole.admin.isGrantedBy(null), isFalse);
      expect(StaffRole.kitchen.isGrantedBy(const {}), isFalse);
    });

    test('admin claim grants every role', () {
      const claims = {'admin': true};
      expect(StaffRole.admin.isGrantedBy(claims), isTrue);
      expect(StaffRole.kitchen.isGrantedBy(claims), isTrue);
    });

    test('kitchen claim does not grant admin', () {
      const claims = {'kitchen': true};
      expect(StaffRole.kitchen.isGrantedBy(claims), isTrue);
      expect(StaffRole.admin.isGrantedBy(claims), isFalse);
    });

    test('only a boolean true counts as granted', () {
      expect(StaffRole.admin.isGrantedBy(const {'admin': 'true'}), isFalse);
      expect(StaffRole.admin.isGrantedBy(const {'admin': false}), isFalse);
    });
  });

  group('StaffRole.fromName', () {
    test('maps route parameters to roles', () {
      expect(StaffRole.fromName('kitchen'), StaffRole.kitchen);
      expect(StaffRole.fromName('admin'), StaffRole.admin);
    });

    test('falls back to the most restrictive role', () {
      expect(StaffRole.fromName(null), StaffRole.admin);
      expect(StaffRole.fromName('unknown'), StaffRole.admin);
    });
  });
}
