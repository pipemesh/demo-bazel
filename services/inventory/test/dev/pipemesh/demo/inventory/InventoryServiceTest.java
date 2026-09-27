package dev.pipemesh.demo.inventory;

public final class InventoryServiceTest {
    public static void main(String[] args) {
        String out = InventoryService.describe();
        if (!(out.contains("stock.reserved"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
