import 'package:flutter/material.dart';
import 'package:logisticscustomer/export.dart';

class CustomAnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final Color iconColor;
  final Color borderColor;
  final Color textColor;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly; // ✅ new
  final VoidCallback? onTap; // ✅ new
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  const CustomAnimatedTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.inputFormatters,
    this.iconColor = Colors.blue,
    this.borderColor = Colors.blue,
    this.textColor = Colors.black54,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false, // default false
    this.onTap, // optional
    this.suffixIcon,
    this.onChanged,
  });

  @override
  State<CustomAnimatedTextField> createState() =>
      _CustomAnimatedTextFieldState();
}

class _CustomAnimatedTextFieldState extends State<CustomAnimatedTextField> {
  bool _isFocused = false;
  bool _hasText = false;
  String? _errorText; // store manually

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  void _handleTextChange() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
      if (widget.validator != null) {
        _errorText = widget.validator!(widget.controller.text);
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldFloat = _isFocused || _hasText;
    final borderRadius = BorderRadius.circular(12);

    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              inputFormatters: widget.inputFormatters,

              validator: (value) => null,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              onChanged: (val) {
                if (widget.validator != null) {
                  final err = widget.validator!(val);
                  setState(() => _errorText = err);
                }
              },

              decoration: InputDecoration(
                isDense: true,

                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: _errorText != null ? Colors.red : widget.iconColor,
                  ),
                ),

                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),

                suffixIcon: widget.suffixIcon,

                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.textColor.withOpacity(0.5),
                  fontSize: 10,
                ),

                filled: true,
                fillColor: Colors.white.withOpacity(0.25),

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 10, // ⬅️ yahan bhi thora kam
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: _errorText != null
                        ? Colors.red
                        : widget.borderColor.withOpacity(0.7),
                    width: 1.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: _errorText != null ? Colors.red : widget.borderColor,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          // ----------------------- FLOATING LABEL ---------------------------
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            left: 12,
            top: shouldFloat ? -20 : 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: shouldFloat ? 1 : 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.labelText,
                  style: TextStyle(
                    color: _errorText != null ? Colors.red : widget.borderColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ----------------------- RIGHT SIDE ERROR BADGE -------------------
          if (_errorText != null)
            Align(
              alignment: Alignment.bottomRight, // ❌ move to right
              child: Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
