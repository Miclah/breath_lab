import 'dart:convert';
import 'dart:math';

/// Why a scanned QR could not be turned into a [LanPairing].
enum LanPairingErrorReason {
  /// The string is not a BreathLab pairing URI at all — keep scanning, this
  /// is just some other QR code in frame.
  notBreathLab,

  /// A BreathLab pairing URI whose version this app does not understand.
  unsupportedVersion,

  /// A BreathLab pairing URI of a known version with missing or invalid
  /// fields — show the user an error, do not silently ignore it.
  malformed,
}

class LanPairingException implements Exception {
  const LanPairingException(this.reason, this.message);

  final LanPairingErrorReason reason;
  final String message;

  @override
  String toString() => 'LanPairingException($reason): $message';
}

/// Everything the Android client needs to reach the Windows host and prove it
/// was invited: the host's candidate LAN addresses, the port its `HttpServer`
/// is on, a one-shot bearer token, and the host's device name for the summary.
///
/// Carried between the two devices as a `breathlab-sync://v1?…` URI inside a
/// QR code. Nothing here is a secret worth protecting beyond the exchange
/// window — the token authorises exactly one successful `POST /sync`, after
/// which the host stops listening.
class LanPairing {
  const LanPairing({
    required this.hosts,
    required this.port,
    required this.token,
    required this.deviceName,
  });

  /// Non-loopback IPv4 addresses the host is reachable at. More than one
  /// because a Windows box routinely has Ethernet, Wi-Fi and virtual-adapter
  /// addresses and only the client can tell which it can actually reach — so
  /// it tries each in turn.
  final List<String> hosts;

  final int port;

  /// 256 bits of `Random.secure()`, base64url without padding.
  final String token;

  final String deviceName;

  static const _scheme = 'breathlab-sync';
  static const _version = 'v1';
  static final _ipv4 = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
  static final _tokenChars = RegExp(r'^[A-Za-z0-9_-]+$');

  /// Mint a pairing for [hosts]/[port], with a fresh random token.
  factory LanPairing.mint({
    required List<String> hosts,
    required int port,
    required String deviceName,
  }) {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return LanPairing(
      hosts: hosts,
      port: port,
      token: base64Url.encode(bytes).replaceAll('=', ''),
      deviceName: deviceName,
    );
  }

  static final _random = Random.secure();

  String encode() {
    final query = {
      'h': hosts.join(','),
      'p': '$port',
      't': token,
      'n': deviceName,
    };
    final pairs = query.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$_scheme://$_version?$pairs';
  }

  static LanPairing decode(String raw) {
    final Uri uri;
    try {
      uri = Uri.parse(raw.trim());
    } on FormatException {
      throw const LanPairingException(
        LanPairingErrorReason.notBreathLab,
        'Not a BreathLab pairing code.',
      );
    }

    if (uri.scheme != _scheme) {
      throw const LanPairingException(
        LanPairingErrorReason.notBreathLab,
        'Not a BreathLab pairing code.',
      );
    }
    if (uri.host != _version) {
      throw const LanPairingException(
        LanPairingErrorReason.unsupportedVersion,
        'This pairing code is from a different version of BreathLab.',
      );
    }

    final q = uri.queryParameters;
    final hosts = (q['h'] ?? '')
        .split(',')
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .toList();
    if (hosts.isEmpty || !hosts.every(_isIpv4)) {
      throw const LanPairingException(
        LanPairingErrorReason.malformed,
        'The pairing code is missing a valid address.',
      );
    }

    final port = int.tryParse(q['p'] ?? '');
    if (port == null || port < 1 || port > 65535) {
      throw const LanPairingException(
        LanPairingErrorReason.malformed,
        'The pairing code has an invalid port.',
      );
    }

    final token = q['t'] ?? '';
    if (token.isEmpty || !_tokenChars.hasMatch(token)) {
      throw const LanPairingException(
        LanPairingErrorReason.malformed,
        'The pairing code has an invalid token.',
      );
    }

    return LanPairing(
      hosts: hosts,
      port: port,
      token: token,
      deviceName: q['n'] ?? '',
    );
  }

  static bool _isIpv4(String s) {
    final m = _ipv4.firstMatch(s);
    if (m == null) return false;
    for (var i = 1; i <= 4; i++) {
      final octet = int.parse(m.group(i)!);
      if (octet > 255) return false;
    }
    return true;
  }

  Uri baseUriFor(String host) => Uri.parse('http://$host:$port');
}
