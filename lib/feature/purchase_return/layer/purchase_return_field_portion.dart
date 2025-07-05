part of '../presentation/purchase_return_view.dart';

class FieldPortion extends StatelessWidget {
  const FieldPortion({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PurchaseReturnController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //purchase return amount //cash
        controller.isCash && controller.isAmount
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Amount",
                      controller:
                          TextEditingController(text: controller.addAmount2()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                        controller.amountController.text =
                            controller.addAmount2();
                      },
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 2,
        ),

        //purchase return discount //cash
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Discount",
                      controller: controller.discountController,
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                      },
                      decoration: InputDecoration(
                        hintText: "",
                        hintStyle: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        // const SizedBox(height: 2,),

        controller.isCash && controller.isDisocunt
            ? vPad5
            : const SizedBox.shrink(),

        // purchase return Total //cash
        controller.isCash && controller.isDisocunt
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Total",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Total',
                      controller:
                          TextEditingController(text: controller.totalAmount()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        ////===> purchase return credit ////amount
        controller.isCash == false && controller.isAmountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Amount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  hPad5,
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: 'Amount',
                      controller:
                          TextEditingController(text: controller.addAmount()),
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 2,
        ),

        //credit purchase return  //discount
        controller.isCash == false && controller.isDiscountCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Discount",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Discount",
                      controller: controller.discountController,
                      onChanged: (value) {
                        TextEditingController(text: controller.totalAmount());
                        controller.discountController.text = value;
                      },
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "",
                        hintStyle: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),

        const SizedBox(
          height: 2,
        ),

        ///purchase return total /// credit
        controller.isCash == false && controller.isSubTotalCredit
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Total",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: 30,
                    width: 150,
                    child: AddSalesFormfield(
                      labelText: "Total",
                      controller: TextEditingController(
                          text: controller.totalAmount2()),
                      onChanged: (value) {
                        Provider.of(context)<PurchaseReturnController>();
                      },
                      //style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: InputDecoration(
                        // filled: true,
                        fillColor: Colors.white,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide:
                              BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
