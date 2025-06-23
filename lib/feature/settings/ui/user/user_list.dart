import 'package:cbook_dt/feature/settings/provider/setting_user_provider.dart';

import 'package:cbook_dt/feature/settings/ui/user/user_add.dart';
import 'package:cbook_dt/feature/settings/ui/user/user_details.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCeate extends StatelessWidget {
  const UserCeate({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final userSettingProvider = Provider.of<SettingUserProvider>(context);

    return Scaffold(
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
              'User',
              style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const UserAdd()));
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
                    'Add user',
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
      body: userSettingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userSettingProvider.hasError
              ? const Center(
                  child: Text(
                  "Something went wrong.",
                  style: TextStyle(color: Colors.black),
                ))
              : userSettingProvider.users.isEmpty
                  ? const Center(
                      child: Text(
                      "No user found.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ))
                  : ListView.builder(
                      itemCount: userSettingProvider.users.length,
                      itemBuilder: (ctx, index) {
                        final user = userSettingProvider.users[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsPage(user: user),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CircleAvatar(
                                  backgroundImage: user.avatar != null
                                      ? NetworkImage(
                                          'https://commercebook.site/${user.avatar}')
                                      : const AssetImage(
                                              'assets/images/avatar_placeholder.png')
                                          as ImageProvider,
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user.nickName != null)
                                    Text("${user.nickName!}",
                                        style: const TextStyle(fontSize: 12)),
                                  Text("${user.email}",
                                      style: const TextStyle(fontSize: 12)),
                                  Text("${user.phone}",
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Handle Edit
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Text(
                                          "Are you sure you want to delete ${user.name}?",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Implement delete logic
                                              // Navigator.pop(ctx);
                                            },
                                            child: const Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

      
    );
  }
}
