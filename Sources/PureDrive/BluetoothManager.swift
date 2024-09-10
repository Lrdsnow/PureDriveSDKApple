//
//  BluetoothManager.swift
//  PureDrive
//
//  Created by Lrdsnow on 8/22/24.
//

import CoreBluetooth
import Combine

let maxBatteryLevel = 4200

public class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?

    private let centralQueue = DispatchQueue(label: "com.lrdsnow.bluetooth")

    @Published public var isScanning = false
    @Published public var connectedPeripheral: CBPeripheral?
    @Published public var discoveredVehicles: [VehicleDelegate] = []
    @Published public var writerCharacteristicList: [(address: String, characteristic: CBCharacteristic)] = []
    @Published public var readerCharacteristicList: [(address: String, characteristic: CBCharacteristic)] = []
    @Published public var bluetoothState: CBManagerState = .unknown

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }

    public func startScanning() {
        guard centralManager.state == .poweredOn else {
            self.bluetoothState = self.centralManager.state
            print("Bluetooth is not powered on. State: \(self.centralManager.state.rawValue)")
            return
        }
        self.isScanning = true
        print("Starting scan...")
        centralManager.scanForPeripherals(withServices: [CBUUID(nsuuid: ankiServiceUUID)], options: nil)
    }
    

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.bluetoothState = central.state
        print("Bluetooth state updated: \(central.state.rawValue)")
        switch central.state {
        case .poweredOn:
            self.startScanning()
        case .poweredOff:
            print("Bluetooth is powered off. Please turn on Bluetooth in your device settings.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unknown:
            print("Bluetooth state is unknown.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        @unknown default:
            print("Unknown Bluetooth state.")
        }
    }

    // Discover
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !self.discoveredVehicles.contains(where: { $0.peripheral.identifier.uuidString == peripheral.identifier.uuidString }),
           let serviceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as? [AnyObject],
           serviceUUIDs.contains(where: { ($0 as? CBUUID)?.uuidString == ankiServiceUUID.uuidString }),
           let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            
            let modelData = manufacturerData.count > 3 ? manufacturerData[3] : 0
            let carName = carName(modelData)
            
            if carName != "Unknown" {
                let address = peripheral.identifier.uuidString
                let state = peripheral.state
                let vehicleDelegate = VehicleDelegate(controller: self, peripheral: peripheral, advData: VehicleAdvData(carName: carName, address: address, state: state))
                peripheral.delegate = vehicleDelegate
                self.discoveredVehicles.append(vehicleDelegate)
                self.centralManager.connect(peripheral, options: nil)
                print("Found car: \(carName) @ \(address)")
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID(nsuuid: ankiServiceUUID)])
    }
}
