// firestore_index_handler.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aswenna/core/utils/color_utils.dart';

class FirestoreIndexHandler {
  // Extract URL from error message
  static String? extractIndexUrlFromError(dynamic error) {
    final errorMessage = error?.toString() ?? '';

    // Check if this is an index-related error
    if (errorMessage.contains('The query requires an index') &&
        errorMessage.contains('You can create it here:')) {
      // Extract the URL using regex
      final RegExp urlRegex = RegExp(
        r'https:\/\/console\.firebase\.google\.com\/v1\/r\/project\/.*?(?=\s|$)',
        caseSensitive: false,
      );

      final match = urlRegex.firstMatch(errorMessage);
      if (match != null) {
        return match.group(0);
      }
    }

    return null;
  }

  // Handle index errors by showing a dialog to the user
  static Future<void> handleIndexError(
    BuildContext context,
    dynamic error,
  ) async {
    final indexUrl = extractIndexUrlFromError(error);

    if (indexUrl != null) {
      return showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Index Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This query requires a Firestore index to be created.',
                    style: TextStyle(fontSize: 16, color: AppColors.text),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Would you like to create it now?',
                    style: TextStyle(fontSize: 15, color: AppColors.textLight),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: indexUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL copied to clipboard')),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Copy URL',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _launchIndexUrl(indexUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Create Index'),
                ),
              ],
            ),
      );
    }

    // If it's not an index error, just show a regular error message
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            content: Text(
              error?.toString() ?? 'An unknown error occurred',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  // Launch URL to create the index
  static Future<void> _launchIndexUrl(String url) async {
    try {
      // Clean up the URL - sometimes there can be issues with encoding
      url = url.trim();

      // Print for debugging
      print('Attempting to launch URL: $url');

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        // Try with different launch modes
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          // If external app mode fails, try with in-app browser
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching index URL: $e');
    }
  }
}
