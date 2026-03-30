import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppPhotoSlot extends StatelessWidget {
  final String title;
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onTapCapture;
  final VoidCallback? onTapRetake;
  final VoidCallback? onTapRemove;
  final bool isRequired;

  const AppPhotoSlot({
    super.key,
    required this.title,
    this.imageFile,
    this.imageUrl,
    required this.onTapCapture,
    this.onTapRetake,
    this.onTapRemove,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageFile != null || imageUrl != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (isRequired) const Text(' *', style: const TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, style: hasImage ? BorderStyle.solid : BorderStyle.none),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!hasImage)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: onTapCapture,
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCamera01,
                      color: Colors.black87,
                      size: 20,
                    ),
                    label: const Text('Ambil Foto/Kamera'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      elevation: 1,
                    ),
                  ),
                )
              else ...[
                if (imageFile != null)
                  Image.file(imageFile!, fit: BoxFit.cover, width: double.infinity)
                else if (imageUrl != null)
                  Image.network(imageUrl!, fit: BoxFit.cover, width: double.infinity),
                  
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    children: [
                      if (onTapRetake != null)
                        CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 18,
                          child: IconButton(
                            iconSize: 20,
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedRefresh,
                              color: Colors.black87,
                              size: 20,
                            ),
                            onPressed: onTapRetake
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (onTapRemove != null)
                        CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 18,
                          child: IconButton(
                            iconSize: 20,
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: onTapRemove
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ],
    );
  }
}
