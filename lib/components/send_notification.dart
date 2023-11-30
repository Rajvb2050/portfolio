import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

mixin NotificationMixin {
  Future<void> sendNotificationToAllUsers(
    String? heading,
    String? subtitle,
    String message,
    QuerySnapshot snap,
  ) async {
    bool userProvidedPrivacyConsent =
        await OneSignal.shared.userProvidedPrivacyConsent();
    if (!userProvidedPrivacyConsent) {
      print(
          "User has not provided privacy consent yet. Cannot send notification.");
      return;
    }
    QuerySnapshot userSnapshot = snap;
    List<String> playerIds = [];
    for (var doc in userSnapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      String? playerId = userData['notification_token'] as String?;
      if (playerId != null) {
        playerIds.add(playerId);
      }
    }
    if (playerIds.isNotEmpty) {
      await OneSignal.shared.postNotification(
        OSCreateNotification(
          playerIds: playerIds,
          heading: heading,
          subtitle: subtitle,
          content: message,
          androidSmallIcon: '@mipmap/notification_icon',
        ),
      );
    }
  }
}
