import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/registration.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';
import '../widgets/chip_select_field.dart';
import '../widgets/common.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/responsive.dart';

/// Event registration form (the app's main validated form).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController();
  final _org = TextEditingController();
  String _role = '';
  String _level = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _org.dispose();
    super.dispose();
  }

  Future<void> _submit(TechEvent event) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final reg = context.read<EventsProvider>().register(
          eventId: event.id,
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          organisation: _org.text,
          role: _role,
          level: _level,
        );
    setState(() => _loading = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(reg: reg, event: event),
    );
    // Dialog "Close" returns here; go back to the event page.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final ev = context.watch<EventsProvider>();
    final event = ev.byId(widget.eventId);
    final pad = pagePadding(context);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Event not found',
          message: 'We could not find this event.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        child: MaxWidth(
          maxWidth: 680,
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 48),
            child: FadeSlideIn(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // event summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: event.category.color.withAlpha(35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(event.category.icon,
                                color: event.category.tone(context)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  '${fmtDate(event.start)} · ${fmtTime(event.start)} · ${fmtPrice(event.price)}',
                                  style: TextStyle(color: p.muted, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('YOUR DETAILS', style: display(context, size: 22)),
                    const SizedBox(height: 4),
                    Text('We will send your ticket to this email.',
                        style: TextStyle(color: p.muted)),
                    const SizedBox(height: 22),

                    CustomTextField(
                      label: 'Full name',
                      icon: Icons.person_outline_rounded,
                      controller: _name,
                      validator: Validators.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TwoCol(
                      left: CustomTextField(
                        label: 'Email',
                        icon: Icons.mail_outline_rounded,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        textInputAction: TextInputAction.next,
                      ),
                      right: CustomTextField(
                        label: 'Phone (10 digits)',
                        icon: Icons.phone_outlined,
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'College / Company',
                      icon: Icons.apartment_rounded,
                      controller: _org,
                      validator: Validators.minLength(2, 'College / Company'),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 22),
                    ChipSelectField(
                      label: 'I am a',
                      options: const ['Student', 'Professional', 'Founder', 'Other'],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Please select one' : null,
                      onChanged: (v) => _role = v,
                    ),
                    const SizedBox(height: 22),
                    ChipSelectField(
                      label: 'Experience level',
                      options: const ['Beginner', 'Intermediate', 'Advanced'],
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Please select one' : null,
                      onChanged: (v) => _level = v,
                    ),
                    const SizedBox(height: 22),
                    FormField<bool>(
                      initialValue: false,
                      validator: (v) =>
                          v == true ? null : 'Please accept to continue',
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => state.didChange(!(state.value ?? false)),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: state.value ?? false,
                                  onChanged: (v) => state.didChange(v ?? false),
                                ),
                                Expanded(
                                  child: Text(
                                    'I agree to share these details with the organiser '
                                    'and follow the event code of conduct.',
                                    style: TextStyle(color: p.muted, fontSize: 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Confirm registration',
                      icon: Icons.check_rounded,
                      expand: true,
                      loading: _loading,
                      onPressed: () => _submit(event),
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

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.reg, required this.event});
  final Registration reg;
  final TechEvent event;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Dialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: p.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: Pal.lime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 42, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Text('YOU’RE IN', style: display(context, size: 28)),
              const SizedBox(height: 8),
              Text(
                'Registered for ${event.title}',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  children: [
                    Text('TICKET ID',
                        style: TextStyle(
                            color: p.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6)),
                    const SizedBox(height: 4),
                    Text(reg.ticketId,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AppButton(
                label: 'View my tickets',
                expand: true,
                onPressed: () {
                  final nav = Navigator.of(context, rootNavigator: true);
                  nav.pop(); // close the dialog first
                  nav.pushNamedAndRemoveUntil(Routes.home, (r) => false, arguments: 3);
                },
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: p.muted),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
