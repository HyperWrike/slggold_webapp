import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

// Set up default notification behavior
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export class NotificationService {
  static async initialize(): Promise<void> {
    if (Platform.OS === 'web') return;

    try {
      const { status: existingStatus } = await Notifications.getPermissionsAsync();
      let finalStatus = existingStatus;

      if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
      }

      if (finalStatus !== 'granted') {
        console.warn('Notification permission not granted.');
        return;
      }

      if (Platform.OS === 'android') {
        await Notifications.setNotificationChannelAsync('slg_notifications_channel', {
          name: 'General Notifications',
          importance: Notifications.AndroidImportance.MAX,
          vibrationPattern: [0, 250, 250, 250],
          lightColor: '#208AEF',
        });
      }
    } catch (e) {
      console.error('Failed to initialize notifications service:', e);
    }
  }

  static async showNotification(title: string, body: string, data?: Record<string, any>): Promise<void> {
    if (Platform.OS === 'web') {
      // In Web, we can show a web notification or standard browser alert / custom toast
      if ('Notification' in window && Notification.permission === 'granted') {
        new Notification(title, { body });
      } else {
        console.log(`Notification (fallback): [${title}] ${body}`);
      }
      return;
    }

    try {
      await Notifications.scheduleNotificationAsync({
        content: {
          title,
          body,
          data: data || {},
          sound: true,
        },
        trigger: null, // show immediately
      });
    } catch (e) {
      console.error('Failed to display notification:', e);
    }
  }

  static async requestWebPermissions(): Promise<void> {
    if (Platform.OS === 'web' && 'Notification' in window) {
      if (Notification.permission !== 'granted' && Notification.permission !== 'denied') {
        await Notification.requestPermission();
      }
    }
  }
}
