import 'package:cbook_dt/feature/settings/ui/bill/bill_create.dart';
import 'package:cbook_dt/feature/settings/ui/bill/provider/bill_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillPersonList extends StatefulWidget {
  const BillPersonList({super.key});

  @override
  State<BillPersonList> createState() => _BillPersonListState();
}

class _BillPersonListState extends State<BillPersonList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<BillPersonProvider>(context, listen: false)
            .fetchBillPersons());
  }

  TextStyle ts =
      const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  TextStyle ts2  = TextStyle(color: Colors.black, fontSize: 12);    
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        //centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // ignore: prefer_const_constructors
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            const Text(
              'Bill Person',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BillCreate()));
              },
              child: const Row(
                children: [
                  CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    'Add bill person',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(children: [

        Consumer<BillPersonProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(child: Text(provider.errorMessage));
    }

    if (provider.billPersons.isEmpty) {
      return Center(
          child: Text(
        'No Bill Persons Found',
        style: ts,
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // 🔥 Zero padding
      itemCount: provider.billPersons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 1), // 🔥 Zero space between items
      itemBuilder: (context, index) {
        final person = provider.billPersons[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300, // Optional: background color
          ),
          child: ListTile(
            dense: true, // 🔥 Makes the tile more compact
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // 🔥 Minimal padding inside ListTile
            leading: person.avatar != null
                ? Image.network(
                    'https://commercebook.site/${person.avatar}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover)
                : const Icon(Icons.person),
            title: Text(person.name, style: ts2),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.phone, style: ts2),
                Text(person.email ?? '', style: ts2),
              ],
            ),
          ),
        );
      },
    );
  },
),



        // Consumer<BillPersonProvider>(
        //   builder: (context, provider, child) {
        //     if (provider.isLoading) {
        //       return const Center(child: CircularProgressIndicator());
        //     }

        //     if (provider.errorMessage.isNotEmpty) {
        //       return Center(child: Text(provider.errorMessage));
        //     }

        //     if (provider.billPersons.isEmpty) {
        //       return Center(
        //           child: Text(
        //         'No Bill Persons Found',
        //         style: ts,
        //       ));
        //     }

        //     return ListView.builder(
        //       shrinkWrap: true,
        //       itemCount: provider.billPersons.length,
        //       itemBuilder: (context, index) {
        //         final person = provider.billPersons[index];


        //         return Card(
        //           elevation: 0,
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(2)),
        //           child: ListTile(
        //             leading: person.avatar != null
        //                 ? Image.network(
        //                     'https://commercebook.site/${person.avatar}',
        //                     width: 40,
        //                     height: 40,
        //                     fit: BoxFit.cover)
        //                 : SizedBox(
        //                   width: 40,
        //                   height: 40,
        //                   child: const Icon(Icons.person)),
        //             title: Text(person.name, style: ts2,),
        //             subtitle: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(person.phone, style: ts2,),
        //                 Text(person.email!, style: ts2,),
        //               ],  
        //             ),
        //           ),
        //         );
        //       },
        //     );
        //   },
        // ),
      
      
      ]),
    );
  }
}
