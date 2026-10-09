/// The authentication template.
library;

export 'auth_app.dart';
export 'common/constants/demo_account.dart';
export 'core/presentation/auth_scope.dart' show AuthLegalLink;
export 'core/presentation/navigation/auth_navigation_cubit.dart'
    show AuthScreen;
export 'data/auth/remote/auth_remote_data_source.dart';
export 'data/auth/remote/in_memory_auth_remote_data_source.dart';
export 'domain/auth/mappers/auth_mapper.dart';
export 'domain/auth/models/account.dart';
export 'domain/auth/models/session.dart';
export 'domain/auth/models/social_provider.dart';
