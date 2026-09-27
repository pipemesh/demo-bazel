package dev.pipemesh.demo.inventory;

import dev.pipemesh.demo.events.Event;

public final class InventoryService {
    private InventoryService() {}

    public static String describe() {
        return "{\"reserved\":3,\"event\":\"" + Event.of("stock.reserved", "sku-9").type() + "\"}";
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8083"));
        dev.pipemesh.demo.http.Server.start(port, "inventory", InventoryService::describe);
        System.out.println("inventory listening on " + port);
    }
}
