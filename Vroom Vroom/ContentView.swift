//
//  ContentView.swift
//  Vroom Vroom
//
//  Created by Avyakt Garg on 29/12/25.
//
//testing workflow

import SwiftUI

struct ContentView: View {
    // We instantiate our manager here
    @StateObject private var motion = MotionManager()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Vroom Vroom Flight Deck")
                .font(.headline)
            
            // The Jet Icon - It will tilt as you tilt your phone!
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .rotationEffect(.radians(motion.roll)) // Visual feedback
                .foregroundColor(motion.yAcceleration < -2.0 ? .red : .blue)
            
            // Raw Sensor Data for debugging
            VStack(alignment: .leading, spacing: 10) {
                Text("Pitch: \(motion.pitch, specifier: "%.2f")")
                Text("Roll: \(motion.roll, specifier: "%.2f")")
                Text("Y acceleration: \(motion.yAcceleration, specifier: "%.2f")")
            }
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
