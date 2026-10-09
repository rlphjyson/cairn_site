library;

import '../../backend/stores.dart';
import '../../domain/newsletter/newsletter.dart';

class NewsletterRepositoryImpl implements NewsletterRepository {
  NewsletterRepositoryImpl(this._store);
  final NewsletterStore _store;

  @override
  Future<bool> subscribe(String email) async => _store.add(email);
}
