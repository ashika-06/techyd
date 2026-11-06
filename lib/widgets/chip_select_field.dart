import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_chip.dart';

/// A validated "pick one" field rendered as chips (works inside a Form).
class ChipSelectField extends FormField<String> {
  ChipSelectField({
    super.key,
    required String label,
    required List<String> options,
    String? initialValue,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) : super(
          initialValue: initialValue,
          validator: validator,
          builder: (state) {
            final p = Pal.of(state.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in options)
                      AppChip(
                        label: o,
                        selected: state.value == o,
                        onTap: () {
                          state.didChange(o);
                          onChanged?.call(o);
                        },
                      ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
