import { broadcastNotification } from "@/lib/api/admin";

export type Notification = {
  id: string;
  title: string;
  body: string;
  type: "system" | "order" | "promo" | "news";
  target_type: "all" | "users" | "vendors" | "specific";
  is_sent: boolean;
  created_at: string;
  [key: string]: any;
};

export async function getNotifications(): Promise<Notification[]> {
  // Notifications are managed via broadcast endpoint
  return [];
}

export async function getNotificationStats(): Promise<{ total: number; sent: number; pending: number }> {
  return { total: 0, sent: 0, pending: 0 };
}

export async function createNotification(data: Partial<Notification>): Promise<void> {
  await broadcastNotification({
    title: data.title || '',
    body: data.body || '',
    type: data.type,
    targetRole: data.target_type === 'all' ? undefined : data.target_type === 'users' ? 'customer' : 'vendor',
  });
}

export async function sendNotification(id: string): Promise<void> {
  // Already sent on creation
  console.log('Notification already sent:', id);
}

export async function deleteNotification(_id: string): Promise<void> {
  return;
}