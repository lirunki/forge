package com.capacitorjs.plugins.statusbar;

/* loaded from: classes2.dex */
public class StatusBarInfo {
    private String color;
    private boolean overlays;
    private String style;
    private boolean visible;

    public boolean isOverlays() {
        return this.overlays;
    }

    public void setOverlays(boolean overlays) {
        this.overlays = overlays;
    }

    public boolean isVisible() {
        return this.visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    public String getStyle() {
        return this.style;
    }

    public void setStyle(String style) {
        this.style = style;
    }

    public String getColor() {
        return this.color;
    }

    public void setColor(String color) {
        this.color = color;
    }
}
