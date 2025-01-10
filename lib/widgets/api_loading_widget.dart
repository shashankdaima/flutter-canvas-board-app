import 'package:flutter/material.dart';

enum ApiStatus {
  success,
  loading,
  error,
}

class ApiLoadingWidget extends StatelessWidget {
  final ApiStatus status;
  final String? errorMessage;
  final double size;

  const ApiLoadingWidget({
    super.key,
    required this.status,
    this.errorMessage,
    this.size = 8.0,
  });

  Color _getStatusColor() {
    switch (status) {
      case ApiStatus.success:
        return Colors.green;
      case ApiStatus.loading:
        return Colors.amber;
      case ApiStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ApiStatus.success:
        return 'System Health';
      case ApiStatus.loading:
        return 'Loading';
      case ApiStatus.error:
        return 'Error';
    }
  }

  Widget _buildIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
        boxShadow: status == ApiStatus.loading
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: status == ApiStatus.loading
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(1 - value),
                    ),
                  ),
                );
              },
              onEnd: () {},
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    // Only wrap with tooltip if it's an error state
    if (status == ApiStatus.error) {
      return Tooltip(
        message: errorMessage ?? 'Error occurred',
        child: chip,
      );
    }

    return chip;
  }
}