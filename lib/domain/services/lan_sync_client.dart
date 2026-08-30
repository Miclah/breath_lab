import 'dart:convert';
import 'dart:io';

import '../models/lan_pairing.dart';
import '../models/sync_payload.dart';
import 'sync_service.dart';

/// A LAN sync exchange failed in a way worth telling the user about.
class LanSyncClientException implements Exception {
  const LanSyncClientException(this.message);
  final String message;
  @override
  String toString() => 'LanSyncClientException: $message';
}

/// The Android side of QR-paired LAN sync.
///
/// Given a [LanPairing] read from the host's QR, POSTs this device's payload
/// to `http://<host>:<port>/sync` with the bearer token — trying each
/// candidate address in turn — and applies the host's reply so both devices
/// converge in one round trip.
class LanSyncClient {
  LanSyncClient(
    this._syncService, {
    this.connectTimeout = const Duration(seconds: 8),
  });

  final SyncService _syncService;
  final Duration connectTimeout;

  Future<SyncImportSummary> exchange(LanPairing pairing) async {
    final body = (await _syncService.buildLocalPayload()).encode();

    for (final host in pairing.hosts) {
      try {
        return await _tryHost(host, pairing, body);
      } on LanSyncClientException {
        rethrow;
      } catch (_) {
        // Unreachable address — try the next candidate.
      }
    }

    throw LanSyncClientException(
      'Could not reach ${_hostLabel(pairing)} on this network. Check that '
      'both devices are on the same Wi-Fi, then scan again.',
    );
  }

  Future<SyncImportSummary> _tryHost(
    String host,
    LanPairing pairing,
    String body,
  ) async {
    final client = HttpClient()..connectionTimeout = connectTimeout;
    try {
      final request = await client.postUrl(
        pairing.baseUriFor(host).replace(path: '/sync'),
      );
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${pairing.token}',
      );
      request.headers.contentType = ContentType.json;
      request.write(body);
      final response = await request.close();

      switch (response.statusCode) {
        case HttpStatus.ok:
          final replyBody = await utf8.decodeStream(response);
          return _syncService.applyRemotePayload(SyncPayload.decode(replyBody));
        case HttpStatus.unauthorized:
          await response.drain<void>();
          throw const LanSyncClientException(
            'This pairing code has expired. Show a new one on the PC and scan '
            'again.',
          );
        case HttpStatus.conflict:
          await response.drain<void>();
          throw const LanSyncClientException(
            'This pairing code was already used. Show a new one on the PC.',
          );
        case HttpStatus.unprocessableEntity:
          final reason = await utf8.decodeStream(response);
          throw LanSyncClientException(
            reason.isEmpty ? 'The PC rejected the sync data.' : reason,
          );
        default:
          await response.drain<void>();
          throw 'HTTP ${response.statusCode} from $host';
      }
    } finally {
      client.close(force: true);
    }
  }

  String _hostLabel(LanPairing pairing) =>
      pairing.deviceName.isEmpty ? 'the PC' : pairing.deviceName;
}
