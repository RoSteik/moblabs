// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: RockQuestionWidget(),
//     );
//   }
// }
//
//
//
// class RockQuestionWidget extends StatefulWidget {
//   const RockQuestionWidget({super.key});
//
//   @override
//   State<RockQuestionWidget> createState() => _RockQuestionWidgetState();
// }
//
// class _RockQuestionWidgetState extends State<RockQuestionWidget> {
//   String _displayText = 'Do you like rock?';
//   bool _showLink = false;
//   final TextEditingController _controller = TextEditingController();
//
//   void _updateDisplayText() {
//     setState(() {
//       if (_controller.text.trim().toLowerCase() == 'linkin park') {
//         _displayText = 'Oh you have taste in music!';
//         _showLink = false;
//       } else {
//         _displayText = 'Give me a normal rock group name';
//         _showLink = true;
//       }
//     });
//   }
//
//
//   Future<void> _launchURL() async {
//     final Uri url = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ'); // Rickroll link
//     if (!await launchUrl(url)) {
//       throw 'Could not launch $url';
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Music Taste'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_displayText, style: const TextStyle(fontSize: 20)),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: TextField(
//                 key: const Key('responseField'),
//                 controller: _controller,
//                 decoration: const InputDecoration(
//                   labelText: 'Your answer',
//                 ),
//                 onSubmitted: (_) => _updateDisplayText(),
//               ),
//             ),
//             if (_showLink) // Display link if _showLink is true
//               GestureDetector(
//                 onTap: _launchURL,
//                 child: const Text(
//                   'Discover more here!',
//                   style: TextStyle(fontSize: 18, color: Colors.blue,
//                       decoration: TextDecoration.underline,),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
