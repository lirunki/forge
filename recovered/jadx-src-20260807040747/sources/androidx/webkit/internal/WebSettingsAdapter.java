package androidx.webkit.internal;

import androidx.webkit.UserAgentMetadata;
import java.util.Set;
import org.chromium.support_lib_boundary.WebSettingsBoundaryInterface;

/* loaded from: classes.dex */
public class WebSettingsAdapter {
    private final WebSettingsBoundaryInterface mBoundaryInterface;

    public WebSettingsAdapter(WebSettingsBoundaryInterface boundaryInterface) {
        this.mBoundaryInterface = boundaryInterface;
    }

    public void setOffscreenPreRaster(boolean enabled) {
        this.mBoundaryInterface.setOffscreenPreRaster(enabled);
    }

    public boolean getOffscreenPreRaster() {
        return this.mBoundaryInterface.getOffscreenPreRaster();
    }

    public void setSafeBrowsingEnabled(boolean enabled) {
        this.mBoundaryInterface.setSafeBrowsingEnabled(enabled);
    }

    public boolean getSafeBrowsingEnabled() {
        return this.mBoundaryInterface.getSafeBrowsingEnabled();
    }

    public void setDisabledActionModeMenuItems(int menuItems) {
        this.mBoundaryInterface.setDisabledActionModeMenuItems(menuItems);
    }

    public int getDisabledActionModeMenuItems() {
        return this.mBoundaryInterface.getDisabledActionModeMenuItems();
    }

    public void setForceDark(int forceDarkMode) {
        this.mBoundaryInterface.setForceDark(forceDarkMode);
    }

    public int getForceDark() {
        return this.mBoundaryInterface.getForceDark();
    }

    public void setForceDarkStrategy(int forceDarkStrategy) {
        this.mBoundaryInterface.setForceDarkBehavior(forceDarkStrategy);
    }

    public int getForceDarkStrategy() {
        return this.mBoundaryInterface.getForceDarkBehavior();
    }

    public void setAlgorithmicDarkeningAllowed(boolean allow) {
        this.mBoundaryInterface.setAlgorithmicDarkeningAllowed(allow);
    }

    public boolean isAlgorithmicDarkeningAllowed() {
        return this.mBoundaryInterface.isAlgorithmicDarkeningAllowed();
    }

    public void setEnterpriseAuthenticationAppLinkPolicyEnabled(boolean enabled) {
        this.mBoundaryInterface.setEnterpriseAuthenticationAppLinkPolicyEnabled(enabled);
    }

    public boolean getEnterpriseAuthenticationAppLinkPolicyEnabled() {
        return this.mBoundaryInterface.getEnterpriseAuthenticationAppLinkPolicyEnabled();
    }

    public Set<String> getRequestedWithHeaderOriginAllowList() {
        return this.mBoundaryInterface.getRequestedWithHeaderOriginAllowList();
    }

    public void setRequestedWithHeaderOriginAllowList(Set<String> allowList) {
        this.mBoundaryInterface.setRequestedWithHeaderOriginAllowList(allowList);
    }

    public UserAgentMetadata getUserAgentMetadata() {
        return UserAgentMetadataInternal.getUserAgentMetadataFromMap(this.mBoundaryInterface.getUserAgentMetadataMap());
    }

    public void setUserAgentMetadata(UserAgentMetadata uaMetadata) {
        this.mBoundaryInterface.setUserAgentMetadataFromMap(UserAgentMetadataInternal.convertUserAgentMetadataToMap(uaMetadata));
    }

    public int getAttributionRegistrationBehavior() {
        return this.mBoundaryInterface.getAttributionBehavior();
    }

    public void setAttributionRegistrationBehavior(int behavior) {
        this.mBoundaryInterface.setAttributionBehavior(behavior);
    }
}
