import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, _) {
        final order = ordersProvider.currentOrder;

        if (ordersProvider.isLoading || order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Buyurtma')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final statusInfo = _getStatusInfo(order.status);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              'Buyurtma ${order.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Status Card
                _buildStatusCard(order, statusInfo),

                const SizedBox(height: 16),

                // Timeline
                _buildTimeline(order.status),

                const SizedBox(height: 16),

                // Products
                _buildProductsSection(order),

                const SizedBox(height: 16),

                // Address
                _buildAddressSection(order),

                const SizedBox(height: 16),

                // Payment Summary
                _buildPaymentSummary(order),

                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet: order.status == OrderStatus.pending ||
                  order.status == OrderStatus.confirmed
              ? _buildBottomActions(order)
              : null,
        );
      },
    );
  }

  Widget _buildStatusCard(OrderModel order, Map<String, dynamic> statusInfo) {
    final formattedDate =
        '${order.createdAt.day}.${order.createdAt.month.toString().padLeft(2, '0')}.${order.createdAt.year}';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: statusInfo['color'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo['icon'],
              color: statusInfo['color'],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // Status text
          Text(
            statusInfo['text'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusInfo['color'],
            ),
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            formattedDate,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderStatus currentStatus) {
    final steps = [
      {
        'status': OrderStatus.pending,
        'label': 'Kutilmoqda',
        'icon': Iconsax.clock
      },
      {
        'status': OrderStatus.confirmed,
        'label': 'Tasdiqlandi',
        'icon': Iconsax.tick_square
      },
      {
        'status': OrderStatus.processing,
        'label': 'Tayyorlanmoqda',
        'icon': Iconsax.box_tick
      },
      {
        'status': OrderStatus.shipping,
        'label': 'Yo\'lda',
        'icon': Iconsax.truck_fast
      },
      {
        'status': OrderStatus.delivered,
        'label': 'Yetkazildi',
        'icon': Iconsax.tick_circle
      },
    ];

    final currentIndex = steps.indexWhere((s) => s['status'] == currentStatus);
    final isCancelled = currentStatus == OrderStatus.cancelled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buyurtma holati',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (isCancelled)
            Center(
              child: Column(
                children: [
                  Icon(
                    Iconsax.close_circle,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buyurtma bekor qilindi',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index <= currentIndex;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          color:
                              isCompleted ? Colors.white : Colors.grey.shade400,
                          size: 16,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted
                              ? AppColors.primary
                              : Colors.grey.shade200,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        step['label'] as String,
                        style: TextStyle(
                          fontWeight:
                              isCompleted ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isCompleted ? Colors.black : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProductsSection(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mahsulotlar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order.items.length} ta',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.productImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Iconsax.box,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.box,
                    color: Colors.grey.shade400,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${_formatPrice(item.price.toInt())} ${AppStrings.currency}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatPrice(item.total.toInt())} ${AppStrings.currency}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order) {
    // AddressesProvider orqali haqiqiy manzilni olish
    final addressesProvider = context.read<AddressesProvider>();
    final address = order.addressId != null
        ? addressesProvider.addresses.cast<AddressModel?>().firstWhere(
              (a) => a!.id == order.addressId,
              orElse: () => null,
            )
        : null;

    final addressTitle = address?.title ?? 'Manzil';
    final addressText = address?.address ?? 'Manzil topilmadi';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yetkazib berish manzili',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.location,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addressText,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (address?.apartment != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Kvartira: ${address!.apartment}${address.entrance != null ? ', Podyezd: ${address.entrance}' : ''}${address.floor != null ? ', Qavat: ${address.floor}' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To\'lov ma\'lumotlari',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Mahsulotlar', order.subtotal),
          _buildSummaryRow('Yetkazib berish', order.deliveryFee),
          if (order.discount > 0) _buildSummaryRow('Chegirma', -order.discount),
          if (order.cashbackUsed > 0)
            _buildSummaryRow('Cashback', -order.cashbackUsed),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jami',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatPrice(order.total.toInt())} ${AppStrings.currency}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _getPaymentIcon(order.paymentMethod),
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getPaymentMethodLabel(order.paymentMethod),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    final isNegative = amount < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            '${isNegative ? "-" : ""}${_formatPrice(amount.abs().toInt())} ${AppStrings.currency}',
            style: TextStyle(
              color: isNegative ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showCancelDialog(order),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Bekor qilish'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Qo'ng'iroq qilish
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.call, size: 20),
                    SizedBox(width: 8),
                    Text('Qo\'ng\'iroq'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtmani bekor qilish'),
        content: const Text('Haqiqatan ham buyurtmani bekor qilmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ordersProvider = context.read<OrdersProvider>();
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await ordersProvider.cancelOrder(order.id);
              if (mounted && success) {
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Buyurtma bekor qilindi'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ha, bekor qilish'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return {
          'text': 'Kutilmoqda',
          'color': AppColors.warning,
          'icon': Iconsax.clock,
        };
      case OrderStatus.confirmed:
        return {
          'text': 'Tasdiqlandi',
          'color': AppColors.accent,
          'icon': Iconsax.tick_square,
        };
      case OrderStatus.processing:
        return {
          'text': 'Tayyorlanmoqda',
          'color': AppColors.accent,
          'icon': Iconsax.box_tick,
        };
      case OrderStatus.shipping:
        return {
          'text': 'Yo\'lda',
          'color': AppColors.primary,
          'icon': Iconsax.truck_fast,
        };
      case OrderStatus.delivered:
        return {
          'text': 'Yetkazildi',
          'color': AppColors.success,
          'icon': Iconsax.tick_circle,
        };
      case OrderStatus.cancelled:
        return {
          'text': 'Bekor qilindi',
          'color': AppColors.error,
          'icon': Iconsax.close_circle,
        };
    }
  }

  IconData _getPaymentIcon(String? method) {
    switch (method) {
      case 'card':
        return Iconsax.card;
      case 'click':
      case 'payme':
        return Iconsax.mobile;
      default:
        return Iconsax.money;
    }
  }

  String _getPaymentMethodLabel(String? method) {
    switch (method) {
      case 'card':
        return 'Plastik karta';
      case 'click':
        return 'Click';
      case 'payme':
        return 'Payme';
      default:
        return 'Naqd pul';
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
