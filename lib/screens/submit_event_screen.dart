import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';
import '../widgets/chip_select_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive.dart';

/// "Report an event" form: adds a community event to the list.
class SubmitEventScreen extends StatefulWidget {
  const SubmitEventScreen({super.key});

  @override
  State<SubmitEventScreen> createState() => _SubmitEventScreenState();
}

class _SubmitEventScreenState extends State<SubmitEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _organizer = TextEditingController();
  final _venue = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();
  final _price = TextEditingController(text: '0');
  final _capacity = TextEditingController();
  final _description = TextEditingController();
  final _link = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String _category = '';
  String _mode = '';
  String _area = '';
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _title, _organizer, _venue, _dateCtl, _timeCtl,
      _price, _capacity, _description, _link,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) {
      _date = d;
      _dateCtl.text = fmtDateLong(d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (t != null) {
      _time = t;
      final dt = DateTime(2000, 1, 1, t.hour, t.minute);
      _timeCtl.text = fmtTime(dt);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final start = DateTime(
        _date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
    final category =
        EventCategory.values.firstWhere((c) => c.label == _category);
    final mode = EventMode.values.firstWhere((m) => m.label == _mode);

    final event = TechEvent(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      organizer: _organizer.text.trim(),
      category: category,
      mode: mode,
      venue: _venue.text.trim(),
      area: mode == EventMode.online ? 'Online' : _area,
      start: start,
      end: start.add(const Duration(hours: 3)),
      price: int.parse(_price.text.trim()),
      capacity: int.parse(_capacity.text.trim()),
      registered: 0,
      description: _description.text.trim(),
      community: true,
      link: _link.text.trim().isEmpty ? null : _link.text.trim(),
    );

    context.read<EventsProvider>().addCommunityEvent(event);
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event submitted - it is now live in Events')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final pad = pagePadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit an event')),
      body: SingleChildScrollView(
        child: MaxWidth(
          maxWidth: 720,
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 56),
            child: FadeSlideIn(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TELL US ABOUT\nYOUR EVENT',
                        style: display(context, size: 32, height: 1)),
                    const SizedBox(height: 8),
                    Text('It appears in the Events list straight away.',
                        style: TextStyle(color: p.muted)),
                    const SizedBox(height: 26),
                    CustomTextField(
                      label: 'Event title',
                      icon: Icons.title_rounded,
                      controller: _title,
                      validator: Validators.minLength(5, 'Title'),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Organiser / community',
                      icon: Icons.groups_2_outlined,
                      controller: _organizer,
                      validator: Validators.minLength(2, 'Organiser'),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 22),
                    ChipSelectField(
                      label: 'Category',
                      options: [for (final c in EventCategory.values) c.label],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Pick a category' : null,
                      onChanged: (v) => _category = v,
                    ),
                    const SizedBox(height: 22),
                    ChipSelectField(
                      label: 'Format',
                      options: [for (final m in EventMode.values) m.label],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Pick a format' : null,
                      onChanged: (v) => setState(() => _mode = v),
                    ),
                    const SizedBox(height: 22),
                    if (_mode != EventMode.online.label) ...[
                      ChipSelectField(
                        label: 'Area in Hyderabad',
                        options: [for (final a in kAreas) if (a != 'Online') a],
                        validator: (v) => (_mode == EventMode.online.label ||
                                (v != null && v.isNotEmpty))
                            ? null
                            : 'Pick an area',
                        onChanged: (v) => _area = v,
                      ),
                      const SizedBox(height: 22),
                    ],
                    CustomTextField(
                      label: _mode == EventMode.online.label
                          ? 'Platform / meeting link name'
                          : 'Venue',
                      icon: Icons.place_outlined,
                      controller: _venue,
                      validator: Validators.minLength(3, 'Venue'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    TwoCol(
                      left: CustomTextField(
                        label: 'Date',
                        icon: Icons.calendar_today_outlined,
                        controller: _dateCtl,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (v) =>
                            Validators.required(v, 'Date'),
                      ),
                      right: CustomTextField(
                        label: 'Start time',
                        icon: Icons.schedule_rounded,
                        controller: _timeCtl,
                        readOnly: true,
                        onTap: _pickTime,
                        validator: (v) =>
                            Validators.required(v, 'Start time'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TwoCol(
                      left: CustomTextField(
                        label: 'Entry fee (₹, 0 = free)',
                        icon: Icons.sell_outlined,
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.integer(
                            label: 'Fee', min: 0, max: 100000),
                      ),
                      right: CustomTextField(
                        label: 'Capacity (seats)',
                        icon: Icons.event_seat_outlined,
                        controller: _capacity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: Validators.integer(
                            label: 'Capacity', min: 1, max: 5000),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      hint: 'What will people learn or build? (min 20 characters)',
                      controller: _description,
                      maxLines: 4,
                      validator: Validators.minLength(20, 'Description'),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Registration link (optional)',
                      icon: Icons.link_rounded,
                      controller: _link,
                      keyboardType: TextInputType.url,
                      validator: Validators.optionalUrl,
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      label: 'Submit event',
                      icon: Icons.send_rounded,
                      expand: true,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
