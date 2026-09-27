package dev.pipemesh.demo.events;

import java.time.Instant;

/** The envelope services publish and consume: what happened, to what, when. */
public record Event(String type, String subject, Instant at, String source) {
    public static Event of(String type, String subject) {
        return new Event(type, subject, Instant.now(), "demo");
    }
}
