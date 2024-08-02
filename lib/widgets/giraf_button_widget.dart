// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../style/custom_color.dart' as theme;

/// A button for the Giraf application.
class GirafButton extends StatefulWidget {
  /// A button for the Giraf application.
  /// The button can contain some text and an icon both of which are optional.
  /// isEnabled determines whether the button is enabled or disabled by default.
  /// isEnabledStream is a stream which is listened to, to update the
  /// enabled/disabled state of the button.
  const GirafButton({
    required Key key,
    this.text = 'Default',
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.icon = const ImageIcon(AssetImage('assets/icons/accept.png')),
    this.width = 160.0,
    this.height = 40.0,
    required this.onPressed,
    this.isEnabled = true,
    // ignore: avoid_unused_constructor_parameters
    this.isEnabledStream = const Stream<bool>.empty(),
    // ignore: avoid_unused_constructor_parameters
    StreamBuilder<File?>? child,
  }) : super(key: key);

  /// The text placed at the center of the button.
  final String text;

  /// The size of the text
  final double fontSize;

  /// The icon placed next to the text on the button.
  final ImageIcon icon;

  /// The width of the button.
  final double width;

  /// The height of the button.
  final double height;

  /// The typeface thickness to use when painting the text (e.g., bold)
  final FontWeight fontWeight;

  /// The function to be called when the button is pressed.
  /// The function must be a void funtion with no input parameters.
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Determines whether the button is enabled or disabled by default. If
  /// isEnabledStream is also supplied, the latest emitted item from the stream
  /// will determine whether the button is enabled. If the stream emits a null
  /// value, isEnabled will be used instead.
  final bool isEnabled;

  /// A stream which tells whether the button should be enabled or disabled.
  /// If the stream emits a null value, the value of isEnabled will be used
  /// instead.
  final Stream<bool>? isEnabledStream;

  @override
  _GirafButtonState createState() => _GirafButtonState();
}

class _GirafButtonState extends State<GirafButton> {
  @override
  void initState() {
    // If onPressed callback is null, the button should be disabled.
    _isEnabled = widget.isEnabled && widget.onPressed != null;
    _isPressed = false;
    if (widget.isEnabledStream != null) {
      _isEnabledSubscription =
          widget.isEnabledStream!.listen(_handleIsEnabledStreamEvent);
    }
    super.initState();
  }

  static const Gradient _gradientDefault = LinearGradient(colors: <Color>[
    theme.GirafColors.gradientDefaultYellow,
    theme.GirafColors.gradientDefaultOrange
  ], begin: Alignment(0.0, -1.0), end: Alignment(0.0, 1.0));

  static const Gradient _gradientPressed = LinearGradient(colors: <Color>[
    theme.GirafColors.gradientPressedYellow,
    theme.GirafColors.gradientPressedOrange
  ], begin: Alignment(0.0, -1.0), end: Alignment(0.0, 1.0));

  static const Gradient _gradientDisabled = LinearGradient(colors: <Color>[
    theme.GirafColors.gradientDisabledYellow,
    theme.GirafColors.gradientDisabledOrange
  ], begin: Alignment(0.0, -1.0), end: Alignment(0.0, 1.0));

  static const Color _borderDefault = theme.GirafColors.gradientDefaultBorder;
  static const Color _borderPressed = theme.GirafColors.gradientPressedBorder;
  static const Color _borderDisabled = theme.GirafColors.gradientDisabledBorder;

  bool? _isPressed;
  bool? _isEnabled;
  StreamSubscription<bool>? _isEnabledSubscription;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: _isEnabled!
              ? (_isPressed! ? _gradientPressed : _gradientDefault)
              : _gradientDisabled,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _isEnabled!
                  ? (_isPressed! ? _borderPressed : _borderDefault)
                  : _borderDisabled,
              width: 1.2),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: _buildWidgetsOnButton()),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (_isEnabled!) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isEnabled!) {
      widget.onPressed!();
      // On a quick tap the pressed state is not shown, because the state
      // changes too fast, hence we introduce a delay.
      _timer = Timer(const Duration(milliseconds: 100),
          () => setState(() => _isPressed = false));
    }
  }

  void _onTapCancel() {
    if (_isEnabled!) {
      setState(() => _isPressed = false);
    }
  }

  void _handleIsEnabledStreamEvent(bool? value) {
    // If a null value is emitted reset enabled state to default.
    value ??= widget.isEnabled;

    // If onPressed callback is null, the button should be disabled.
    if (widget.onPressed == null) {
      value = false;
    }

    // Only update state if the new value is different from the previous.
    if (value != _isEnabled) {
      setState(() {
        _isEnabled = value;
      });
    }
  }

  Widget _buildWidgetsOnButton() {
    final TextStyle textStyle = TextStyle(
        color: theme.GirafColors.black,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight);

    if (widget.text != '' && widget.icon != '') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: widget.icon,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              widget.text,
              style: textStyle,
            ),
          ),
        ],
      );
    } else if (widget.text != '') {
      return Center(
          child: AutoSizeText(
        widget.text,
        style: textStyle,
        minFontSize: 5,
      ));
    } else if (widget.icon != '') {
      return Center(
        child: widget.icon,
      );
    }

    // return null;
    throw Exception;
  }

  @override
  void dispose() {
    _isEnabledSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
