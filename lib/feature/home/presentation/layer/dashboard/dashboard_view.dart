import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/banner_image.dart';
import 'package:cbook_dt/common/fi_chart_date_amount.dart';
import 'package:cbook_dt/common/round_fi_chart_document_view.dart';
import 'package:cbook_dt/common/feature_not_available.dart';
import 'package:cbook_dt/feature/home/presentation/layer/dashboard/dashboard_controller.dart';
import 'package:cbook_dt/feature/home/presentation/widget/reusable_box.dart';
import 'package:cbook_dt/feature/purchase/purchase_list_api.dart';
import 'package:cbook_dt/feature/purchase_return/purchase_return_list.dart';
import 'package:cbook_dt/feature/sales/sales_list.dart';
import 'package:cbook_dt/feature/sales_bulk/sales_bulk.dart';
import 'package:cbook_dt/feature/sales_return/sales_return_list.dart';
import 'package:cbook_dt/utils/custom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  DashboardViewState createState() => DashboardViewState();
}

class DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: const _Layout(),
    );
  }
}

class _Layout extends StatelessWidget {
  const _Layout();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    final colorScheme = Theme.of(context).colorScheme;
    // Function to show the pop-up and add a new button

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light, // for Android
        statusBarBrightness: Brightness.dark, // for iOS
      ),
      child: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Scaffold(
            floatingActionButton: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FocusableActionDetector(
                    autofocus: true,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) =>
                              _buildBottomSheetContent(context),
                        );
                      },
                      child: Container(
                        width: 50, // Make sure width and height are equal
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: colorScheme.surface,
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/image/cbook_logo.png",
                                    height: 40,
                                    width: 40,
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Commerce Book Ltd",
                                        style: TextStyle(
                                          fontFamily: 'Calibri',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Admin",
                                        style: TextStyle(
                                           fontFamily: 'Calibri',
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const Icon(
                                Icons.notification_add,
                                color: Colors.white,
                              ),
                              // You can add a button or search icon here
                            ],
                          ),
                        ),

                        //vPad16,
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          hPad5,
                          Expanded(
                            child: ReusableBox(
                              icon: Icons.monetization_on,
                              label: "Cash",
                              value: "৳ 12,500,000",
                              borderColor: colorScheme.primary,
                              textColor: Colors.black,
                              iconColor: colorScheme.primary,
                            ),
                          ),
                          hPad5,
                          Expanded(
                            child: ReusableBox(
                              icon: Icons.account_balance,
                              label: "Bank",
                              value: "৳ 25,000,009",
                              borderColor: Colors.black,
                              textColor: Colors.black,
                              iconColor: colorScheme.primary,
                            ),
                          ),
                          hPad5,
                          Expanded(
                            child: ReusableBox(
                              icon: Icons.person_3_outlined,
                              label: "Customer",
                              value: "৳ 80,200.000",
                              borderColor: Colors.black,
                              textColor: Colors.black,
                              iconColor: colorScheme.primary,
                            ),
                          ),
                          hPad5,
                          Expanded(
                            child: ReusableBox(
                              icon: Icons.pie_chart,
                              label: "Suppiler",
                              value: "৳ 47,300,000",
                              borderColor: Colors.black,
                              textColor: Colors.black,
                              iconColor: colorScheme.primary,
                            ),
                          ),
                          hPad5,
                        ],
                      ),

                      // Row(
                      //   children: [
                      //     hPad5,
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(2.0),
                      //         child: CustomDashboardStats(
                      //           title: "Receipt",
                      //           value: "৳ 10,550",
                      //           titleBackgroundColor: colorScheme.primary,
                      //           titleTextColor: colorScheme.secondary,
                      //           valueBackgroundColor: Colors.grey.shade400,
                      //           valueTextColor: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(2.0),
                      //         child: CustomDashboardStats(
                      //           title: "Payment",
                      //           value: "৳ 10,550",
                      //           titleBackgroundColor: colorScheme.primary,
                      //           titleTextColor: colorScheme.secondary,
                      //           valueBackgroundColor: Colors.grey.shade400,
                      //           valueTextColor: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(2.0),
                      //         child: CustomDashboardStats(
                      //           title: "Expense",
                      //           value: "৳ 10,550",
                      //           titleBackgroundColor: colorScheme.primary,
                      //           titleTextColor: colorScheme.secondary,
                      //           valueBackgroundColor: Colors.grey.shade100,
                      //           valueTextColor: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(2.0),
                      //         child: CustomDashboardStats(
                      //           title: "Income",
                      //           value: "৳ 10,550",
                      //           titleBackgroundColor: colorScheme.primary,
                      //           titleTextColor: colorScheme.secondary,
                      //           valueBackgroundColor: Colors.grey.shade400,
                      //           valueTextColor: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     hPad5,
                      //   ],
                      // ),

                      const SizedBox(
                        height: 8,
                      ),

                      // Text(
                      //   "Today Stock Information",
                      //   style: GoogleFonts.notoSansPhagsPa(
                      //       color: AppColors.primaryColor,
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 16),
                      // ),

                      // const SizedBox(
                      //   height: 8,
                      // ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //   child: Table(
                      //     border: TableBorder.all(
                      //         color: Colors.grey.shade300, width: 1),
                      //     children:
                      //         controller.data.asMap().entries.map((entry) {
                      //       int index = entry.key;
                      //       var item = entry.value;
                      //       return TableRow(
                      //         decoration: BoxDecoration(
                      //           color: index % 2 == 0
                      //               ? const Color(0xffdfe8f4)
                      //               : Colors.white, // Red for odd rows
                      //         ),
                      //         children: [
                      //           Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Text(
                      //               item["label"]!,
                      //               style: GoogleFonts.notoSansPhagsPa(
                      //                 fontSize: 12,
                      //                 // fontWeight: FontWeight.w500,
                      //                 color: Colors.black.withOpacity(0.8),
                      //               ),
                      //             ),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Text(
                      //               item["value"]!,
                      //               textAlign: TextAlign.end,
                      //               style: GoogleFonts.notoSansPhagsPa(
                      //                 fontSize: 12,
                      //                 // fontWeight: FontWeight.w700,
                      //                 color: Colors.black.withOpacity(0.8),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    "Transaction History",
                    style: GoogleFonts.notoSansPhagsPa(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  CustomBarChart(),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    "Transaction summary",
                    style: GoogleFonts.notoSansPhagsPa(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  DonutChartViewRound(),

                  const SizedBox(
                    height: 6,
                  ),

                  const AutoScrollCarousel(),

                  const SizedBox(
                    height: 6,
                  ),

                  //(height: 50,),

                  const SizedBox(
                    height: 20,
                  ),
                  //const BarChartTop(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomSheetContent(BuildContext context) {
  return SafeArea(
    child: SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for Sales Transaction
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context, MaterialPageRoute(builder: (_) => SalesScreen()));

                  _buildBottomSheetContent(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0), // Only vertical padding
                      child: Text(
                        "Sales Transaction",
                        style: GoogleFonts.notoSansPhagsPa(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ),

              // Icons with text in a Wrap for Sales Transaction
              Wrap(
                spacing: 10,
                runSpacing: 20,
                children: [
                  //// Sales/Bill/\nInvoice
                  InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SalesScreen()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(Icons.shopping_cart_checkout,
                          "Sales/Bill/\nInvoice", context)),


                   //// bulk sales
                  InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ItemListPage()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(Icons.apps,
                          "Bulk sales/\nInvoice", context)),        

                  //// Estimate/\nQuotation
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.view_timeline, "Estimate/\nQuotation", context),
                  ),

                  //// Challan
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child:
                          _buildIconWithLabel(Icons.tab, "Challan", context)),

                  //// Receipt In
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.receipt, "Receipt In", context)),

                  ////Sales\nReturn
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SalesReturnScreen())); //SalesReturnView
                      //showFeatureNotAvailableDialog(context);
                    },
                    child: _buildIconWithLabel(
                        Icons.redo, "Sales\nReturn", context),
                  ),

                  ////Delivery
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.delivery_dining, "Delivery", context)),
                ],
              ),

              // Purchase Transaction Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Purchase Transaction",
                  style: GoogleFonts.notoSansPhagsPa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Wrap(
                runSpacing: 20,
                spacing: 10,
                children: [
                  ////Purchase
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PurchaseListApi()));

                      //showFeatureNotAvailableDialog(context);
                    },
                    child: _buildIconWithLabel(
                        Icons.add_shopping_cart_rounded, "Purchase", context),
                  ),

                  ////  Purchase/\nOrder
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.work_history, "Purchase/\nOrder", context),
                  ),

                  //// Payment\nOut
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.tab, "Payment\nOut", context)),

                  ///// Purchase\nReturn
                  InkWell(
                    onTap: () {},
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PurchaseReturnList()));

                        //showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.redo_rounded, "Purchase\nReturn", context),
                    ),
                  ),
                ],
              ),

              // Account Transaction Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Only vertical padding
                child: Text(
                  "Account Transaction",
                  style: GoogleFonts.notoSansPhagsPa(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

              Wrap(
                runSpacing: 20,
                spacing: 10,
                children: [
                  ////Purchase
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.card_travel, "Expense", context),
                  ),

                  ////  Purchase/\nOrder
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              const FeatureNotAvailableDialog());
                    },
                    child: _buildIconWithLabel(
                        Icons.work_history, "Contra", context),
                  ),

                  //// Payment\nOut
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(Icons.tab, "Income", context)),

                  //jurnal
                  InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const FeatureNotAvailableDialog());
                      },
                      child: _buildIconWithLabel(
                          Icons.article_sharp, "Jurnal", context)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// // Helper function to build an icon with a label

Widget _buildIconWithLabel(IconData icon, String label, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryColor,
          ),
        ),
      ), // Icon size and color
      const SizedBox(height: 4), // Space between icon and text
      Text(
        label,
        style: GoogleFonts.notoSansPhagsPa(fontSize: 12, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class ServiceBottmModel {
  String label;
  Widget page;

  ServiceBottmModel(this.label, this.page);
}
