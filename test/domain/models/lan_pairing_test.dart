import 'package:breath_lab/domain/models/lan_pairing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanPairing.mint', () {
    test('produces a base64url token of at least 43 chars and no padding', () {
      final p = LanPairing.mint(
        hosts: ['192.168.1.5'],
        port: 50000,
        deviceName: 'PC',
      );
      expect(p.token, isNot(contains('=')));
      expect(p.token.length, greaterThanOrEqualTo(43));
      expect(RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(p.token), isTrue);
    });

    test('two mints do not collide', () {
      final a = LanPairing.mint(hosts: ['10.0.0.1'], port: 1, deviceName: '');
      final b = LanPairing.mint(hosts: ['10.0.0.1'], port: 1, deviceName: '');
      expect(a.token, isNot(b.token));
    });
  });

  group('encode / decode round trip', () {
    test(
      'carries every field, including a name with spaces and punctuation',
      () {
        final original = LanPairing(
          hosts: ['192.168.1.5', '172.20.10.2', '10.5.0.9'],
          port: 54213,
          token: 'abc-123_XYZ',
          deviceName: "Michal's Laptop (Wi-Fi)",
        );
        final decoded = LanPairing.decode(original.encode());

        expect(decoded.hosts, original.hosts);
        expect(decoded.port, original.port);
        expect(decoded.token, original.token);
        expect(decoded.deviceName, original.deviceName);
      },
    );

    test('an empty device name survives', () {
      final decoded = LanPairing.decode(
        LanPairing(
          hosts: ['10.0.0.2'],
          port: 8080,
          token: 't0ken',
          deviceName: '',
        ).encode(),
      );
      expect(decoded.deviceName, isEmpty);
    });
  });

  group('decode rejects', () {
    void expectReason(String raw, LanPairingErrorReason reason) {
      expect(
        () => LanPairing.decode(raw),
        throwsA(
          isA<LanPairingException>().having((e) => e.reason, 'reason', reason),
        ),
      );
    }

    test('a plain URL as notBreathLab', () {
      expectReason('https://example.com', LanPairingErrorReason.notBreathLab);
    });

    test('random text as notBreathLab', () {
      expectReason('just some text', LanPairingErrorReason.notBreathLab);
    });

    test('a future protocol version as unsupportedVersion', () {
      expectReason(
        'breathlab-sync://v2?h=10.0.0.1&p=5&t=x&n=PC',
        LanPairingErrorReason.unsupportedVersion,
      );
    });

    test('no host as malformed', () {
      expectReason(
        'breathlab-sync://v1?p=5000&t=x&n=PC',
        LanPairingErrorReason.malformed,
      );
    });

    test('a non-IPv4 host as malformed', () {
      expectReason(
        'breathlab-sync://v1?h=my-pc.local&p=5000&t=x',
        LanPairingErrorReason.malformed,
      );
    });

    test('an out-of-range octet as malformed', () {
      expectReason(
        'breathlab-sync://v1?h=192.168.1.999&p=5000&t=x',
        LanPairingErrorReason.malformed,
      );
    });

    test('port 0 and port 70000 as malformed', () {
      expectReason(
        'breathlab-sync://v1?h=10.0.0.1&p=0&t=x',
        LanPairingErrorReason.malformed,
      );
      expectReason(
        'breathlab-sync://v1?h=10.0.0.1&p=70000&t=x',
        LanPairingErrorReason.malformed,
      );
    });

    test('an empty or non-base64url token as malformed', () {
      expectReason(
        'breathlab-sync://v1?h=10.0.0.1&p=5000&t=',
        LanPairingErrorReason.malformed,
      );
      expectReason(
        'breathlab-sync://v1?h=10.0.0.1&p=5000&t=has%20space',
        LanPairingErrorReason.malformed,
      );
    });
  });

  test('baseUriFor builds a plain http origin', () {
    final p = LanPairing(
      hosts: ['192.168.1.5'],
      port: 54213,
      token: 'x',
      deviceName: '',
    );
    expect(p.baseUriFor('192.168.1.5').toString(), 'http://192.168.1.5:54213');
  });
}
