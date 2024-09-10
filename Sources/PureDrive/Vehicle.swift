//
//  Advertisement.swift
//  PureDrive
//
//  Created by Lrdsnow on 8/22/24.
//

import Foundation
import CoreBluetooth

public let ankiServiceUUID = UUID(uuidString: "BE15BEEF-6186-407E-8381-0BD89C4D8DF4")!

public let ankiChrReadUUID = UUID(uuidString: "BE15BEE0-6186-407E-8381-0BD89C4D8DF4")!
public let ankiChrWriteUUID = UUID(uuidString: "BE15BEE1-6186-407E-8381-0BD89C4D8DF4")!

public func carName(_ modelId: UInt8) -> String {
    switch modelId {
    case 0x01: return "kourai"
    case 0x02: return "boson"
    case 0x03: return "rho"
    case 0x04: return "katal"
    case 0x05: return "hadion"
    case 0x06: return "spektrix"
    case 0x07: return "corax"
    case 0x08: return "groundshock"
    case 0x09: return "skull"
    case 0x0a: return "thermo"
    case 0x0b: return "nuke"
    case 0x0c: return "guardian"
    case 0x0e: return "bigbang"
    case 0x0f: return "freewheel"
    case 0x10: return "x52"
    case 0x11: return "x52ice"
    case 0x12: return "mammoth"
    case 0x13: return "dynamo"
    case 0x14: return "ghost"
    default: return "unknown"
    }
}

public func trackName(_ trackId: UInt8) -> String {
    switch trackId {
    //case 36, 39: return "FnF Straight"
    //case 40, 51: return "Straight"
    //case 17, 18: return "Curve"
    //case 20, 23: return "FnF Curve"
    case 36, 39, 40, 51: return "Straight"
    case 17, 18, 20, 23: return "Curve"
    case 34: return "Pre-Finish Line"
    case 33: return "Start/Finish"
    case 57: return "FnF Powerup"
    case 10: return "Intersection"
    default: return "Unknown"
    }
}

public struct VehicleAdvData: Identifiable, Hashable {
    public let id = UUID()
    
    public var carName: String
    public var address: String
    public var state: CBPeripheralState
}
