import 'package:flutter/material.dart';
import 'package:front_desk_app/model/values.dart';

Future<bool?> showPinDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PinEntryDialog();
    },
  );
}

class PinEntryDialog extends StatefulWidget {
  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  String _enteredPin = '';
  final String _correctPin = '7862'; // Change this to your desired PIN
  bool _showError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _showError = false;
      });

      // Check PIN when 4 digits entered
      if (_enteredPin.length == 4) {
        Future.delayed(Duration(milliseconds: 200), () {
          if (_enteredPin == _correctPin) {
            // Correct PIN - unlock and close dialog
            Values.locked = false;
            Navigator.of(context).pop(true);
          } else {
            // Wrong PIN - show error and clear
            setState(() {
              _showError = true;
              _enteredPin = '';
            });
          }
        });
      }
    }
  }

  void _onClearPressed() {
    setState(() {
      _enteredPin = '';
      _showError = false;
    });
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinDot(bool filled) {
    return Container(
      width: 16,
      height: 16,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 350,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_open,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Enter PIN to Unlock',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),

            // PIN dots display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPinDot(_enteredPin.length >= 1),
                _buildPinDot(_enteredPin.length >= 2),
                _buildPinDot(_enteredPin.length >= 3),
                _buildPinDot(_enteredPin.length >= 4),
              ],
            ),

            SizedBox(height: 8),

            // Error message
            Container(
              height: 24,
              child: _showError
                  ? Text(
                'Incorrect PIN',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
                  : SizedBox.shrink(),
            ),

            SizedBox(height: 16),

            // Number pad
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 70), // Empty space
                    _buildNumberButton('0'),
                    InkWell(
                      onTap: _onClearPressed,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: Colors.red.shade300, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.backspace,
                            color: Colors.red.shade700,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}