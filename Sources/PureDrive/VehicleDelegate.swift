//
//  VehicleDelegate.swift
//  PureDrive
//
//  Created by Lrdsnow on 8/23/24.
//

import Foundation
import CoreBluetooth
import SwiftUI
import PureDriveC

public class VehicleDelegate: NSObject, CBPeripheralDelegate, Identifiable {
    public var id: UUID { peripheral.identifier }
    public var peripheral: CBPeripheral
    public var advData: VehicleAdvData
    public var readChannel: CBCharacteristic?
    public var writeChannel: CBCharacteristic?
    public var controller: AnyObject
    public var active: Bool = false
    public var identifier: UInt32 = 0
    public var modelIdentifier: UInt8 = 0
    public var version: String = "0x0000"
    public var debug_mode = true
    @Published public var loggedTracks: [(String, Bool, Int)] = []

    public init(controller: AnyObject, peripheral: CBPeripheral, advData: VehicleAdvData) {
        self.controller = controller
        self.peripheral = peripheral
        self.advData = advData
        super.init()
    }

    public func isActive() -> Bool {
        return active
    }
    
    /// Sets the SDK mode for the vehicle.
    ///
    /// - Parameters:
    ///   - on: A Boolean value indicating whether to turn SDK mode on (`true`) or off (`false`).
    ///   - flags: Option flags to specify vehicle behaviors while SDK mode is enabled.
    public func setSDKMode(_ on: Bool, _ flags: UInt8) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_set_sdk_mode(&msg, on ? 1 : 0, flags)
        sendMessage(&msg, withLength: size)
    }
    
    /// Sets the vehicle's internal offset from the road center.
    ///
    /// - Parameter offset: The offset from the road center in millimeters.
    public func setOffsetFromRoadCenter(_ offset: Float) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_set_offset_from_road_center(&msg, offset)
        sendMessage(&msg, withLength: size)
    }

    /// Requests a lane change for the vehicle.
    ///
    /// - Parameters:
    ///   - horizontalSpeed: The horizontal speed for the lane change in millimeters per second.
    ///   - horizontalAccel: The horizontal acceleration for the lane change in millimeters per second squared.
    ///   - offset: The target offset from the road center in millimeters.
    public func changeLane(horizontalSpeed: UInt16, horizontalAccel: UInt16, offset: Float) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_change_lane(&msg, horizontalSpeed, horizontalAccel, offset)
        sendMessage(&msg, withLength: size)
    }
    
    /// Sets the vehicle's lights using a mask.
    ///
    /// - Parameter mask: A mask byte representing the desired lights.
    public func setLights(mask: UInt8) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_set_lights(&msg, mask)
        sendMessage(&msg, withLength: size)
    }
    
    // LED channel definitions - for RGB engine, front, and tail lights
    public enum VehicleLightChannel: UInt32, CaseIterable {
        case red = 0
        case tail = 1
        case blue = 2
        case green = 3
        case frontL = 4
        case frontR = 5
        case count = 6
    }

    // Below is a description of the public various effects used in SetLight(...)
    public enum VehicleLightEffect: UInt32, CaseIterable {
        case steady = 0   // Simply set the light intensity to 'start' value
        case fade = 1     // Fade intensity from 'start' to 'end'
        case throb = 2    // Fade intensity from 'start' to 'end' and back to 'start'
        case flash = 3    // Turn on LED between time 'start' and time 'end' inclusive
        case random = 4   // Flash the LED erratically - ignoring start/end
        case count = 5
    }
    
    /// Sets a pattern for the vehicle's lights.
    ///
    /// - Parameters:
    ///   - channel: The target light channel. See `anki_vehicle_light_channel_t`.
    ///   - effect: The type of light effect. See `anki_vehicle_light_effect_t`.
    ///   - start: The starting intensity of the light.
    ///   - end: The ending intensity of the light.
    ///   - cyclesPerMin: The frequency of the light pattern transitions, in cycles per minute.
    public func setLightsPattern(channel: VehicleLightChannel, effect: VehicleLightEffect, start: UInt8, end: UInt8, cyclesPerMin: UInt16) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_lights_pattern(&msg, anki_vehicle_light_channel_t(channel.rawValue), anki_vehicle_light_effect_t(effect.rawValue), start, end, cyclesPerMin)
        sendMessage(&msg, withLength: size)
    }
    
    public func setEngineLight(r: UInt8, g: UInt8, b: UInt8, effect: VehicleLightEffect, cycles: UInt16) {
        switch effect {
        case .throb, .flash:
            setLightsPattern(channel: .red, effect: effect, start: 0, end:  r, cyclesPerMin: cycles)
            setLightsPattern(channel: .green, effect: effect, start: 0, end: g, cyclesPerMin: cycles)
            setLightsPattern(channel: .blue, effect: effect, start: 0, end: b, cyclesPerMin: cycles)
        case .fade:
            setLightsPattern(channel: .red, effect: effect, start: r, end:  0, cyclesPerMin: cycles)
            setLightsPattern(channel: .green, effect: effect, start: g, end: 0, cyclesPerMin: cycles)
            setLightsPattern(channel: .blue, effect: effect, start: b, end: 0, cyclesPerMin: cycles)
        default:
            setLightsPattern(channel: .red, effect: effect, start: r, end:  r, cyclesPerMin: 0)
            setLightsPattern(channel: .green, effect: effect, start: g, end: g, cyclesPerMin: 0)
            setLightsPattern(channel: .blue, effect: effect, start: b, end: b, cyclesPerMin: 0)
        }
    }
    
    /// Sends a disconnect request to the vehicle.
    ///
    /// This is often a more reliable way to disconnect compared to closing
    /// the connection from the central.
    public func disconnect() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_disconnect(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Sends a ping request to the vehicle.
    ///
    /// The vehicle will respond with a message of type `ANKI_VEHICLE_MSG_V2C_PING_RESPONSE`.
    public func ping() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_ping(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Requests the vehicle firmware version.
    ///
    /// The vehicle will respond with a message of type `anki_vehicle_msg_version_response_t`.
    public func getVersion() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_get_version(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Requests the vehicle's battery level.
    ///
    /// The vehicle will respond with a message of type `anki_vehicle_msg_battery_level_response_t`.
    public func getBatteryLevel() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_get_battery_level(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Cancels a previously requested lane change.
    ///
    /// The vehicle will stop any lane change maneuver that was in progress.
    public func cancelLaneChange() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_cancel_lane_change(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Requests the vehicle to perform a 180-degree turn.
    ///
    /// The vehicle will execute a 180-degree turn maneuver.
    public func turn180() {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_turn_180(&msg)
        sendMessage(&msg, withLength: size)
    }
    
    /// Sets the speed and acceleration for the vehicle.
    ///
    /// - Parameters:
    ///   - speed: The requested vehicle speed in millimeters per second.
    ///   - acceleration: The acceleration of the vehicle in millimeters per second squared.
    public func setSpeed(_ speed: Int, _ acceleration: Int) {
        var msg = anki_vehicle_msg_t()
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        let size = anki_vehicle_msg_set_speed(&msg, UInt16(speed), UInt16(acceleration))
        sendMessage(&msg, withLength: size)
    }
    
    public func sendMessage(_ buffer: UnsafeMutableRawPointer, withLength len: UInt8) {
        if let writeChannel = writeChannel {
            let valData = Data(bytes: buffer, count: Int(len))
            peripheral.writeValue(valData, for: writeChannel, type: .withoutResponse)
            if debug_mode {
                print("Sent: \(valData.map { String(format: "%02hhx ", $0) }.joined())")
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Discovered services for \(peripheral.name ?? "") with error: \(error.localizedDescription)")
            return
        }

        guard let service = peripheral.services?.first else { return }
        print("Discovered service, Id=\(service.uuid.uuidString)")
        peripheral.discoverCharacteristics(nil, for: service)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Discovered characteristics for \(service.uuid) with error: \(error.localizedDescription)")
            return
        }

        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == CBUUID(string: ankiChrWriteUUID.uuidString) {
                writeChannel = characteristic
                print("Discovered write channel")
            }
            if characteristic.uuid == CBUUID(string: ankiChrReadUUID.uuidString) {
                readChannel = characteristic
                print("Discovered read channel")
            }
        }

        peripheral.setNotifyValue(true, for: readChannel!)

        var msg = anki_vehicle_msg_t()
        var size: UInt8 = 0
        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        size = anki_vehicle_msg_set_sdk_mode(&msg, 1, UInt8(ANKI_VEHICLE_SDK_OPTION_OVERRIDE_LOCALIZATION))
        sendMessage(&msg, withLength: size)

        memset(&msg, 0, MemoryLayout<anki_vehicle_msg_t>.size)
        anki_vehicle_msg_get_version(&msg)
        sendMessage(&msg, withLength: size)

        active = true
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic \(characteristic.uuid) error: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            print("No data available for characteristic \(characteristic.uuid)")
            return
        }

        var msg = anki_vehicle_msg_t()
        data.withUnsafeBytes { bufferPointer in
            let rawPointer = bufferPointer.baseAddress!
            memcpy(&msg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_t>.size))
        }

        switch msg.msg_id {
        case UInt8(ANKI_VEHICLE_MSG_V2C_PING_RESPONSE):
            print("Ping received from vehicle")

        case UInt8(ANKI_VEHICLE_MSG_V2C_VERSION_RESPONSE):
            var versionMsg = anki_vehicle_msg_version_response_t()
            data.withUnsafeBytes { bufferPointer in
                let rawPointer = bufferPointer.baseAddress!
                memcpy(&versionMsg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_version_response_t>.size))
            }
            version = String(format: "0x%04x", versionMsg.version)
            print("Version response: \(version)")

        case UInt8(ANKI_VEHICLE_MSG_V2C_LOCALIZATION_POSITION_UPDATE):
            var updateMsg = anki_vehicle_msg_localization_position_update_t()
            data.withUnsafeBytes { bufferPointer in
                let rawPointer = bufferPointer.baseAddress!
                memcpy(&updateMsg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_localization_position_update_t>.size))
            }
            print("pos: \(updateMsg)")
            let track_name = trackName(updateMsg._reserved.1)
            self.loggedTracks.append((track_name, updateMsg.is_clockwise == 71, Int(updateMsg._reserved.0)))
            print("track name: \(track_name)")
            
        case UInt8(ANKI_VEHICLE_MSG_V2C_LOCALIZATION_TRANSITION_UPDATE):
            var transitionMsg = anki_vehicle_msg_localization_transition_update_t()
            data.withUnsafeBytes { bufferPointer in
                let rawPointer = bufferPointer.baseAddress!
                memcpy(&transitionMsg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_localization_transition_update_t>.size))
            }
            print("transition: \(transitionMsg)")

        case UInt8(ANKI_VEHICLE_MSG_V2C_VEHICLE_DELOCALIZED):
            print(String(format: "Warning: vehicle delocalized id=0x%04x", identifier))

        case UInt8(ANKI_VEHICLE_MSG_V2C_BATTERY_LEVEL_RESPONSE):
            var batteryMsg = anki_vehicle_msg_battery_level_response()
            data.withUnsafeBytes { bufferPointer in
                let rawPointer = bufferPointer.baseAddress!
                memcpy(&batteryMsg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_battery_level_response>.size))
            }
            print("Battery Level: \(batteryMsg.battery_level)")
            
        case UInt8(ANKI_VEHICLE_MSG_V2C_STATUS_UPDATE):
            var statusUpdateMsg = anki_vehicle_msg_status_update()
            data.withUnsafeBytes { bufferPointer in
                let rawPointer = bufferPointer.baseAddress!
                memcpy(&statusUpdateMsg, rawPointer, min(data.count, MemoryLayout<anki_vehicle_msg_status_update>.size))
            }
            print("Status Update: \(statusUpdateMsg)")
        
        case UInt8(ANKI_VEHICLE_MSG_V2C_CAR_MESSAGE_CYCLE_OVERTIME):
            break
            
        case UInt8(ANKI_VEHICLE_MSG_V2C_CAR_COLLISION):
            print("Collision!")
        
        case UInt8(ANKI_VEHICLE_MSG_V2C_CAR_ERROR):
            print("Car Error")
        
        default:
            print("\(String(format: "Unknown message received - 0x%04X, size %d", msg.msg_id, msg.size)), Message: \(data.map { String(format: "%02hhx ", $0) }.joined())")
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value for characteristic \(characteristic.uuid) error: \(error.localizedDescription)")
            return
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating notification state for characteristic \(characteristic.uuid) error: \(error.localizedDescription)")
            return
        }
    }
}
