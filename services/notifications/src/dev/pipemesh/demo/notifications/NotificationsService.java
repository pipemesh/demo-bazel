package dev.pipemesh.demo.notifications;

import dev.pipemesh.demo.events.Event;

public final class NotificationsService {
    private NotificationsService() {}

    public static String describe() {
        return "{\"sent\":\"" + Event.of("email.sent", "u-7").type() + "\"}";
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8084"));
        dev.pipemesh.demo.http.Server.start(port, "notifications", NotificationsService::describe);
        System.out.println("notifications listening on " + port);
    }
}
