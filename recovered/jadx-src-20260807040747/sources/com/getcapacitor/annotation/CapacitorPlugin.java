package com.getcapacitor.annotation;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
/* loaded from: classes2.dex */
public @interface CapacitorPlugin {
    String name() default "";

    Permission[] permissions() default {};

    int[] requestCodes() default {};
}
