import 'package:flutter/material.dart';
import '../theme/wingnut_theme.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool Function(String pin) onVerify;

  const PinDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onVerify,
  });

  /// Show the dialog and return true if PIN was accepted
  static Future<bool> show(
      BuildContext context, {
        String title = 'Enter PIN',
        String subtitle = 'Enter the 4-digit admin PIN to continue.',
        required bool Function(String pin) onVerify,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(
        title: title,
        subtitle: subtitle,
        onVerify: onVerify,
      ),
    );
    return result ?? false;
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final List<String> _digits = [];
  bool _shake = false;

  void _onDigit(String d) {
    if (_digits.length >= 4) return;
    setState(() => _digits.add(d));
    if (_digits.length == 4) _verify();
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _verify() async {
    final pin = _digits.join();
    if (widget.onVerify(pin)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _shake = true;
        _digits.clear();
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _shake = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline,
                color: WingnutTheme.violet, size: 36),
            const SizedBox(height: 12),
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: WingnutTheme.textSecondary)),
            const SizedBox(height: 28),

            // PIN dots
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: _shake
                  ? (Matrix4.translationValues(8, 0, 0))
                  : Matrix4.identity(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _digits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? WingnutTheme.violet
                          : WingnutTheme.border,
                      border: Border.all(
                        color: filled
                            ? WingnutTheme.violet
                            : WingnutTheme.textSecondary,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 28),

            // Number pad
            ..._buildPad(),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: WingnutTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPad() {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return rows.map((row) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((label) {
            if (label.isEmpty) return const SizedBox(width: 72);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 72,
                height: 52,
                child: Material(
                  color: label == '⌫'
                      ? WingnutTheme.border
                      : WingnutTheme.violetLight,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () =>
                    label == '⌫' ? _onDelete() : _onDigit(label),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: label == '⌫' ? 18 : 22,
                          fontWeight: FontWeight.w600,
                          color: label == '⌫'
                              ? WingnutTheme.textSecondary
                              : WingnutTheme.violetDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }
}