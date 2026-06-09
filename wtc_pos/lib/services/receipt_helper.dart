import 'package:intl/intl.dart';
import '../models/order_model.dart';

const int kPrinterWidth = 32;

/// A single line on the receipt
class ReceiptLine {
  final String text;
  final bool bold;
  final bool centered;
  final bool divider;

  const ReceiptLine({
    this.text = '',
    this.bold = false,
    this.centered = false,
    this.divider = false,
  });
}

class ReceiptHelper {
  static String formatLine(String left, String right) {
    if (left.length + right.length > kPrinterWidth) {
      final available = kPrinterWidth - right.length - 1;
      left = available > 0 ? left.substring(0, available) : '';
    }
    final spaces = kPrinterWidth - left.length - right.length;
    return left + (' ' * spaces.clamp(0, kPrinterWidth)) + right;
  }

  static String crop(String text, int max) =>
      text.length <= max ? text : text.substring(0, max);

  static List<ReceiptLine> buildLines(Order order) {
    final lines = <ReceiptLine>[];

    // Header
    lines.add(const ReceiptLine(text: 'THE WINGNUT TRADING CO.', bold: true, centered: true));
    lines.add(const ReceiptLine(text: 'Cameron, North Carolina', centered: true));
    lines.add(const ReceiptLine(text: ' '));
    lines.add(ReceiptLine(text: 'GUEST: ${(order.customerName ?? '???').toUpperCase()}', centered: true));
    lines.add(const ReceiptLine(text: ' '));
    lines.add(const ReceiptLine(divider: true));
    lines.add(const ReceiptLine(text: ' '));

    // Items
    for (final item in order.items) {
      final lineTotal = item.lineTotal;
      final itemLine = formatLine(
        '${item.quantity} ${item.blankName}',
        '\$${lineTotal.toStringAsFixed(2)}',
      );
      lines.add(ReceiptLine(text: itemLine, bold: true));

      // Size
      if (item.size.isNotEmpty) {
        lines.add(ReceiptLine(text: crop('   ${sizeLabel(item.size)}', kPrinterWidth)));
      }

      // Transfers
      for (final p in item.placements) {
        if (p.hasDecal) {
          lines.add(ReceiptLine(
            text: crop('   ${p.slot}: ${p.transferName ?? ''}', kPrinterWidth),
          ));
        }
      }
    }

    lines.add(const ReceiptLine(text: ' '));

    // Discount
    if (order.discountPct > 0) {
      final subtotal = order.subtotal + order.discountAmount; // pre-discount
      lines.add(ReceiptLine(
        text: formatLine('SUBTOTAL:', '\$${(order.total + order.discountAmount).toStringAsFixed(2)}'),
        bold: true,
      ));
      lines.add(ReceiptLine(
        text: formatLine('DISCOUNT (${order.discountPct.toStringAsFixed(0)}%):', '-\$${order.discountAmount.toStringAsFixed(2)}'),
        bold: true,
      ));
    }

    lines.add(ReceiptLine(
      text: formatLine('TOTAL:', '\$${order.total.toStringAsFixed(2)}'),
      bold: true,
    ));
    lines.add(ReceiptLine(
      text: formatLine('PAYMENT:', order.paymentMethod.toUpperCase()),
      bold: true,
    ));

    // Footer
    lines.add(const ReceiptLine(text: ' '));
    lines.add(const ReceiptLine(divider: true));
    lines.add(const ReceiptLine(text: ' '));

    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    lines.add(ReceiptLine(text: formattedDate, centered: true));
    lines.add(const ReceiptLine(text: ' '));
    lines.add(const ReceiptLine(text: 'THANK YOU FOR SUPPORTING', bold: true, centered: true));
    lines.add(const ReceiptLine(text: 'WINGNUT TRADING CO!', bold: true, centered: true));

    return lines;
  }
}