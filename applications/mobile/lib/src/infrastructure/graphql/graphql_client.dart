import 'dart:async';
import 'dart:io' show Platform;

import 'package:ferry/ferry.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:http/http.dart' as http;

/// Supplies the current user's Firebase ID token to the GraphQL HTTP link.
///
/// Implementations MUST return the most recent token that has been verified
/// by the backend; returning `null` is permitted while the user is signed
/// out (queries that require auth will surface `DOWNSTREAM_AUTH_FAILED`).
abstract class AuthTokenSupplier {
  Future<String?> currentToken();
}

/// Builds a ferry [Client] configured to talk to the local graphql-gateway
/// emulator (or an arbitrary override) with a Bearer token injected from
/// Firebase Auth.
///
/// The returned client has no in-memory cache wiring beyond ferry's
/// defaults; list-returning queries should set `fetchPolicy: noCache` at the
/// call site when necessary.
class GraphQLClientFactory {
  const GraphQLClientFactory._();

  /// Port exposed by `docker/applications/compose.yaml` for the
  /// graphql-gateway service. iOS simulator can reach the host via
  /// `127.0.0.1`; the Android emulator uses the magic host alias
  /// `10.0.2.2`.
  static const int gatewayPort = 18180;

  static String _gatewayHost() {
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  /// The default endpoint for the emulator stack. Override via
  /// [create]'s `endpoint` argument when wiring a production build.
  static Uri defaultEndpoint() {
    return Uri.parse('http://${_gatewayHost()}:$gatewayPort/graphql');
  }

  static Client create({
    required AuthTokenSupplier tokenSupplier,
    Uri? endpoint,
    http.Client? httpClient,
  }) {
    final resolvedEndpoint = endpoint ?? defaultEndpoint();
    final inner = httpClient ?? http.Client();
    final authLink = _AuthHttpClient(
      tokenSupplier: tokenSupplier,
      inner: inner,
    );
    final link = HttpLink(
      resolvedEndpoint.toString(),
      httpClient: authLink,
    );
    return Client(link: link);
  }
}

/// Thin [http.BaseClient] that prepends `Authorization: Bearer <id-token>`
/// to every request when a token is available.
class _AuthHttpClient extends http.BaseClient {
  _AuthHttpClient({
    required this.tokenSupplier,
    required this.inner,
  });

  final AuthTokenSupplier tokenSupplier;
  final http.Client inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await tokenSupplier.currentToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'application/json';
    return inner.send(request);
  }

  @override
  void close() {
    inner.close();
    super.close();
  }
}
