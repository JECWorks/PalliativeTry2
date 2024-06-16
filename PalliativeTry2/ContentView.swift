//
//  ContentView.swift
//  PalliativeTry2
//
//  Created by Jason Cox on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @State private var ambulationScore: Int = 1
    @State private var activityScore: Int = 1
    @State private var assistanceScore: Int = 1
    @State private var oralIntakeScore: Int = 1
    @State private var mentalStatusScore: Int = 1
    @State private var ppsScore: Int = 0

    var body: some View {
        VStack {
            MenuButton(title: "Ambulation", options: ["Full Ambulation", "Slightly reduced ambulation", "Reduced ambulation", "Very reduced ambulation", "Bedbound"], score: $ambulationScore, symbol: "figure.walk")
                .frame(width: 150)
            
            MenuButton(title: "Activity", options: ["Normal Activity", "Reduced Activity", "Minimal Activity", "Very Minimal Activity", "Bedridden"], score: $activityScore, symbol: "bolt")
                .frame(width: 150)
            
            MenuButton(title: "Assistance", options: ["No Assistance", "Slight Assistance", "Moderate Assistance", "Significant Assistance", "Total Assistance"], score: $assistanceScore, symbol: "hand.raised")
                .frame(width: 150)
            
            MenuButton(title: "Oral Intake", options: ["Normal Intake", "Reduced Intake", "Minimal Intake", "Sips only", "Nothing by mouth"], score: $oralIntakeScore, symbol: "fork.knife")
                .frame(width: 150)
            
            MenuButton(title: "Mental Status", options: ["Alert", "Forgetful", "Confused", "Drowsy", "Unresponsive"], score: $mentalStatusScore, symbol: "brain.head.profile")
                .frame(width: 150)
            
            Button(action: calculatePPS) {
                Text("Calculate PPS")
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("PPS Score: \(ppsScore)")
                .font(.title)
                .padding()
        }
        .padding()
    }

    func calculatePPS() {
        ppsScore = ppsCalculator(ambulation: ambulationScore, activity: activityScore, assistance: assistanceScore, oralIntake: oralIntakeScore, mentalStatus: mentalStatusScore)
    }

    func ppsCalculator(ambulation: Int, activity: Int, assistance: Int, oralIntake: Int, mentalStatus: Int) -> Int {
        return ambulation + activity + assistance + oralIntake + mentalStatus
    }
}

struct MenuButton: View {
    let title: String
    let options: [String]
    @Binding var score: Int
    let symbol: String

    var body: some View {
        Menu {
            ForEach(0..<options.count, id: \.self) { index in
                Button(action: { selectOption(index + 1) }) {
                    Text(options[index])
                }
            }
        } label: {
            Label(title, systemImage: symbol)
                .font(.title)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    func selectOption(_ selectedScore: Int) {
        score = selectedScore
    }
}

#Preview {
    ContentView()
}
