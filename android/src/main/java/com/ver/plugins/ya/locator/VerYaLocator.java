package com.ver.plugins.ya.locator;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.telephony.TelephonyManager;
import android.telephony.gsm.GsmCellLocation;

import com.getcapacitor.JSObject;
import com.ver.plugins.ya.locator.interfaces.LocationInterface;
import com.ver.plugins.ya.locator.interfaces.PostCallbackInterface;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Calendar;

public class VerYaLocator implements LocationInterface {
    public JSObject result = new JSObject();
    public String version = "1.0";
    public String url = "https://api.lbs.yandex.net/geolocation";
    public String apiKey = "";

    private final Context context;

    public VerYaLocator(Context context) {
        this.context = context;
    }

    public void prepareRequestData()
    {
        this.result.put("gsm_cells", this.getGsmCellLocation());
        this.result.put("wifi_networks", this.getCurrentNetworkInfo());
    }

    public void sendPost(final PostCallbackInterface callbackInterface) {
        Thread thread = new Thread(() -> {
            try {
                URL url = new URL(VerYaLocator.this.url);
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
                conn.setRequestProperty("Accept","application/json");
                conn.setDoOutput(true);
                conn.setDoInput(true);
                conn.setConnectTimeout(10000);
                conn.setReadTimeout(10000);

                JSONObject jsonParam = new JSONObject();

                JSONObject commonObj = new JSONObject();
                commonObj.put("version", VerYaLocator.this.version);
                commonObj.put("api_key", VerYaLocator.this.apiKey);
                jsonParam.put("common", commonObj);

                JSObject gsm_cells = (JSObject) VerYaLocator.this.result.get("gsm_cells");
                if (gsm_cells.has("country")) {
                    JSONArray gsmCellsList = new JSONArray();
                    JSONObject gsmCellObj = new JSObject();
                    gsmCellObj.put("countrycode", gsm_cells.get("country"));
                    gsmCellObj.put("operatorid", gsm_cells.get("operatorId"));
                    gsmCellObj.put("cellid", gsm_cells.get("cid"));
                    gsmCellObj.put("lac", gsm_cells.get("lac"));
                    gsmCellsList.put(gsmCellObj);
                    jsonParam.put("gsm_cells", gsmCellsList);
                }

                JSObject wifi_networks = (JSObject) VerYaLocator.this.result.get("wifi_networks");
                if (wifi_networks.has("mac")) {
                    JSONArray networkCellsList = new JSONArray();
                    JSONObject networkCellObj = new JSObject();
                    networkCellObj.put("mac", wifi_networks.get("mac"));
                    networkCellsList.put(networkCellObj);
                    jsonParam.put("wifi_networks", networkCellsList);
                }

                DataOutputStream os = new DataOutputStream(conn.getOutputStream());
                //os.writeBytes(URLEncoder.encode(jsonParam.toString(), "UTF-8"));
                os.writeBytes("json=" + jsonParam.toString());

                os.flush();
                os.close();

                String response = "";
                BufferedReader br;
                if (200 <= conn.getResponseCode() && conn.getResponseCode() <= 299) {
                    br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    for (String line; (line = br.readLine()) != null; response += line.trim());
                } else {
                    br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                    response = conn.getResponseMessage();
                }

                callbackInterface.success(String.valueOf(conn.getResponseCode()), response);

                conn.disconnect();
            } catch (Exception e) {
                e.printStackTrace();
            }
        });

        thread.start();
    }


    public JSObject getGsmCellLocation() {
        final Calendar calendar = Calendar.getInstance();
        TelephonyManager telMgr = (TelephonyManager) context
                .getApplicationContext().getSystemService(Context.TELEPHONY_SERVICE);
        final JSObject json = new JSObject();

        if (telMgr == null) {
            return json;
        }

        @SuppressLint("MissingPermission")
        GsmCellLocation gc = (GsmCellLocation) telMgr.getCellLocation();

        if(gc != null){
            String operator = telMgr.getNetworkOperator();
            int mcc = Integer.parseInt(operator.substring(0, 3));
            int mnc = Integer.parseInt(operator.substring(3));

            json.put("country", telMgr.getSimCountryIso());
            json.put("operatorId", telMgr.getSimOperator());
            json.put("timestamp", calendar.getTimeInMillis());
            json.put("cid", gc.getCid());
            json.put("lac", gc.getLac());
            json.put("psc", gc.getPsc());
            json.put("mcc", mcc);
            json.put("mnc", mnc);
        }

        return json;
    }

    @SuppressLint("HardwareIds")
    public JSObject getCurrentNetworkInfo() {
        final JSObject json = new JSObject();
        ConnectivityManager cm = (ConnectivityManager) context
                .getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        if (cm == null) {
            return json;
        }

        NetworkInfo networkInfo = cm.getActiveNetworkInfo();
        if (networkInfo == null) {
            return json;
        }

        if (networkInfo.isConnected()) {
            final WifiManager wifiManager = (WifiManager) context
                    .getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            if (wifiManager == null) {
                return json;
            }

            final WifiInfo connectionInfo = wifiManager.getConnectionInfo();
            if (connectionInfo != null && connectionInfo.getSSID() != null) {
                json.put("ssid", connectionInfo.getSSID());
                json.put("mac", connectionInfo.getMacAddress());
                json.put("ip", connectionInfo.getIpAddress());
            }
        }

        return json;
    }
}
