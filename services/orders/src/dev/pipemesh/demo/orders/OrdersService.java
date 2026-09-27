package dev.pipemesh.demo.orders;

import dev.pipemesh.demo.events.Event;
import dev.pipemesh.demo.money.Money;

public final class OrdersService {
    private OrdersService() {}

    public static String describe() {
        return "{\"total\":\"" + new Money(1250, "EUR").plus(new Money(499, "EUR")) + "\",\"event\":\"" + Event.of("order.placed", "o-1").type() + "\"}";
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8081"));
        dev.pipemesh.demo.http.Server.start(port, "orders", OrdersService::describe);
        System.out.println("orders listening on " + port);
    }
}
