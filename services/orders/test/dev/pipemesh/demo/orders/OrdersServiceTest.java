package dev.pipemesh.demo.orders;

public final class OrdersServiceTest {
    public static void main(String[] args) {
        String out = OrdersService.describe();
        if (!(out.contains("17.49 EUR"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
