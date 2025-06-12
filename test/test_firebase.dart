import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:progetto/services/firestore_service.dart';

void main() {
  group('FirestoreService - getUserProfile', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);

      await fakeFirestore.collection('users').doc('testUid').set({
        'nickname': 'glorbo',
        'email': 'a@al.com',
        'imageBase64': 'fakebase64',
      });
    });

    test('returns UserModel when user exists', () async {
      final user = await firestoreService.getUserProfile('testUid');

      expect(user, isNotNull);
      expect(user!.uid, 'testUid');
      expect(user.nickname, 'glorbo');
      expect(user.email, 'a@al.com');
    });

    test('returns null when user does not exist', () async {
      final user = await firestoreService.getUserProfile('nonExistentUid');
      expect(user, isNull);
    });
  });
}
