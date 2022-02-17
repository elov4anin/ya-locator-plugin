package com.ver.plugins.ya.locator;

import android.Manifest;
import com.getcapacitor.JSObject;
import com.getcapacitor.PermissionState;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;

import java.util.Objects;

@CapacitorPlugin(
        name = "VerYaLocator",
        permissions = {
                @Permission(
                        alias = "location",
                        strings = {
                                Manifest.permission.ACCESS_FINE_LOCATION,
                                Manifest.permission.ACCESS_COARSE_LOCATION,
                        }
                ),
                @Permission(
                        alias = "network",
                        strings = {
                                Manifest.permission.ACCESS_NETWORK_STATE,
                                Manifest.permission.ACCESS_WIFI_STATE,
                                Manifest.permission.INTERNET
                        }
                )
        }
)
public class VerYaLocatorPlugin extends Plugin {
    private VerYaLocator locator;
    // static final int REQUEST_LOCATION_PERMISSION = 9874;
    // private VerYaLocator implementation = new VerYaLocator();

    @PluginMethod
    public void requestCoordinates(PluginCall call) {
        locator = new VerYaLocator(getContext());

        if (!Objects.requireNonNull(call.getString("version")).isEmpty()) {
            locator.version = call.getString("version");
        }

        if (!Objects.requireNonNull(call.getString("url")).isEmpty()) {
            locator.url = call.getString("url");
        }

        if (!Objects.requireNonNull(call.getString("api_key")).isEmpty()) {
            locator.apiKey = call.getString("api_key");
        }

        if (getPermissionState("location") == PermissionState.GRANTED && getPermissionState("network") == PermissionState.GRANTED) {
            this.prepareRequestData(call);
        } else {
            requestAllPermissions(call, "aliasesPermsCallback");
        }

        JSObject ret = new JSObject();
        ret.put("result", "success");
        call.resolve(ret);
    }

    @PermissionCallback
    private void aliasesPermsCallback(PluginCall call) {
        if (getPermissionState("location") == PermissionState.GRANTED && getPermissionState("network") == PermissionState.GRANTED) {
            this.prepareRequestData(call);
        } else {
            call.reject("Permission is required to take a current location");
        }
    }

    private void prepareRequestData(PluginCall call)
    {
        this.locator.prepareRequestData();

        this.locator.sendPost((code, message) -> {
            JSObject ret = new JSObject();
            ret.put("code", code);
            ret.put("data", message);
            notifyListeners("currentLocationByGsm", ret);
        });

        call.resolve(this.locator.result);
    }
}
