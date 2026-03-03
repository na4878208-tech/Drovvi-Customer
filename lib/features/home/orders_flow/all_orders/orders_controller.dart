// lib/features/orders/controllers/order_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/get_all_orders_modal.dart';
import 'package:logisticscustomer/features/home/orders_flow/all_orders/orders_repo.dart';

class OrderController extends StateNotifier<OrderState> {
  final OrderRepository repository;

  OrderController(this.repository) : super(OrderState());

  /// ================= LOAD INITIAL =================
  Future<void> loadOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await repository.getAllOrders();

      state = state.copyWith(
        orders: response.data,
        meta: response.pagination,
        isLoading: false,
        currentPage: 1,
        currentFilter: 'All',
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// ================= LOAD MORE (PAGINATION) =================
  Future<void> loadMoreOrders() async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.meta.lastPage) return;

    try {
      state = state.copyWith(isLoadingMore: true);

      final nextPage = state.currentPage + 1;

      final response = state.currentFilter == 'All'
          ? await repository.getAllOrders(page: nextPage)
          : await repository.getOrdersByStatus(
              state.currentFilter,
              page: nextPage,
            );

      state = state.copyWith(
        orders: [...state.orders, ...response.data],
        meta: response.pagination,
        currentPage: nextPage,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// ================= FILTER =================
  Future<void> filterByStatus(String status) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentFilter: status,
      );

      if (status == 'All') {
        await loadOrders();
        return;
      }

      final response = await repository.getOrdersByStatus(status);

      state = state.copyWith(
        orders: response.data,
        meta: response.pagination,
        isLoading: false,
        currentPage: 1,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// ================= REFRESH =================
  Future<void> refreshOrders() async {
    if (state.currentFilter == 'All') {
      await loadOrders();
    } else {
      await filterByStatus(state.currentFilter);
    }
  }
}

/// ================= STATE =================
class OrderState {
  final List<AlOrder> orders;
  final AlMeta  meta;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final String currentFilter;

  const OrderState({
    this.orders = const [],
    this.meta = const AlMeta(
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 0,
    ),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.currentFilter = 'All',
  });

  OrderState copyWith({
    List<AlOrder>? orders,
    AlMeta? meta,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    String? currentFilter,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      meta: meta ?? this.meta,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

/// ================= PROVIDER =================
final orderControllerProvider =
    StateNotifierProvider<OrderController, OrderState>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderController(repo);
});