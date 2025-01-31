// ChatPanel.dart
import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/widgets/ChattingArea.dart';

class ChatPanel extends StatelessWidget {
 final VoidCallback onTogglePanel;
 final bool isPanelVisible;
 const ChatPanel({
   super.key,
   required this.onTogglePanel,
   required this.isPanelVisible,
 });

 @override
 Widget build(BuildContext context) {
   return SafeArea(
     child: Container(
       decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.surfaceContainerHigh,
         borderRadius: BorderRadius.circular(12),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Toggle button and Title
           Padding(
             padding: const EdgeInsets.all(12.0),
             child: Row(
               children: [
                 IconButton(
                   onPressed: onTogglePanel,
                   icon: Icon(
                     isPanelVisible ? Icons.chevron_left : Icons.chevron_right,
                   ),
                   tooltip: isPanelVisible ? 'Hide Panel' : 'Show Panel',
                 ),
                 Expanded(
                   child: Center(
                     child: Text(
                       'Chat Name',
                       style: Theme.of(context).textTheme.titleMedium,
                     ),
                   ),
                 ),
                 // Placeholder to balance the row
                 const SizedBox(width: 48),
               ],
             ),
           ),
           const Expanded(
             child: Padding(
               padding: EdgeInsets.all(12),
               child: ChattingArea(),
             ),
           ),
         ],
       ),
     ),
   );
 }
}
