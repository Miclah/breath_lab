import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../tables/providers.dart' show pipServiceProvider, isInPipModeProvider;
import 'providers.dart';

/// Invisible widget that tells native whether entering picture-in-picture
/// is currently allowed (active hold + ambient PiP setting), and wires PiP
/// mode changes back into [isInPipModeProvider]. Mount once in the Timer
/// screen's widget tree — renders nothing.
class PipController extends ConsumerStatefulWidget {
  const PipController({super.key});

  @override
  ConsumerState<PipController> createState() => _PipControllerState();
}

class _PipControllerState extends ConsumerState<PipController> {
  bool? _lastAllowed;

  @override
  void initState() {
    super.initState();
    ref.read(pipServiceProvider).onModeChanged = (isInPipMode) {
      ref.read(isInPipModeProvider.notifier).state = isInPipMode;
    };
  }

  @override
  Widget build(BuildContext context) {
    final isHolding = ref.watch(timerProvider).isHolding;
    final pipEnabled = ref.watch(ambientPipEnabledProvider).valueOrNull ?? true;
    final shouldAllow = isHolding && pipEnabled;

    if (shouldAllow != _lastAllowed) {
      _lastAllowed = shouldAllow;
      ref.read(pipServiceProvider).setEnabled(shouldAllow);
    }

    return const SizedBox.shrink();
  }
}
