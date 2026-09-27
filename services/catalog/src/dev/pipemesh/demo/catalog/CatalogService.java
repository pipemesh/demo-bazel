package dev.pipemesh.demo.catalog;



public final class CatalogService {
    private CatalogService() {}

    public static String describe() {
        return "{\"items\":43,\"from\":\"" + new dev.pipemesh.demo.money.Money(999, "EUR") + "\"}";
    }

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8085"));
        dev.pipemesh.demo.http.Server.start(port, "catalog", CatalogService::describe);
        System.out.println("catalog listening on " + port);
    }
}
