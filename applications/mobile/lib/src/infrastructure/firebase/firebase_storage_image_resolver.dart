import 'package:firebase_storage/firebase_storage.dart';

/// Resolves a Firebase Storage object path (e.g.
/// `actors/stub-actor-demo/images/stub-img-for-stub-vocab-0000.png`) to a
/// long-lived download URL that `Image.network(...)` can render.
///
/// Kept separate from the GraphQL adapters so presentation-layer widgets
/// can decorate the resolver with in-memory caching without pulling in the
/// GraphQL client.
class FirebaseStorageImageResolver {
  FirebaseStorageImageResolver({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<Uri> resolve(String assetReference) async {
    final reference = _storage.ref(assetReference);
    final downloadUrl = await reference.getDownloadURL();
    return Uri.parse(downloadUrl);
  }
}
