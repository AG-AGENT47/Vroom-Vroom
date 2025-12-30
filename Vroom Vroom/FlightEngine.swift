//
//  FlightEngine.swift
//  Vroom Vroom
//
//  Created by Avyakt Garg on 30/12/25.
//

import Foundation
import SwiftUI


class FlightEngine: ObservableObject {
    // These are observed by the UI
    @Published var motionState: MotionState = .idling
    @Published var bankingState: BankingState = .level
    
    // Calibration and Physics variables
    private var pitchOffset: Double = 0.0
    private var rollOffset: Double = 0.0
    private var lastYAccel: Double = 0.0
    
    /// Capture the current raw orientation to treat it as "Zero"
    func calibrate(currentPitch: Double, currentRoll: Double) {
        self.pitchOffset = currentPitch
        self.rollOffset = currentRoll
        self.motionState = .idling
        self.bankingState = .level
        self.lastYAccel = 0.0
        
        print(">>> [LOG] SYSTEMS RECALIBRATED: Zeroing at P: \(currentPitch), R: \(currentRoll)")
    }
    
    /// The main logic processor called 60 times per second
    func processSensorData(pitch: Double, roll: Double, yAccel: Double) {
        // TERMINAL STATE GUARD: If crashed, ignore sensors until reset
        guard motionState != .crashed else { return }
        
        // 1. Apply Calibration Offsets
        let calibratedRoll = roll - rollOffset
        
        // 2. Refined Crash Detection (Fluctuation + Negative Force)
        // We check for a sudden reversal in acceleration (delta)
        let delta = yAccel - lastYAccel
        
        if yAccel < -0.1 && delta < -2.0 {
            self.motionState = .crashed
            print("💥 [CRASH] High impact detected! Delta: \(delta), Y-Accel: \(yAccel)")
            return
        }
        
        // 3. Motion State Transitions
        let oldMotion = self.motionState
        if abs(yAccel) < 0.1 {
            self.motionState = .idling
        } else if yAccel > 0.1 {
            self.motionState = .accelerating
        } else {
            self.motionState = .decelerating
        }
        
        // 4. Banking State Transitions
        let oldBanking = self.bankingState
        if calibratedRoll > 0.4 {
            self.bankingState = .bankingRight
        } else if calibratedRoll < -0.4 {
            self.bankingState = .bankingLeft
        } else {
            self.bankingState = .level
        }
        
        // 5. Telemetry: Output to Laptop if a state changed
        if oldMotion != self.motionState || oldBanking != self.bankingState {
            print("--- [TELEMETRY] Motion: \(self.motionState) | Banking: \(self.bankingState) | Y-Accel: \(yAccel)")
        }
        
        // Store for next iteration
        lastYAccel = yAccel
    }
}
