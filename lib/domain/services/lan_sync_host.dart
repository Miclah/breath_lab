import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/lan_pairing.dart';
import '../models/sync_payload.dart';
import 'sync_service.dart';

/// Where a hosted LAN sync exchange is up to.
sealed class LanSyncHostStatus {
  const LanSyncHostStatus();
}

/// The server is up and waiting for the phone to scan the QR and connect.
class LanSyncServing extends LanSyncHostStatus {
  const LanSyncServing(this.pairing);
  final LanPairing pairing;
}

/// A peer connected and the merge is running.
class LanSyncExchanging extends LanSyncHostStatus {
  const LanSyncExchanging();
}

/// The exchange completed — both devices now hold the merged state.
class LanSyncHostDone extends LanSyncHostStatus {
  const LanSyncHostDone(this.summary);
  final SyncImportSummary summary;
}

/// The exchange failed or timed out. The server is stopped.
class LanSyncHostFailed extends LanSyncHostStatus {
  const LanSyncHostFailed(this.message);
  final String message;
}

/// The Windows side of QR-paired LAN sync.
///
/// Binds an ephemeral-port `HttpServer` on every interface, hands back a
/// [LanPairing] to put in a QR, and serves exactly one `POST /sync`: it merges
/// the body against local state, answers with its own payload so the phone
/// converges too, then stops. A bad or missing bearer token is refused; an
/// idle server gives up after [idleTimeout].
class LanSyncHost {
  LanSyncHost(
    this._syncService, {
    required this.deviceName,
    this.idleTimeout = const Duration(minutes: 2),
    Future<List<String>> Function()? resolveHosts,
  }) : _resolveHosts = resolveHosts ?? _localIpv4s;

  final SyncService _syncService;
  final String deviceName;
  final Duration idleTimeout;
  final Future<List<String>> Function() _resolveHosts;

  final _statusController = StreamController<LanSyncHostStatus>.broadcast();
  HttpServer? _server;
  LanPairing? _pairing;
  Timer? _idleTimer;
  var _consumed = false;

  Stream<LanSyncHostStatus> get status => _statusController.stream;

  /// Bind, enumerate addresses, mint a token. Returns the pairing to encode
  /// into the QR. Throws if no usable network interface is available.
  Future<LanPairing> start() async {
    final hosts = await _resolveHosts();
    if (hosts.isEmpty) {
      throw const LanSyncHostException(
        'This device is not on a network. Connect to Wi-Fi and try again.',
      );
    }

    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server = server;
    final pairing = LanPairing.mint(
      hosts: hosts,
      port: server.port,
      deviceName: deviceName,
    );
    _pairing = pairing;

    server.listen(
      _handle,
      onError: (Object e) => _fail('Network error: $e'),
      cancelOnError: false,
    );
    _armIdleTimer();
    _emit(LanSyncServing(pairing));
    return pairing;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      if (request.method != 'POST' || request.uri.path != '/sync') {
        response.statusCode = HttpStatus.notFound;
        await response.close();
        return;
      }
      if (!_authorised(request)) {
        response.statusCode = HttpStatus.unauthorized;
        await response.close();
        return;
      }
      if (_consumed) {
        response.statusCode = HttpStatus.conflict;
        await response.close();
        return;
      }

      _idleTimer?.cancel();
      _emit(const LanSyncExchanging());

      final body = await utf8.decodeStream(request);

      final SyncImportSummary summary;
      try {
        summary = await _syncService.applyRemotePayload(
          SyncPayload.decode(body),
        );
      } on SyncPayloadException catch (e) {
        response.statusCode = HttpStatus.unprocessableEntity;
        response.write(e.message);
        await response.close();
        _fail(e.message);
        return;
      }

      _consumed = true;
      final localPayload = await _syncService.buildLocalPayload();
      response.statusCode = HttpStatus.ok;
      response.headers.contentType = ContentType.json;
      response.write(localPayload.encode());
      await response.close();

      _emit(LanSyncHostDone(summary));
      await stop();
    } catch (e) {
      try {
        response.statusCode = HttpStatus.internalServerError;
        await response.close();
      } catch (_) {}
      _fail('Sync failed: $e');
    }
  }

  bool _authorised(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    const prefix = 'Bearer ';
    if (header == null || !header.startsWith(prefix)) return false;
    return _constantTimeEquals(
      header.substring(prefix.length),
      _pairing!.token,
    );
  }

  void _armIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, () {
      _fail('No device connected. Try again.');
    });
  }

  void _emit(LanSyncHostStatus status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }

  void _fail(String message) {
    _emit(LanSyncHostFailed(message));
    stop();
  }

  /// Idempotent. Always safe to call, including before [start].
  Future<void> stop() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    final server = _server;
    _server = null;
    await server?.close(force: true);
    if (!_statusController.isClosed) await _statusController.close();
  }
}

Future<List<String>> _localIpv4s() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
    includeLinkLocal: false,
  );
  return [
    for (final i in interfaces)
      for (final a in i.addresses)
        // Drop APIPA (169.254/16): assigned when DHCP failed, never routable
        // to the phone.
        if (!a.address.startsWith('169.254.')) a.address,
  ];
}

class LanSyncHostException implements Exception {
  const LanSyncHostException(this.message);
  final String message;
  @override
  String toString() => 'LanSyncHostException: $message';
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
