package dev.pipemesh.demo.money;

/** Amounts in minor units (cents), one currency per value. */
public record Money(long cents, String currency) {
    public Money plus(Money other) {
        if (!currency.equals(other.currency)) throw new IllegalArgumentException("currency mismatch");
        return new Money(cents + other.cents, currency);
    }

    public Money minus(Money other) {
        return plus(new Money(-other.cents, other.currency));
    }

    @Override
    public String toString() {
        return String.format("%d.%02d %s", cents / 100, cents % 100, currency);
    }
}
