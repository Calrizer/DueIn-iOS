//
//  Tools.swift
//  Due In
//
//  Created by Callum Drain on 23/12/2016.
//  Copyright © 2016 Due In. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Tools {
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func convertDate(date: String) -> String {
        
        var start = date.index(date.startIndex, offsetBy: 0)
        var end = date.index(date.endIndex, offsetBy: -15)
        var range = start..<end
        
        let year = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 5)
        end = date.index(date.endIndex, offsetBy: -12)
        range = start..<end
        
        let month = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 8)
        end = date.index(date.endIndex, offsetBy: -9)
        range = start..<end
        
        let day = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 11)
        end = date.index(date.endIndex, offsetBy: -6)
        range = start..<end
        
        let hour = date.substring(with: range)
        
        start = date.index(date.startIndex, offsetBy: 14)
        end = date.index(date.endIndex, offsetBy: -3)
        range = start..<end
        
        let minute = date.substring(with: range)
        
        return day + "/" + month + "/" + year + " at " + hour + ":" + minute
    }
}
