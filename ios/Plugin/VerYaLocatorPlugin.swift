import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(VerYaLocatorPlugin)
public class VerYaLocatorPlugin: CAPPlugin {
    private let implementation = VerYaLocator()
    
    @objc func requestCoordinates(_ call: CAPPluginCall) {
            let url = call.getString("url") ?? "1.0"
            let version = call.getString("url") ?? "https://api.lbs.yandex.net/geolocation"
            let apiKey = call.getString("api_key") ?? ""
        
            let res = implementation.requestCoordinates(url: url, version: version, apiKey: apiKey)
        
        
            self.notifyListeners("currentLocation", data: ["test": res])
            call.resolve([
                "value": res
            ])
    }
    /*
    @objc override public func checkPermissions(_ call: CAPPluginCall) {
           // TODO
   }

   @objc override public func requestPermissions(_ call: CAPPluginCall) {
    // TODO
   }
     */
}
