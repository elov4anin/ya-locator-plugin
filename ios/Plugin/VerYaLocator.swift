import Foundation
import CoreTelephony
// import JavaScriptCore

extension Dictionary {
    func jsonString() -> NSString {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        guard jsonData != nil else {return ""}
        let jsonString = String(data: jsonData!, encoding: .utf8)
        guard jsonString != nil else {return ""}
        return jsonString! as NSString
    }

}


@objc public class VerYaLocator: NSObjectad {
    var result: [String: String] = [:]
    // var result1 = JSObjectRef
    var version: String = "1.0"
    var url: String = "https://api.lbs.yandex.net/geolocation"
    var apiKey: String = ""
    
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
    
    
    @objc public func prepareRequestData() -> Void {
        result["gsm_cells"] = getGsmCellLocation()
        result["wifi_networks"] = ""
    }
    
    @objc public func getGsmCellLocation() -> String {
        var json: [String: String] = [:]
        let telephonyInfo: CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        let carrier = telephonyInfo.serviceSubscriberCellularProviders?.first?.value
        let carrierName = carrier?.carrierName
        let mcc = carrier?.mobileCountryCode
        let mnc = carrier?.mobileNetworkCode
        let country = carrier?.isoCountryCode
      
        return jsonData.jsonString()
     /* json.put("country", telMgr.getSimCountryIso());
     json.put("operatorId", telMgr.getSimOperator());
     json.put("timestamp", calendar.getTimeInMillis());
     json.put("cid", gc.getCid());
     json.put("lac", gc.getLac());
     json.put("psc", gc.getPsc());
     json.put("mcc", mcc);
     json.put("mnc", mnc);
    
      
    }
    
    func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
}
