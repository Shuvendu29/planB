import 'package:flutter/material.dart';

/// App-wide color scheme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB);        // Blue 600
  static const Color primaryLight = Color(0xFF3B82F6);   // Blue 500
  static const Color primaryDark = Color(0xFF1D4ED8);    // Blue 700
  
  // Secondary colors
  static const Color secondary = Color(0xFF10B981);      // Emerald 500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryDark = Color(0xFF059669);  // Emerald 600
  
  // Accent colors
  static const Color accent = Color(0xFFF59E0B);         // Amber 500
  static const Color accentLight = Color(0xFFFBBF24);    // Amber 400
  
  // Status colors
  static const Color success = Color(0xFF22C55E);        // Green 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color info = Color(0xFF3B82F6);           // Blue 500
  
  // Neutral colors
  static const Color background = Color(0xFFF8FAFC);     // Slate 50
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0);         // Slate 200
  static const Color textPrimary = Color(0xFF1E293B);    // Slate 800
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textHint = Color(0xFF94A3B8);       // Slate 400
  
  // Role-specific colors
  static const Color userPrimary = Color(0xFF2563EB);    // Blue
  static const Color smePrimary = Color(0xFF7C3AED);     // Violet
  static const Color adminPrimary = Color(0xFFDC2626);   // Red
  
  // Gradient backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient smeGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App-wide text styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}

/// Common app button styles
class AppButtons {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle outline = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle success = ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppTextStyles.button,
  );
}

/// Card decoration helper
class AppCards {
  static BoxDecoration get standard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get elevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get outlined => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 1),
  );
  
  static BoxDecoration gradient(Color primaryColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
  );
}

/// Input decoration helper
class AppInputs {
  static InputDecoration textField({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textHint) : null,
    suffix: suffix,
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
  
  static InputDecoration searchField({String? hint}) => InputDecoration(
    hintText: hint ?? 'Search...',
    prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );
}

/// Spacing constants
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Reusable stat card widget
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppCards.standard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTextStyles.headline3),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!, style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headline3),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!, style: AppTextStyles.body1.copyWith(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textHint),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.headline3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle!, style: AppTextStyles.body2, textAlign: TextAlign.center),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(onPressed: onAction, style: AppButtons.primary, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator
class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(message!, style: AppTextStyles.body2),
          ],
        ],
      ),
    );
  }
}

/// Status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  factory StatusBadge.pending() => const StatusBadge(
    text: 'Pending',
    color: AppColors.warning,
    icon: Icons.hourglass_empty,
  );

  factory StatusBadge.approved() => const StatusBadge(
    text: 'Approved',
    color: AppColors.success,
    icon: Icons.check_circle,
  );

  factory StatusBadge.rejected() => const StatusBadge(
    text: 'Rejected',
    color: AppColors.error,
    icon: Icons.cancel,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Points display card
class PointsCard extends StatelessWidget {
  final int points;
  final bool showTopUp;
  final VoidCallback? onTopUp;

  const PointsCard({
    super.key,
    required this.points,
    this.showTopUp = true,
    this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.stars, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$points', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (showTopUp)
            ElevatedButton(
              onPressed: onTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

/// Content card for lists
class ContentListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailingText;
  final Widget? trailing;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final VoidCallback? onTap;

  const ContentListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.trailing,
    this.leadingIcon,
    this.leadingColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: leadingIcon != null
            ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (leadingColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(leadingIcon, color: leadingColor ?? AppColors.primary),
              )
            : null,
        title: Text(title, style: AppTextStyles.subtitle1),
        subtitle: Text(subtitle, style: AppTextStyles.body2),
        trailing: trailing ?? (trailingText != null ? Text(trailingText!, style: AppTextStyles.caption) : null),
      ),
    );
  }
}

/// Quick action button
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}