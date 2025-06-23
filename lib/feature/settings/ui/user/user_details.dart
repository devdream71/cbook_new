import 'package:flutter/material.dart';
// Import your user model if needed

class UserDetailsPage extends StatelessWidget {
  final user;

  const UserDetailsPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(user.name),
      // ),
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          user.name,
          style: const TextStyle(
              color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 30,
                backgroundImage: user.avatar != null
                    ? NetworkImage('https://commercebook.site/${user.avatar}')
                    : const AssetImage('assets/images/avatar_placeholder.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text('${user.name}',
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            if (user.nickName != null)
              Text('${user.nickName}',
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
            Text('${user.email}',
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            Text('${user.phone}',
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            Text('${user.createdDate}',
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            Text('${user.status == 1 ? "Active" : "Inactive"}',
                style: const TextStyle(fontSize: 12, color: Colors.black)),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
