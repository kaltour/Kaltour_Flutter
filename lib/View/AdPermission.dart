import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';




// class AdPermission extends StatelessWidget {
//   // const AdPermission({super.key});
//
//   final bool isNotificationEnabled;
//   final ValueChanged<bool> onChanged;
//
//
//   AdPermission({
//     required this.isNotificationEnabled,
//     required this.onChanged
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     // bool isPermissionOff = !isNotificationEnabled;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("앱푸시AdPermission "),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Switch(
//               value: isNotificationEnabled,
//               onChanged: onChanged,
//               activeColor: Colors.blue,
//               activeTrackColor: Colors.lightBlueAccent,
//               inactiveThumbColor: Colors.grey,
//               inactiveTrackColor: Colors.grey[300],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
