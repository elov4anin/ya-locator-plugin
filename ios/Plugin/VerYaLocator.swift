import Foundation
import CoreTelephony
import Network
import NetworkExtension
import SystemConfiguration.CaptiveNetwork


public class EnumerateNetworkInterfaces {
  public struct NetworkInterfaceInfo {
  let name: String
  let ip: String
  let netmask: String
}

public static func enumerate() -> [NetworkInterfaceInfo] {
  var interfaces = [NetworkInterfaceInfo]()

  // Get list of all interfaces on the local machine:
  var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
  if getifaddrs(&ifaddr) == 0 {

    // For each interface ...
    var ptr = ifaddr
    while( ptr != nil) {

      let flags = Int32(ptr!.pointee.ifa_flags)
      var addr = ptr!.pointee.ifa_addr.pointee

      // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
      if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
        if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {

          var mask = ptr!.pointee.ifa_netmask.pointee

          // Convert interface address to a human readable string:
          let zero  = CChar(0)
          var hostname = [CChar](repeating: zero, count: Int(NI_MAXHOST))
          var netmask =  [CChar](repeating: zero, count: Int(NI_MAXHOST))
          if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
            let address = String(cString: hostname)
            let name = ptr!.pointee.ifa_name!
            let ifname = String(cString: name)


            if (getnameinfo(&mask, socklen_t(mask.sa_len), &netmask, socklen_t(netmask.count),
              nil, socklen_t(0), NI_NUMERICHOST) == 0) {
              let netmaskIP = String(cString: netmask)

              let info = NetworkInterfaceInfo(name: ifname,
                ip: address,
                netmask: netmaskIP)
              interfaces.append(info)
            }
          }
        }
      }
      ptr = ptr!.pointee.ifa_next
    }
    freeifaddrs(ifaddr)
  }
  return interfaces
}
}




@objc public class VerYaLocator: NSObject {
    
    @objc public func requestCoordinates(url: String, version: String, apiKey: String) -> [String: Any] {
        var networkLocation: [String: Any] = [String:Any]()
        var currentNetworkInfo: [String: Any] = [:]

        getNetworkInfo { (wifiInfo) in
                       
          currentNetworkInfo = wifiInfo
           
        }
        networkLocation["gsm_cells"] = getGsmCellLocation()
        networkLocation["wifi_networks"] = currentNetworkInfo
        return networkLocation
    }
    
    func getGsmCellLocation() -> [String: Any] {
        var jsonObject: [String: Any] = [String:Any]()
        let networkStatus = CTTelephonyNetworkInfo()
        
       // CarrierNetwork = telephonyInfo.serviceCurrentRadioAccessTechnology?.first?.value ?? "null"//
       //  carrierNetwork = carrierNetwork.replacingOccurrences(of: "CTRadioAccessTechnology", with: "", options: NSString.CompareOptions.literal, range: nil)

        let carrier = networkStatus.serviceSubscriberCellularProviders?.first?.value
        
        jsonObject["mnc"] = (String(describing: carrier?.mobileNetworkCode) ) // 20
        jsonObject["mcc"] = (String(describing: carrier?.mobileCountryCode) ) // 250
        jsonObject["isoCountryCode"] = (String(describing: carrier?.isoCountryCode) ) // ru
        jsonObject["carrierName"] = (String(describing: carrier?.carrierName) ) // Tele2
        
        print("jsonObject ssid 00", carrier?.mobileNetworkCode);
        print("jsonObject", jsonObject);
        return jsonObject
    }
    
    func getNetworkInfo(compleationHandler: @escaping ([String: Any])->Void){
        
       var currentWirelessInfo: [String: Any] = [:]
        
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                
                guard let network = network else {
                    compleationHandler([:])
                    return
                }
                
                
                let bssid = network.bssid
                let ssid = network.ssid
               // let mac = UIDevice.current.identifierForVendor?.uuidString ?? ""
                for interface in EnumerateNetworkInterfaces.enumerate() {
                    print("\(interface.name):  \(interface.ip)")
                }
                currentWirelessInfo = [
                    "mac": bssid,
                    "ip": EnumerateNetworkInterfaces.enumerate().first?.ip ?? "",
                    "BSSID": bssid,
                    "SSID": ssid,
                    "SSIDDATA": "<54656e64 615f3443 38354430>"
                ]
                compleationHandler(currentWirelessInfo)
            }
        }
        else {
            #if !TARGET_IPHONE_SIMULATOR
            guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
                compleationHandler([:])
                return
            }
            
            guard let name = interfaceNames.first, let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String: Any] else {
                compleationHandler([:])
                return
            }
            
            currentWirelessInfo = info
            
            #else
            currentWirelessInfo = ["BSSID ": "c8:3a:35:4c:85:d0", "SSID": "Tenda_4C85D0", "SSIDDATA": "<54656e64 615f3443 38354430>"]
            #endif
            compleationHandler(currentWirelessInfo)
        }
    }
    
    func sendPost(url: String, body: [String: Any], apiKey: String, version: String) {
            let Url = String(format: url)
            let _: [String: Any] = [
                "version": version,
                "api_key": apiKey
            ]
        
            guard let serviceUrl = URL(string: Url) else { return }
            let parameters: [String: Any] = [
                "request": body
            ]
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 20
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
}


    
