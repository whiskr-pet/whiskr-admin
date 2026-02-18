import 'package:w_dashboard/helpers/status_chip_type.dart';
import 'package:w_network_module/api_headers/api_headers.dart';
import 'package:w_network_module/network_manager/network_manager.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/services/service_type_service.dart';
import 'package:w_utils/storage_manager/storage_keys.dart';
import 'package:w_utils/storage_manager/storage_prefs_manager.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/appointments_models/wa_meta_appointments_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_orders_model.dart';
import 'package:wa_orders_appointments_module/models/orders_models/wa_meta_orders_model.dart';
import 'package:wa_orders_appointments_module/services/wa_appointments_service/wa_appointments_service.dart';
import 'package:wa_orders_appointments_module/services/wa_orders_service/wa_orders_service.dart';

import 'calendar_constants.dart';
import 'mappers/appointment_calendar_mapper.dart';
import 'mappers/order_calendar_mapper.dart';
import 'models/calendar_entry.dart';
import 'models/calendar_status_option.dart';

class CalendarRepository {
  CalendarRepository({
    WaOrdersService? ordersService,
    WaAppointmentsService? appointmentsService,
  }) : _ordersService = ordersService ?? WaOrdersService.instance,
       _appointmentsService =
           appointmentsService ?? WaAppointmentsService.instance;

  final WaOrdersService _ordersService;
  final WaAppointmentsService _appointmentsService;

  Future<bool> resolveIsShopType() => ServiceTypeService.getServiceType();

  Future<List<CalendarEntry>> fetchEntries({
    required bool isShop,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    return isShop
        ? _fetchOrderEntries(rangeStart: rangeStart, rangeEnd: rangeEnd)
        : _fetchAppointmentEntries(rangeStart: rangeStart, rangeEnd: rangeEnd);
  }

  Future<List<CalendarEntry>> _fetchOrderEntries({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    int page = 1;
    bool hasMore = true;
    final List<CalendarEntry> collected = <CalendarEntry>[];

    while (hasMore && page <= 10) {
      final ResponseModel<WaMetaOrdersModel> response = await _ordersService
          .getServiceOrders(page: page, pageSize: kCalendarFetchPageSize);
      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? 'Failed to load orders');
      }

      final WaMetaOrdersModel metaModel = response.data!;
      collected.addAll(
        metaModel.serviceOrders
            .map(OrderCalendarMapper.toEntry)
            .where(
              (CalendarEntry entry) =>
                  !(entry.end.isBefore(rangeStart) ||
                      entry.start.isAfter(rangeEnd)),
            ),
      );
      hasMore = metaModel.meta.hasMore;
      page += 1;
    }

    return collected;
  }

  Future<List<CalendarEntry>> _fetchAppointmentEntries({
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    int page = 1;
    bool hasMore = true;
    final List<CalendarEntry> collected = <CalendarEntry>[];

    while (hasMore && page <= 10) {
      final ResponseModel<WaMetaAppointmentsModel> response =
          await _appointmentsService.getServiceAppointments(
            page: page,
            pageSize: kCalendarFetchPageSize,
          );
      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? 'Failed to load appointments');
      }

      final WaMetaAppointmentsModel metaModel = response.data!;
      collected.addAll(
        metaModel.serviceAppointments
            .map(AppointmentCalendarMapper.toEntry)
            .where(
              (CalendarEntry entry) =>
                  !(entry.end.isBefore(rangeStart) ||
                      entry.start.isAfter(rangeEnd)),
            ),
      );

      hasMore = metaModel.meta.hasMore;
      page += 1;
    }

