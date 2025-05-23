import 'package:dz_admin_panel/core/color_cons.dart';
import 'package:dz_admin_panel/core/textStyle_cons.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final TextStyle? hintStyle;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final bool isPassword;
  final Widget? prefixIcon;
  final String? suffixIcon;
  final int? maxline;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Function()? ontap;
  final bool readOnly;
  final Function(String)? onSubmitted;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.hintStyle,
    this.onChanged,
    this.validator,
    this.contentPadding,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxline = 1,
    this.focusNode,
    this.style,
    this.ontap,
    this.readOnly = false,
    this.onSubmitted,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword ? true : widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color.fromARGB(255, 6, 11, 27),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(5, 5)),
        ],
      ),
      child: TextFormField(
        onFieldSubmitted: widget.onSubmitted,
        cursorColor: ClrCons.whiteColor,
        readOnly: widget.readOnly,
        onTap: widget.ontap,
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.isPassword ? _isObscured : widget.obscureText,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        maxLines: widget.isPassword ? 1 : widget.maxline,
        style:
            widget.style ??
            TextStylesCons.custom(fontSize: 18, color: ClrCons.whiteColor),
        onChanged: widget.onChanged,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle:
              widget.hintStyle ??
              TextStyle(color: ClrCons.whiteColor, fontSize: 18),
          border: InputBorder.none,
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                      color: ClrCons.whiteColor,
                      size: 24,
                    ),
                    onPressed: _togglePasswordVisibility,
                  )
                  : widget.suffixIcon != null
                  ? Padding(
                    padding: const EdgeInsets.only(right: 12.0, left: 8),
                    child: Image.asset(
                      widget.suffixIcon ?? "", // Replace with your asset path
                      width: 24,
                      height: 24,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}
