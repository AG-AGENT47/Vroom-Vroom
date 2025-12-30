//
//  MotionManager.swift
//  Vroom Vroom
//
//  Created by Avyakt Garg on 29/12/25.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    // 1. Core Motion and Engine Instances
    private let motionManager = CMMotionManager()
    @Published var engine = FlightEngine() // The Decision Maker
    
    // 2. Raw values published for visual orientation in the UI
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    // 3. Calibration storage
    @Published var pitchOffset: Double = 0.0
    @Published var rollOffset: Double = 0.0

    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            
            // Move the hardware start to a background queue
            // to keep the UI responsive during launch
            DispatchQueue.global(qos: .userInteractive).async {
                self.startUpdates()
            }
    }

    func startUpdates() {
        // Safety check to ensure the device has an accelerometer/gyroscope
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Error: Device Motion is not available on this device.")
            return
        }

        // Start pulling 'Device Motion' (fused sensor data)
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, let self = self else { return }
            
            // Update raw values for the UI icon rotation
            self.pitch = data.attitude.pitch
            self.roll = data.attitude.roll
            
            // PIPE DATA TO ENGINE:
            // This is where the actual logic for 'Flying', 'Accelerating',
            // and 'Crashed' is determined.
            self.engine.processSensorData(
                pitch: data.attitude.pitch,
                roll: data.attitude.roll,
                yAccel: data.userAcceleration.y
            )
        }
    }
    
    // Helper function to link UI Reset to the Engine's calibration
    func resetAndCalibrate() {
        self.pitchOffset = self.pitch
        self.rollOffset = self.roll
        self.engine.calibrate(currentPitch: self.pitch, currentRoll: self.roll)
    }
}
