package dev.pipemesh.demo.notifications;

public final class NotificationsServiceTest {
    public static void main(String[] args) {
        String out = NotificationsService.describe();
        if (!(out.contains("email.sent"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
