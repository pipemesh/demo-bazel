package dev.pipemesh.demo.orders;

public final class OrdersServiceTest {
    public static void main(String[] args) {
        String out = OrdersService.describe();
        if (!(out.contains("17.49 EUR"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
// Orders' tests pin the receipt format.
// Probe for pipemesh/pipemesh#791: a PR that touches orders runs Bazel, to time its cache.
