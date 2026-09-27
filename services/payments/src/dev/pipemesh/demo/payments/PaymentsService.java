package dev.pipemesh.demo.payments;

import dev.pipemesh.demo.money.Money;

public final class PaymentsService {
    private PaymentsService() {}

    public static String describe() {
        return "{\"captured\":\"" + new Money(1749, "EUR") + "\"}";
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8082"));
        dev.pipemesh.demo.http.Server.start(port, "payments", PaymentsService::describe);
        System.out.println("payments listening on " + port);
    }
}