    return collected;
  }

  Future<CalendarEntry> updateStatus({
    required bool isShop,
    required CalendarEntry entry,
    required String statusKey,
  }) async {
    if (isShop) {
      final StatusChipType status = CalendarStatusResolver.toOrderBackendStatus(
        statusKey,
      );
      final ResponseModel<ServiceOrderModel> response = await _ordersService
          .updateOrderStatus(status, entry.id);
      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? 'Failed to update order status');
      }
      return OrderCalendarMapper.toEntry(response.data!);
    }

    final StatusChipType status =
        CalendarStatusResolver.toAppointmentBackendStatus(statusKey);
    final ResponseModel<WaAppointmentsModel> response =
        await _appointmentsService.updateAppointmentStatus(status, entry.id);
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.error ?? 'Failed to update appointment status');
    }

    return AppointmentCalendarMapper.toEntry(response.data!);
  }

  Future<CalendarEntry> createEntry({
    required bool isShop,
    required String title,
    required DateTime start,
    required DateTime end,
    required String statusKey,
    String? subtitle,
  }) async {
    final Map<String, String> headers = await _authorizedHeaders();
    final String path = isShop
        ? 'service-provider-dashboard/orders'
        : 'service-provider-dashboard/appointments';

    final dynamic response = await NetworkManager.instance.postRequest(
      path,
      headers: headers,
      data: <String, dynamic>{
        'title': title,
        'status': isShop
            ? CalendarStatusResolver.toOrderBackendStatus(statusKey).name
            : CalendarStatusResolver.toAppointmentBackendStatus(statusKey).name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        if (subtitle != null && subtitle.isNotEmpty) 'customer': subtitle,
        if (isShop) 'deliveryDate': start.toIso8601String(),
        if (!isShop) 'date': start.toIso8601String(),
      },
    );

    if (response == null || response.data == null) {
      throw Exception('Unable to create event.');
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(
      response.data as Map,
    );
    if (isShop) {
      return OrderCalendarMapper.toEntry(ServiceOrderModel.fromJson(map));
    }
    return AppointmentCalendarMapper.toEntry(WaAppointmentsModel.fromJson(map));
  }

  Future<CalendarEntry> updateEntry({
    required bool isShop,
    required CalendarEntry current,
    required String title,
    required DateTime start,
    required DateTime end,
    required String statusKey,
    String? subtitle,
  }) async {
    final Map<String, String> headers = await _authorizedHeaders();
    final String path = isShop
        ? 'service-provider-dashboard/orders/${current.id}'
        : 'service-provider-dashboard/appointments/${current.id}';

    final dynamic response = await NetworkManager.instance.putRequest(
      path,
      headers: headers,
      data: <String, dynamic>{
        'title': title,
        'status': isShop
            ? CalendarStatusResolver.toOrderBackendStatus(statusKey).name
            : CalendarStatusResolver.toAppointmentBackendStatus(statusKey).name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        if (subtitle != null && subtitle.isNotEmpty) 'customer': subtitle,
        if (isShop) 'deliveryDate': start.toIso8601String(),
        if (!isShop) ...<String, dynamic>{
          'date': start.toIso8601String(),
          'time':
              '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
        },
      },
    );

    if (response == null || response.data == null) {
      throw Exception('Unable to update event.');
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(
      response.data as Map,
    );
    if (isShop) {
      return OrderCalendarMapper.toEntry(ServiceOrderModel.fromJson(map));
    }

    return AppointmentCalendarMapper.toEntry(WaAppointmentsModel.fromJson(map));
  }

  Future<void> deleteEntry({required bool isShop, required String id}) async {
    final Map<String, String> headers = await _authorizedHeaders();
    final String path = isShop
        ? 'service-provider-dashboard/orders/$id'
        : 'service-provider-dashboard/appointments/$id';

    final dynamic response = await NetworkManager.instance.deleteRequest(
      path,
      headers: headers,
    );
    if (response == null) {
      throw Exception('Unable to delete event.');
    }
  }

  Future<void> rescheduleEntry({
    required bool isShop,
    required CalendarEntry entry,
    required DateTime newStart,
    required DateTime newEnd,
  }) async {
    final Map<String, String> headers = await _authorizedHeaders();
    final String path = isShop
        ? 'service-provider-dashboard/orders/${entry.id}'
        : 'service-provider-dashboard/appointments/${entry.id}';

    final dynamic response = await NetworkManager.instance.putRequest(
      path,
      headers: headers,
      data: <String, dynamic>{
        if (isShop) 'deliveryDate': newStart.toIso8601String(),
        if (!isShop) ...<String, dynamic>{
          'date': DateTime(
            newStart.year,
            newStart.month,
            newStart.day,
          ).toIso8601String(),
          'time':
              '${newStart.hour.toString().padLeft(2, '0')}:${newStart.minute.toString().padLeft(2, '0')}',
          'end': newEnd.toIso8601String(),
        },
      },
    );

    if (response == null) {
      throw Exception('Unable to reschedule event.');
    }
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final String token = await storagePrefs.getValue(StorageKeys.ACCESS_TOKEN);
    return ApiHeaderHelper.getValue(ApiHeader.authAppJson, token: token);
  }
}
