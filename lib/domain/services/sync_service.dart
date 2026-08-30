import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/db/app_database.dart' as db;
import '../../data/db/database_provider.dart';
import '../../data/repositories/sync_repository.dart';
import '../models/sync_payload.dart';
import 'sync_merge_service.dart';

const _typeGroup = XTypeGroup(label: 'BreathLab backup', extensions: ['blab']);

/// Result of a completed import: how the merge changed the local database,
/// and who the other side was — feeds the post-import summary sheet.
class SyncImportSummary {
  const SyncImportSummary({required this.counts, required this.peerDeviceName});

  final MergeCounts counts;
  final String peerDeviceName;
}

String _suggestedFileName() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'breathlab-${now.year}-${two(now.month)}-${two(now.day)}.blab';
}

/// Orchestrates the file side of sync: builds/writes the `.blab` payload
/// via [SyncRepository], and hands it to native save/share/open dialogs.
/// Doubles as backup/restore — an import into a fresh install is just a
/// merge into an empty local payload.
class SyncService {
  SyncService({
    required this._syncRepo,
    required db.AppDatabase database,
    required this.appVersion,
  }) : _db = database;

  final SyncRepository _syncRepo;
  final db.AppDatabase _db;
  final String appVersion;

  Future<Uint8List> _buildExportBytes() async {
    final payload = await _syncRepo.buildLocalPayload(appVersion: appVersion);
    return Uint8List.fromList(utf8.encode(payload.encode()));
  }

  /// Opens a native save dialog and writes the export there. Returns the
  /// saved path, or null if the user canceled.
  Future<String?> exportToFile() async {
    final fileName = _suggestedFileName();
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: const [_typeGroup],
    );
    if (location == null) return null;

    final bytes = await _buildExportBytes();
    final file = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: fileName,
    );
    await file.saveTo(location.path);
    return location.path;
  }

  /// Android-only: hands the export straight to the share sheet, so
  /// "send to my PC" is one tap without a save dialog first.
  Future<void> shareExport() async {
    final bytes = await _buildExportBytes();
    final file = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: _suggestedFileName(),
    );
    await SharePlus.instance.share(ShareParams(files: [file]));
  }

  /// Reads, validates, merges, and applies a `.blab` file. Returns null if
  /// the user canceled the file picker. Throws [SyncPayloadException] for
  /// any other failure — wrong format, newer schema, corrupt JSON — never
  /// a raw exception, and never a partial write.
  Future<SyncImportSummary?> importFromFile() async {
    final picked = await openFile(acceptedTypeGroups: const [_typeGroup]);
    if (picked == null) return null;

    final content = await picked.readAsString();
    return applyRemotePayload(SyncPayload.decode(content));
  }

  /// The shared tail of every inbound sync — file import and LAN sync both
  /// end here: schema-check the remote payload, merge it against the local
  /// one, apply the result in a single transaction, and report what changed.
  /// Older data never overwrites newer, so this is safe to call without a
  /// confirmation step.
  Future<SyncImportSummary> applyRemotePayload(SyncPayload remote) async {
    if (remote.schemaVersion > _db.schemaVersion) {
      throw const SyncPayloadException(
        SyncPayloadErrorReason.newerSchema,
        'This data was exported by a newer version of BreathLab. '
        'Update the app on this device first.',
      );
    }

    final local = await _syncRepo.buildLocalPayload(appVersion: appVersion);
    final result = SyncMergeService.merge(local: local, remote: remote);
    await _syncRepo.applyMerge(
      result: result,
      peerDeviceName: remote.deviceName,
    );

    return SyncImportSummary(
      counts: result.counts,
      peerDeviceName: remote.deviceName,
    );
  }

  /// This device's current state as a payload, for handing to a sync peer.
  Future<SyncPayload> buildLocalPayload() =>
      _syncRepo.buildLocalPayload(appVersion: appVersion);
}

final syncServiceProvider = FutureProvider<SyncService>((ref) async {
  final syncRepo = await ref.watch(syncRepositoryProvider.future);
  final database = ref.watch(databaseProvider);
  final packageInfo = await PackageInfo.fromPlatform();
  return SyncService(
    syncRepo: syncRepo,
    database: database,
    appVersion: packageInfo.version,
  );
});
