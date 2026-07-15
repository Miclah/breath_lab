import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../domain/models/table_session.dart';

/// Type filter for the History screen. Standalone max holds vs. the two
/// table session types.
enum HistoryTypeFilter { max, co2, o2 }

/// Selected type filters. Empty means no restriction (show every type) --
/// each chip narrows the list further once selected.
final historyTypeFilterProvider = StateProvider<Set<HistoryTypeFilter>>(
  (ref) => {},
);

/// Selected lung volume filters. Empty means no restriction.
final historyLungVolumeFilterProvider = StateProvider<Set<LungVolume>>(
  (ref) => {},
);

/// Selected tag id filters. Empty means no restriction.
final historyTagFilterProvider = StateProvider<Set<String>>((ref) => {});

/// True if [hold] passes the type/lung-volume/tag filters. Filters combine
/// with AND; an empty filter set never excludes anything.
bool holdMatchesHistoryFilters(
  Hold hold, {
  required Set<HistoryTypeFilter> types,
  required Set<LungVolume> lungVolumes,
  required Set<String> tagFilter,
  required Set<String> holdTagIds,
}) {
  if (types.isNotEmpty && !types.contains(HistoryTypeFilter.max)) {
    return false;
  }
  if (lungVolumes.isNotEmpty && !lungVolumes.contains(hold.lungVolume)) {
    return false;
  }
  if (tagFilter.isNotEmpty && !tagFilter.any(holdTagIds.contains)) {
    return false;
  }
  return true;
}

/// True if [session] passes the type filter. Table sessions have no tags
/// or lung volume, so only the type filter applies to them.
bool tableSessionMatchesHistoryFilters(
  TableSession session,
  Set<HistoryTypeFilter> types,
) {
  if (types.isEmpty) return true;
  final filterType = session.type == TableType.co2
      ? HistoryTypeFilter.co2
      : HistoryTypeFilter.o2;
  return types.contains(filterType);
}
