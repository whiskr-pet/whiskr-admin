import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:wa_orders_appointments_module/providers/appointments_providers/wa_appointments_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
// Syncfusion calendar is used because it supports month/week/day + drag/drop + resize on web.
import 'package:syncfusion_flutter_calendar/calendar.dart' as sf;

import '../../app/screens/orders_and_appointments_screen/widgets/appointments_details_sheet.dart';
import '../../app/screens/orders_and_appointments_screen/widgets/orders_details_sheet.dart';
import '../../routing/routes.dart';
import '../../widgets/wa_slide_panel.dart';
import 'calendar_provider.dart';
import 'models/calendar_entry.dart';
import 'models/calendar_filters.dart';
import 'models/calendar_status_option.dart';
import 'models/calendar_view_type.dart';
import 'widgets/calendar_data_source.dart';
import 'widgets/calendar_entry_form_dialog.dart';
import 'widgets/calendar_filters_panel.dart';
import 'widgets/calendar_toolbar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final sf.CalendarController _calendarController = sf.CalendarController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Selector<CalendarProvider, _FilterPanelVm>(
        selector: (_, CalendarProvider provider) => _FilterPanelVm(
          filters: provider.filters,
          statusOptions: provider.statusOptions,
          serviceTypes: provider.availableServiceTypes,
          resources: provider.availableResources,
        ),
        builder: (BuildContext context, _FilterPanelVm vm, Widget? child) {
          return CalendarFiltersPanel(
            filters: vm.filters,
            statusOptions: vm.statusOptions,
            serviceTypes: vm.serviceTypes,
            resources: vm.resources,
            onToggleStatus: context.read<CalendarProvider>().toggleStatusFilter,
            onToggleServiceType: context
                .read<CalendarProvider>()
                .toggleServiceTypeFilter,
            onToggleResource: context
                .read<CalendarProvider>()
                .toggleStaffResourceFilter,
            onApplyQuickRange: (CalendarQuickRange range) =>
                context.read<CalendarProvider>().applyQuickRange(range),
            onClear: context.read<CalendarProvider>().clearFilters,
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Selector<CalendarProvider, _ToolbarVm>(
              selector: (_, CalendarProvider provider) => _ToolbarVm(
                viewType: provider.viewType,
                focusedDate: provider.focusedDate,
              ),
              builder: (BuildContext context, _ToolbarVm vm, Widget? child) {
                return CalendarToolbar(
                  periodLabel: _periodLabel(vm.focusedDate, vm.viewType),
                  currentView: vm.viewType,
                  onToday: () async {
                    await context.read<CalendarProvider>().goToToday();
                    _calendarController.displayDate = context
                        .read<CalendarProvider>()
                        .focusedDate;
                  },
                  onPrevious: () async {
                    await context.read<CalendarProvider>().goToPreviousPeriod();
                    _calendarController.displayDate = context
                        .read<CalendarProvider>()
                        .focusedDate;
                  },
                  onNext: () async {
                    await context.read<CalendarProvider>().goToNextPeriod();
                    _calendarController.displayDate = context
                        .read<CalendarProvider>()
                        .focusedDate;
                  },
                  onViewChanged: (CalendarViewType value) async {
                    await context.read<CalendarProvider>().setViewType(value);
                    _calendarController.view = _toSfView(value);
                  },
                  onSearchChanged: context
                      .read<CalendarProvider>()
                      .setSearchQuery,
                  onOpenFilters: () =>
                      _scaffoldKey.currentState?.openEndDrawer(),
                  onCreate: () => _openEventEditor(context),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<CalendarProvider>(
                builder:
                    (
                      BuildContext context,
                      CalendarProvider provider,
                      Widget? child,
                    ) {
                      if (provider.isLoading && provider.entries.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null &&
                          provider.entries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                provider.errorMessage!,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: provider.fetchEntries,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.filteredEntries.isEmpty) {
                        return _buildEmptyState(context, provider);
                      }

                      final CalendarEntriesDataSource source =
                          CalendarEntriesDataSource(
                            entries: provider.filteredEntries,
                            colorForStatus: (String status) =>
                                CalendarStatusPalette.colorForStatus(
                                  context,
                                  status,
                                ),
                          );

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: sf.SfCalendar(
                          key: const Key('calendar_sf_widget'),
                          controller: _calendarController,
                          view: _toSfView(provider.viewType),
                          dataSource: source,
                          allowDragAndDrop: true,
                          allowAppointmentResize: true,
                          showNavigationArrow: false,
                          todayHighlightColor: theme.colorScheme.primary,
                          monthViewSettings: const sf.MonthViewSettings(
                            showAgenda: false,
                            appointmentDisplayMode:
                                sf.MonthAppointmentDisplayMode.appointment,
                          ),
                          onViewChanged: (sf.ViewChangedDetails details) {
                            if (details.visibleDates.isEmpty) {
                              return;
                            }
                            final int focusIndex =
                                (details.visibleDates.length / 2).floor();
                            provider.updateVisibleRange(
                              details.visibleDates.first,
                              details.visibleDates.last,
                              focusedDate: details.visibleDates[focusIndex],
                            );
                          },
                          onTap: (sf.CalendarTapDetails details) {
                            final Object? appointment =
                                details.appointments?.isNotEmpty == true
                                ? details.appointments!.first
                                : null;
                            final CalendarEntry? entry = source
                                .entryFromAppointment(appointment);
                            if (entry != null) {
                              _openSourceDetails(context, entry);
                            }
                          },
                          onDragEnd: (sf.AppointmentDragEndDetails details) {
                            final CalendarEntry? entry = source
                                .entryFromAppointment(details.appointment);
                            final DateTime? dropTime = details.droppingTime;
                            if (entry == null || dropTime == null) {
                              return;
                            }
                            final Duration duration = entry.end.difference(
                              entry.start,
                            );
                            context
                                .read<CalendarProvider>()
                                .rescheduleEntry(
                                  entry: entry,
                                  newStart: dropTime,
                                  newEnd: dropTime.add(duration),
                                )
                                .then((CalendarActionResult value) {
                                  _showResult(context, value);
                                });
                          },
                          onAppointmentResizeEnd:
                              (sf.AppointmentResizeEndDetails details) {
                                final CalendarEntry? entry = source
                                    .entryFromAppointment(details.appointment);
                                final DateTime? startTime = details.startTime;
                                final DateTime? endTime = details.endTime;
                                if (entry == null ||
                                    startTime == null ||
                                    endTime == null ||
                                    !endTime.isAfter(startTime)) {
                                  return;
                                }
                                context
                                    .read<CalendarProvider>()
                                    .rescheduleEntry(
                                      entry: entry,
                                      newStart: startTime,
                                      newEnd: endTime,
                                    )
                                    .then((CalendarActionResult value) {
                                      _showResult(context, value);
                                    });
                              },
                          appointmentBuilder:
                              (
                                BuildContext context,
                                sf.CalendarAppointmentDetails details,
                              ) {
                                final sf.Appointment appointment =
                                    details.appointments.first
                                        as sf.Appointment;
                                return Tooltip(
                                  message:
                                      '${DateFormat('HH:mm').format(appointment.startTime)} - ${appointment.subject}',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: appointment.color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '${DateFormat('HH:mm').format(appointment.startTime)} ${appointment.subject}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                );
                              },
                        ),
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEventEditor(
    BuildContext context, {
    CalendarEntry? initial,
  }) async {
    final CalendarProvider provider = context.read<CalendarProvider>();
    final List<CalendarStatusOption> statusOptions = provider.statusOptions;
    final CalendarEntryFormData? data = await CalendarEntryFormDialog.show(
      context,
      initial: initial,
      statusOptions: statusOptions,
    );

    if (!mounted || data == null) {
      return;
    }

    final CalendarActionResult result = initial == null
        ? await provider.createEntry(
            title: data.title,
            start: data.start,
            end: data.end,
            statusKey: data.statusKey,
            subtitle: data.subtitle,
          )
        : await provider.editEntry(
            current: initial,
            title: data.title,
            start: data.start,
            end: data.end,
            statusKey: data.statusKey,
            subtitle: data.subtitle,
          );

    if (!mounted) {
      return;
    }
    _showResult(context, result);
  }

  Future<void> _openSourceDetails(
    BuildContext context,
    CalendarEntry entry,
  ) async {
    if (entry.sourceType == CalendarEntrySourceType.order) {
      final dynamic source = entry.metadata['source'];
      if (source is ServiceOrderModel) {
        context.read<WaOrdersProvider>().setOrderDetails(source);
        await showWASlidePanel(
          context: context,
          child: const OrderDetailsSheet(),
        );
      } else {
        context.go(ordersRoute);
      }
    } else {
      final dynamic source = entry.metadata['source'];
      if (source is WaAppointmentsModel) {
        context.read<WaAppointmentsProvider>().setAppointmentDetails(source);
        await showWASlidePanel(
          context: context,
          child: const AppointmentDetailsSheet(),
        );
      } else {
        context.go(ordersRoute);
      }
    }

    if (!mounted) {
      return;
    }
    await context.read<CalendarProvider>().fetchEntries();
  }

  Widget _buildEmptyState(BuildContext context, CalendarProvider provider) {
    final ThemeData theme = Theme.of(context);
    final IconData icon;
    final String title;
    final String subtitle;

    switch (provider.viewType) {
      case CalendarViewType.month:
        icon = Icons.calendar_month_outlined;
        title = 'No events this month';
        subtitle =
            'This month is clear. Add a new order/appointment or jump to another period.';
        break;
      case CalendarViewType.week:
        icon = Icons.date_range_outlined;
        title = 'No events this week';
        subtitle =
            'Nothing is scheduled for this week. Use filters or create a new event.';
        break;
      case CalendarViewType.day:
        icon = Icons.event_busy_outlined;
        title = 'No events this day';
        subtitle = 'Your day is open. Create an event or go to today.';
        break;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () async {
                        await provider.goToToday();
                        if (!mounted) {
                          return;
                        }
                        _calendarController.displayDate = provider.focusedDate;
                      },
                      icon: const Icon(Icons.today),
                      label: const Text('Go to today'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openEventEditor(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create event'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, CalendarActionResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message ?? (result.isSuccess ? 'Success' : 'Action failed'),
        ),
        backgroundColor: result.isSuccess
            ? null
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _periodLabel(DateTime focusedDate, CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.month:
        return DateFormat('MMMM yyyy').format(focusedDate);
      case CalendarViewType.week:
        final DateTime start = focusedDate.subtract(
          Duration(days: focusedDate.weekday - 1),
        );
        final DateTime end = start.add(const Duration(days: 6));
        return '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
      case CalendarViewType.day:
        return DateFormat('EEE, d MMM yyyy').format(focusedDate);
    }
  }

  sf.CalendarView _toSfView(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.month:
        return sf.CalendarView.month;
      case CalendarViewType.week:
        return sf.CalendarView.week;
      case CalendarViewType.day:
        return sf.CalendarView.day;
    }
  }
}

class _ToolbarVm {
  const _ToolbarVm({required this.viewType, required this.focusedDate});

  final CalendarViewType viewType;
  final DateTime focusedDate;
}

class _FilterPanelVm {
  const _FilterPanelVm({
    required this.filters,
    required this.statusOptions,
    required this.serviceTypes,
    required this.resources,
  });

  final CalendarFilters filters;
  final List<CalendarStatusOption> statusOptions;
  final Set<String> serviceTypes;
  final Set<String> resources;
}
