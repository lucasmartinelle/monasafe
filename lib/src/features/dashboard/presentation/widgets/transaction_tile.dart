import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:simpleflow/src/common_widgets/category_icon.dart';
import 'package:simpleflow/src/common_widgets/icon_label_tile.dart';
import 'package:simpleflow/src/core/theme/app_colors.dart';
import 'package:simpleflow/src/core/theme/app_text_styles.dart';
import 'package:simpleflow/src/core/utils/currency_formatter.dart';
import 'package:simpleflow/src/core/utils/icon_mapper.dart';
import 'package:simpleflow/src/data/local/converters/type_converters.dart';
import 'package:simpleflow/src/data/local/daos/transaction_dao.dart';

/// A single transaction tile displaying icon, title, date, and amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction, super.key,
    this.onTap,
  });

  final TransactionWithDetails transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = transaction.category;
    final isExpense = category.type == CategoryType.expense;
    final amountColor = isExpense ? AppColors.error : AppColors.success;
    final amountText = CurrencyFormatter.formatTransaction(
      transaction.transaction.amount,
      isExpense: isExpense,
    );

    final dateFormatter = DateFormat('dd MMM', 'fr_FR');
    final dateText = dateFormatter.format(transaction.transaction.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IconLabelTile(
        iconWidget: CategoryIcon.fromHex(
          icon: IconMapper.getIcon(category.iconKey),
          colorHex: category.color,
        ),
        label: category.name,
        subtitle: _buildSubtitle(dateText),
        onTap: onTap,
        trailing: Text(
          amountText,
          style: AppTextStyles.labelMedium(color: amountColor),
        ),
      ),
    );
  }

  String _buildSubtitle(String dateText) {
    final note = transaction.transaction.note;
    if (note != null && note.isNotEmpty) {
      return '$dateText - $note';
    }
    return dateText;
  }
}
