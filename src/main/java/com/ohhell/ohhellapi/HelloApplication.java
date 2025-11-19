package com.ohhell.ohhellapi;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;
import java.util.Set;

@ApplicationPath("/api")
public class HelloApplication extends Application {
    
    @Override
    public Set<Class<?>> getClasses() {
        return Set.of(
            com.ohhell.ohhellapi.resources.HelloResource.class,
            com.ohhell.ohhellapi.resources.TestDatabaseResource.class
        );
    }
}
