import 'package:flutter/material.dart';

class CustomDropdownTwo extends StatefulWidget {
  final List<String> items;
  final String  ? hint;
  final String? labelText;
  final Function(String) onChanged;
  final double width;
  final double height;
  final String? selectedItem;
  final String? value;

  const CustomDropdownTwo({
    super.key,
    required this.items,
    this.hint,
    this.labelText,
    required this.onChanged,
    required this.width,
    required this.height,
    this.selectedItem,
    this.value,
  });

  @override
  State<CustomDropdownTwo> createState() => _CustomDropdownTwoState();
}

class _CustomDropdownTwoState extends State<CustomDropdownTwo> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isDropdownOpen = false;
  String? selectedItem;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem ?? widget.value;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != selectedItem) {
      setState(() {
        selectedItem = widget.value;
      });
    }
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() => isDropdownOpen = true);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => isDropdownOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeDropdown,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy, // Position at the button top, not below
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height), // move dropdown below button
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: widget.items.map((item) {
                        return ListTile(
                          dense: true,
                          title:
                              Text(item, style: const TextStyle(fontSize: 13)),
                          onTap: () {
                            setState(() => selectedItem = item);
                            widget.onChanged(item);
                            _removeDropdown();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _removeDropdown();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedItem != null && selectedItem!.isNotEmpty;
    final verticalPadding = (widget.height - 20) / 2; // 20 = approx text height

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          _toggleDropdown();
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height, // <-- use widget.height here
          child: InputDecorator(
            isFocused: isDropdownOpen || _focusNode.hasFocus,
            isEmpty: !hasValue,
            decoration: InputDecoration(
              filled: true,
              isDense: true,
              labelText: widget.labelText,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              floatingLabelStyle:
                  const TextStyle(fontSize: 12, color: Colors.green),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: verticalPadding),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    // hasValue ? selectedItem! : widget.hint,
                    hasValue ? selectedItem! : widget.hint ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: hasValue ? Colors.black : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final hasValue = selectedItem != null && selectedItem!.isNotEmpty;

  //   return CompositedTransformTarget(
  //     link: _layerLink,
  //     child: GestureDetector(
  //       onTap: () {
  //         _focusNode.requestFocus();
  //         _toggleDropdown();
  //       },
  //       child: Container(
  //         color: Colors.red,
  //         child: SizedBox(
  //           width: widget.width,
  //           height: 26,
  //           child: InputDecorator(
  //             isFocused: isDropdownOpen || _focusNode.hasFocus,
  //             isEmpty: !hasValue,
  //             decoration: InputDecoration(
  //               filled: true,
  //               isDense: true,
  //               labelText: widget.labelText,
  //               labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
  //               floatingLabelStyle:
  //                   const TextStyle(fontSize: 12, color: Colors.green),
  //               enabledBorder: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(3),
  //                 borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
  //               ),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(3),
  //                 borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
  //               ),
  //               focusedBorder: const OutlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.green),
  //               ),
  //               contentPadding:
  //                   const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     hasValue ? selectedItem! : widget.hint,
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       color: hasValue ? Colors.black : Colors.grey.shade600,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //                 Icon(
  //                   isDropdownOpen
  //                       ? Icons.arrow_drop_up
  //                       : Icons.arrow_drop_down,
  //                   color: Colors.grey.shade700,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}




// ////====> its working
// class CustomDropdownTwo extends StatefulWidget {
//   final List<String> items;
//   final String hint;
//   final Function(String) onChanged;
//   final double width;
//   final double height;
//   final String? selectedItem; // Add this line
//   final String? value;

//   const CustomDropdownTwo({
//     Key? key,
//     required this.items,
//     required this.hint,
//     required this.onChanged,
//     required this.width,
//     required this.height,
//     this.selectedItem, // Add this line
//     this.value,
//   }) : super(key: key);

//   @override
//   _CustomDropdownTwoState createState() => _CustomDropdownTwoState();
// }

// class _CustomDropdownTwoState extends State<CustomDropdownTwo> {
//   OverlayEntry? _overlayEntry;
//   final LayerLink _layerLink = LayerLink();
//   bool isDropdownOpen = false;
//   String? selectedItem;

//   @override
//   void didUpdateWidget(covariant CustomDropdownTwo oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.value != null && widget.value != selectedItem) {
//       setState(() {
//         selectedItem = widget.value;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     selectedItem = widget.selectedItem ?? widget.hint; // Set initial text
//   }

//   void _toggleDropdown() {
//     if (isDropdownOpen) {
//       _removeDropdown();
//     } else {
//       _showDropdown();
//     }
//   }

//   void _showDropdown() {
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//     setState(() {
//       isDropdownOpen = true;
//     });
//   }

//   void _removeDropdown() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     setState(() {
//       isDropdownOpen = false;
//     });
//   }

//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//     var size = renderBox.size;
//     var offset = renderBox.localToGlobal(Offset.zero);
//     double maxWidth = MediaQuery.of(context).size.width * 0.8 - 18;

//     return OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           // Background tap handler
//           Positioned.fill(
//             child: GestureDetector(
//               onTap: _removeDropdown,
//               behavior: HitTestBehavior.opaque,
//               child: Container(),
//             ),
//           ),
//           // Scrollable Dropdown
//           Positioned(
//             width: widget.width == double.infinity ? maxWidth : widget.width,
//             left: offset.dx,
//             top: offset.dy + size.height,
//             child: CompositedTransformFollower(
//               link: _layerLink,
//               showWhenUnlinked: false,
//               offset: Offset(0, size.height),
//               child: Material(
//                 elevation: 4.0,
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(5),
//                 child: Container(
//                   constraints: const BoxConstraints(
//                     maxHeight: 200, // 👈 LIMIT height to make it scrollable
//                   ),
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     shrinkWrap: true,
//                     children: widget.items.map((item) {
//                       return InkWell(
//                         onTap: () {
//                           setState(() {
//                             selectedItem = item;
//                           });
//                           widget.onChanged(item);
//                           _removeDropdown();
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 16),
//                           child: Text(
//                             item,
//                             style: const TextStyle(
//                                 color: Colors.black, fontSize: 11),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double maxWidth = MediaQuery.of(context).size.width * 0.8 -
//         5; // Max width is 90% of screen

//     final displayValue =
//         selectedItem?.isNotEmpty == true ? selectedItem : widget.hint;

//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onTap: _toggleDropdown,
//         child: Container(
//           width: widget.width == double.infinity ? maxWidth : widget.width,
//           height: widget.height,
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black12),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   displayValue ?? '',
//                   style: const TextStyle(color: Colors.black, fontSize: 14),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                 ),
//               ),

//               const SizedBox(width: 5), // spacing
//               Icon(
//                 isDropdownOpen
//                     ? Icons.arrow_drop_up
//                     : Icons.keyboard_arrow_down,
//                 color: Colors.black,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
