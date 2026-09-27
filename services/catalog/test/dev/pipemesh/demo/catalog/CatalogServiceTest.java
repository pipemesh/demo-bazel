package dev.pipemesh.demo.catalog;

public final class CatalogServiceTest {
    public static void main(String[] args) {
        String out = CatalogService.describe();
        if (!(out.contains("\"items\":44"))) throw new AssertionError("unexpected: " + out);
        System.out.println("ok: " + out);
    }
}
