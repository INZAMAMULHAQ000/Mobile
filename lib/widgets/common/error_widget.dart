import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: AppConstants.defaultPadding),
            Text(
              AppStrings.error,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: AppConstants.smallPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.error, color: Colors.white),
      backgroundColor: Theme.of(context).colorScheme.error,
      actions: [
        if (onAction != null && actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        TextButton(
          onPressed: onDismiss ?? () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          child: const Text(
            'DISMISS',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            IconButton(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }
}