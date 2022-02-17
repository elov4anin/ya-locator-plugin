package com.ver.plugins.ya.locator.interfaces;

import com.getcapacitor.JSObject;

public interface LocationInterface {
    public JSObject getCurrentNetworkInfo();
    public JSObject getGsmCellLocation();
    public void sendPost(final PostCallbackInterface callbackInterface);
    public void prepareRequestData();
}
