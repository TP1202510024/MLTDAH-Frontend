import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.contentPadding,
    this.fillColor,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.labelStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        if (label.isNotEmpty) const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hintText,
            border: border ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: border,
            focusedBorder: focusedBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorBorder: errorBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 12,
            ),
            filled: fillColor != null || !enabled,
            fillColor: !enabled
                ? Colors.grey[200]
                : fillColor ?? Colors.transparent,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            hintStyle: hintStyle ?? TextStyle(color: Colors.grey[600]),
          ),
          style: !enabled
              ? TextStyle(color: Colors.grey[600])
              : null,
        ),
      ],
    );
  }
}