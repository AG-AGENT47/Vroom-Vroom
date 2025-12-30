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
    private let motionManager = CMMotionManager()
    
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yAcceleration: Double = 0.0
    //subsicribe to these values
    
    init() {
        //
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        startUpdates()
    }
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, let self = self else { return }
            
            // 1. Attitude (Pitch/Roll) handles the "flying" orientation
            self.pitch = data.attitude.pitch
            self.roll = data.attitude.roll
            
            //extreme negative y will show crash
            let yAccel = data.userAcceleration.y
            self.yAcceleration = yAccel
        }
    }
}
