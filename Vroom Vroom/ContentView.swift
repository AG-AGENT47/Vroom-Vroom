// Swift
//
//  ContentView.swift
//  Vroom Vroom
//
//  Created by Avyakt Garg on 29/12/25.
//
//testing workflow

import SwiftUI

struct ContentView: View {
    // The View observes the MotionManager, which contains the Engine
    @StateObject private var motion = MotionManager()
    
    var body: some View {
        ZStack {
            // Dynamic background color based on state
            backgroundGradient.ignoresSafeArea()
            
            VStack {
                // TELEMETRY HUD (Top)
                VStack(spacing: 5) {
                    Text("ENGINE: \(motion.engine.motionState)")
                    Text("BANKING: \(motion.engine.bankingState)")
                }
                .font(.system(.title3, design: .monospaced))
                .bold()
                .foregroundColor(.white)
                .padding(.top, 40)
                
                Spacer()
                
                // JET VISUAL (Center)
                // The icon changes based on state
                Image(systemName: motion.engine.motionState == .crashed ? "bolt.shield.fill" : "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(motion.engine.motionState == .crashed ? .orange : .white)
                    // Visual Roll: Subtracting offset happens inside the Engine now
                    .rotationEffect(.radians(motion.roll - motion.rollOffset))
                    .shadow(color: .black.opacity(0.3), radius: 10)
                
                Spacer()
                
                // PERSISTENT RESET & CALIBRATE (Bottom)
                Button(action: {
                    motion.engine.calibrate(currentPitch: motion.pitch, currentRoll: motion.roll)
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                        Text("RESET & CALIBRATE")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(motion.engine.motionState == .crashed ? Color.red : Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // Computed property for the background
    var backgroundGradient: LinearGradient {
        let colors: [Color]
        switch motion.engine.motionState {
        case .crashed:
            colors = [Color.red, Color.black]
        case .accelerating:
            colors = [Color.blue, Color.cyan]
        default:
            colors = [Color.black, Color.blue.opacity(0.3)]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
