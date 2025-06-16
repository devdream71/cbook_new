 



import 'package:cbook_dt/feature/customer_create/model/customer_list.dart';
import 'package:cbook_dt/feature/customer_create/provider/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// customer list

class AddSalesFormfieldTwo extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final String? customerorSaleslist;
  final String? customerOrSupplierButtonLavel;
  final void Function()? onTap;
  final Color? color;

  const AddSalesFormfieldTwo({
    super.key,
    this.label,
    required this.controller,
    this.customerorSaleslist,
    this.customerOrSupplierButtonLavel,
    this.onTap,
    this.color,
  });

  @override
  State<AddSalesFormfieldTwo> createState() => _AddSalesFormfieldTwoState();
}

class _AddSalesFormfieldTwoState extends State<AddSalesFormfieldTwo> {
  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        final provider = Provider.of<CustomerProvider>(context, listen: false);
        // Show all customers when focused
        _filteredCustomers = provider.customerResponse?.data ?? [];
        _showOverlay(context);
      } else {
        _removeOverlay();
      }
    });
  }

  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  List<Customer> _filteredCustomers = [];

  void _showOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - offset.dx;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: screenWidth - offset.dx,
        child: Material(
          //elevation: 4,
          color: colorScheme.surface,
          child: Consumer<CustomerProvider>(
            builder: (context, provider, _) {
              if (_filteredCustomers.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                        color: Colors.grey), // Change color as needed
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: availableWidth,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.customerorSaleslist!,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              InkWell(
                                  onTap: widget.onTap,
                                  child: Text(
                                    widget.customerOrSupplierButtonLavel!,
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Divider(
                            color: widget.color,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets
                              .zero, // Remove default ListView padding
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];

                            return Container(
                              color: colorScheme.surface,
                              child: GestureDetector(
                                onTap: () {
                                  widget.controller.text = customer.name;
                                  provider.setSelectedCustomer(customer);
                                  _removeOverlay();
                                  FocusScope.of(context).unfocus();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6), // Custom padding
                                  child: Row(
                                    children: [
                                      // Colored Dot
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: customer.type == 'customer'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),

                                      // Name and Due
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                customer.name,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              customer.due.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                // customer.type ==
                                                //         'customer'
                                                //     ? Colors.green
                                                //     : Colors.red,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onChanged(String value, CustomerProvider provider) {
    if (value.isEmpty) {
      _filteredCustomers = [];
      _removeOverlay();
      return;
    }

    _filteredCustomers = provider.customerResponse?.data
            ?.where((customer) =>
                customer.name.toLowerCase().contains(value.toLowerCase()))
            .toList() ??
        [];

    if (_filteredCustomers.isNotEmpty) {
      if (_overlayEntry == null) {
        _showOverlay(context);
      } else {
        _overlayEntry!.markNeedsBuild();
      }
    } else {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Text(widget.label!,
                  style: const TextStyle(color: Colors.black, fontSize: 10)),
            const SizedBox(height: 5),
            SizedBox(
              height: 30,
              child: TextFormField(
                cursorHeight: 14,
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: (value) => _onChanged(value, customerProvider),
                style: const TextStyle(color: Colors.black, fontSize: 12),
                decoration: InputDecoration(
                  labelText: "Customer",
                  labelStyle: const TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelStyle:
                      const TextStyle(fontSize: 12, color: Colors.green),
                  hintText: "",
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    //vertical: 1,
                    horizontal: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
