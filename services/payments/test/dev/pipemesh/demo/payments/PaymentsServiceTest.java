package dev.pipemesh.demo.payments;

public final class PaymentsServiceTest {
    public static void main(String[] args) {
        String out = PaymentsService.describe();
        if (!(out.contains("17.49 EUR"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
