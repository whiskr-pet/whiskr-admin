// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:w_utils/responsive_web/responsive_web_helper.dart';
// import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
// import 'package:whiskr_admin_panel/l10n/app_localizations.dart';
// import 'package:whiskr_admin_panel/routing/routes.dart';
//
// class SettingsProfileScreen extends StatelessWidget {
//   const SettingsProfileScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final ThemeData themeData = Theme.of(context);
//     final ColorScheme colorScheme = themeData.colorScheme;
//     final AppLocalizations l10n = AppLocalizations.of(context)!;
//
//     final String? email = context.select<WAOnboardingProvider, String?>((WAOnboardingProvider p) => p.serviceAdminData.contact?.email);
//     final String? profileImageUrl = context.select<WAOnboardingProvider, String?>((WAOnboardingProvider p) => p.serviceAdminData.serviceProfileImage?.url);
//
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               vertical: 24,
//               horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 60.0, desktop: 120.0, widescreen: 200.0),
//             ),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 900),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       IconButton(
//                         onPressed: () => Navigator.of(context).maybePop(),
//                         icon: const Icon(Icons.arrow_back),
//                         tooltip: MaterialLocalizations.of(context).backButtonTooltip,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         l10n.settingsProfile,
//                         style: themeData.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: colorScheme.surface,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: <BoxShadow>[
//                         BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 4)),
//                       ],
//                     ),
//                     child: Row(
//                       children: <Widget>[
//                         CircleAvatar(
//                           radius: 28,
//                           backgroundColor: colorScheme.surfaceContainerHighest,
//                           backgroundImage: (profileImageUrl == null || profileImageUrl.isEmpty) ? null : NetworkImage(profileImageUrl),
//                           child: (profileImageUrl == null || profileImageUrl.isEmpty)
//                               ? Icon(Icons.person, color: themeData.colorScheme.onSurfaceVariant)
//                               : null,
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 email ?? '—',
//                                 style: themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Admin',
//                                 style: themeData.textTheme.bodySmall?.copyWith(color: themeData.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: colorScheme.surface,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: <BoxShadow>[
//                         BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 4)),
//                       ],
//                     ),
//                     child: Row(
//                       children: <Widget>[
//                         Expanded(
//                           child: Text(
//                             'Edit your business profile details, media, location, and working hours.',
//                             style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSurfaceVariant),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         FilledButton.icon(
//                           onPressed: () => context.go(settingsEditProfileRoute),
//                           icon: const Icon(Icons.edit_outlined),
//                           label: Text(l10n.settingsEditProfile),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
