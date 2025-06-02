import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../../domain/entities/user.dart';

class SubscriptionPackagesWidget extends StatefulWidget {
  const SubscriptionPackagesWidget({super.key});

  @override
  State<SubscriptionPackagesWidget> createState() =>
      _SubscriptionPackagesWidgetState();
}

class _SubscriptionPackagesWidgetState
    extends State<SubscriptionPackagesWidget> {
  List<SubscriptionPlan> _availablePlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailablePlans();
  }

  Future<void> _loadAvailablePlans() async {
    try {
      // In a real app, you'd fetch this from your repository
      // For now, we'll create mock plans
      _availablePlans = [
        const SubscriptionPlan(
          id: 'monthly_360',
          name: 'Monthly Plan',
          description: '360 AI VPN Monthly Subscription',
          price: 9.99,
          currency: 'USD',
          type: PlanType.monthly,
        ),
        const SubscriptionPlan(
          id: 'yearly_360',
          name: 'Yearly Plan',
          description: '360 AI VPN Yearly Subscription',
          price: 59.99,
          currency: 'USD',
          type: PlanType.yearly,
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_availablePlans.isEmpty) {
      return const Center(
        child: Text(
          'No subscription plans available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state is UserPurchasing;

        return Column(
          children: _availablePlans.map((plan) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
              child: _buildPlanTile(plan, isLoading),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPlanTile(SubscriptionPlan plan, bool isLoading) {
    final isYearly = plan.type == PlanType.yearly;
    final monthlyPrice = isYearly ? plan.price / 12 : plan.price;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: isYearly
              ? CupertinoColors.systemBlue
              : CupertinoColors.systemGrey,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoListTile(
        title: Text(
          plan.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${plan.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: CupertinoColors.activeGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isYearly)
              Text(
                'Save ${_calculateSavings()}%',
                style: const TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: isYearly ? _buildMonthlyPriceDisplay(monthlyPrice) : null,
        onTap: isLoading ? null : () => _purchasePlan(plan),
      ),
    );
  }

  Widget _buildMonthlyPriceDisplay(double monthlyPrice) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${formatter.format(monthlyPrice)}/month',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const Text(
          'Billed Annually',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  String _calculateSavings() {
    if (_availablePlans.length < 2) return '0';

    final monthlyPlan = _availablePlans.firstWhere(
      (plan) => plan.type == PlanType.monthly,
      orElse: () => _availablePlans.first,
    );

    final yearlyPlan = _availablePlans.firstWhere(
      (plan) => plan.type == PlanType.yearly,
      orElse: () => _availablePlans.last,
    );

    final monthlyTotal = monthlyPlan.price * 12;
    final savings = ((monthlyTotal - yearlyPlan.price) / monthlyTotal) * 100;

    return savings.round().toString();
  }

  void _purchasePlan(SubscriptionPlan plan) {
    HapticFeedback.selectionClick();
    context.read<UserBloc>().add(PurchaseSubscription(plan.id));
  }
}
