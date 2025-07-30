import 'package:cbook_dt/app_const/app_colors.dart';
import 'package:cbook_dt/common/banner_image.dart';
import 'package:cbook_dt/common/fi_chart_date_amount.dart';
import 'package:cbook_dt/common/round_fi_chart_document_view.dart';
import 'package:cbook_dt/common/feature_not_available.dart';
import 'package:cbook_dt/feature/Received/received_list.dart';
import 'package:cbook_dt/feature/account/ui/expense/expense_list.dart';
import 'package:cbook_dt/feature/account/ui/income/income_list.dart';
import 'package:cbook_dt/feature/dashboard_report/provider/dashbord_report_provider.dart';
import 'package:cbook_dt/feature/home/presentation/layer/dashboard/dashboard_controller.dart';
import 'package:cbook_dt/feature/home/presentation/widget/reusable_box.dart';
import 'package:cbook_dt/feature/paymentout/payment_out_list.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => DashboardReportProvider()),
      ],
      child: const _Layout(),
    );
  }
}

class _Layout extends StatefulWidget {
  const _Layout();

  @override
  State<_Layout> createState() => _LayoutState();
}

class _LayoutState extends State<_Layout> with SingleTickerProviderStateMixin  {

  List<double> salesValues = [];
    late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
   

    final provider =
        Provider.of<DashboardReportProvider>(context, listen: false);
    Future.microtask(() async {
      await provider.fetchCustomerTransaction();
      await provider.fetchSupplierTransaction();
      await provider.fetchCashInHandTransaction();
      await provider.fetchBankBalance();
      await provider.fetchVoucherSummary();


    });

    
  provider.fetchSalesLast30Days().then((_) {
    setState(() {
      salesValues = provider.salesLast30Days.map((e) => e.sales.toDouble()).toList();
      _controller.forward();
    });
  });

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );

     
  }

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
            //backgroundColor: colorScheme.surface,
            backgroundColor: AppColors.sfWhite,
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
                            child: Consumer<DashboardReportProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return const Center(
                                      child: SizedBox());
                                } else if (provider.error != null) {
                                  return Text("Error: ${provider.error}");
                                } else {
                                  return ReusableBox(
                                    icon: Icons.monetization_on,
                                    label: "Cash",
                                    value:
                                        "৳ ${provider.customerTransaction ?? 0}",
                                    borderColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor: Colors.black,
                                    iconColor:
                                        Theme.of(context).colorScheme.primary,
                                  );
                                }
                              },
                            ),
                          ),
                          hPad5,

                          Expanded(
                            child: Consumer<DashboardReportProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return const Center(
                                      child: SizedBox());
                                } else if (provider.error != null) {
                                  return Text("Error: ${provider.error}");
                                } else {
                                  return ReusableBox(
                                    icon: Icons.pie_chart,
                                    label: "Supplier",
                                    value:
                                        "৳ ${provider.supplierTransaction ?? 0}",
                                    borderColor: Colors.black,
                                    textColor: Colors.black,
                                    iconColor:
                                        Theme.of(context).colorScheme.primary,
                                  );
                                }
                              },
                            ),
                          ),

                          hPad5,

                          Expanded(
  child: Consumer<DashboardReportProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: SizedBox());
      } else if (provider.error != null) {
        return Text("Error: ${provider.error}");
      } else {
        return ReusableBox(
          icon: Icons.wallet,
          label: "Cash in Hand",
          value: "৳ ${provider.cashInHand ?? 0}",
          borderColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.black,
          iconColor: Theme.of(context).colorScheme.primary,
        );
      }
    },
  ),
),

    hPad5,

 

Expanded(
  child: Consumer<DashboardReportProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: SizedBox());
      } else if (provider.error != null) {
        return Text("Error: ${provider.error}");
      } else {
        return ReusableBox(
          icon: Icons.account_balance,
          label: "Bank Balance",
          value: "৳ ${provider.bankBalance ?? 0}",
          borderColor: Colors.green,
          textColor: Colors.black,
          iconColor: Colors.green,
        );
      }
    },
  ),
),

                          // Expanded(
                          //   child: ReusableBox(
                          //     icon: Icons.account_balance,
                          //     label: "Bank",
                          //     value: "৳ 25,000,009",
                          //     borderColor: Colors.black,
                          //     textColor: Colors.black,
                          //     iconColor: colorScheme.primary,
                          //   ),
                          // ),
                          // hPad5,
                          // Expanded(
                          //   child: ReusableBox(
                          //     icon: Icons.person_3_outlined,
                          //     label: "Customer",
                          //     value: "৳ 80,200.000",
                          //     borderColor: Colors.black,
                          //     textColor: Colors.black,
                          //     iconColor: colorScheme.primary,
                          //   ),
                          // ),
                          hPad5,

                          // Expanded(
                          //   child: Consumer<DashboardReportProvider>(
                          //     builder: (context, provider, _) {
                          //       if (provider.isLoading) {
                          //         return const Center(
                          //             child: CircularProgressIndicator());
                          //       } else if (provider.error != null) {
                          //         return Text("Error: ${provider.error}");
                          //       } else {
                          //         return ReusableBox(
                          //           icon: Icons.wallet,
                          //           label: "Cash in Hand",
                          //           value: "৳ ${provider.cashInHand ?? 0}",
                          //           borderColor:
                          //               Theme.of(context).colorScheme.primary,
                          //           textColor: Colors.black,
                          //           iconColor:
                          //               Theme.of(context).colorScheme.primary,
                          //         );
                          //       }
                          //     },
                          //   ),
                          // ),

                          hPad5,

//                                          hPad5,
                        ],
                      ),

                      Consumer<DashboardReportProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const Center(child: SizedBox());
    } else if (provider.error != null) {
      return Text('Error: ${provider.error}');
    } else if (provider.voucherSummary == null) {
      return const Text('No data available');
    } else {
      final summary = provider.voucherSummary!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Received: ৳${summary.received}", style: TextStyle(fontSize: 12, color: Colors.black)),
          Text("Payment: ৳${summary.payment}", style: TextStyle(fontSize: 12, color: Colors.black)),
          Text("Income: ৳${summary.income}", style: TextStyle(fontSize: 12, color: Colors.black)),
          Text("Expense: ৳${summary.expense}", style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      );
    }
  },
),

                      
                      const SizedBox(
                        height: 8,
                      ),

                       
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ItemListPage()));

                        // showFeatureNotAvailableDialog(context);
                      },
                      child: _buildIconWithLabel(
                          Icons.apps, "Bulk sales/\nInvoice", context)),

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
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReceivedList()));
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
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PaymentOutList()));
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
                      // showDialog(
                      //     context: context,
                      //     builder: (context) =>
                      //         const FeatureNotAvailableDialog());
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Expanse()));
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
                        // showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         const FeatureNotAvailableDialog());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Income()));
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
