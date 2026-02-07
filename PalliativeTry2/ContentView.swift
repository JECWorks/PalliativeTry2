import SwiftUI

struct ContentView: View {
    @State private var input: PPSInput = .default
    @State private var evaluation: PPSEvaluation?

    var body: some View {
        Form {
            selectionRow("🚶 Ambulation", selection: $input.ambulation)
            selectionRow("⚡ Activity and Evidence of Disease", selection: $input.activity)
            selectionRow("🤲 Self-Care", selection: $input.selfCare)
            selectionRow("🍽️ Oral Intake", selection: $input.intake)
            selectionRow("🧠 Conscious Level", selection: $input.consciousness)

            Button("Calculate PPS") {
                evaluation = PPSCalculator.evaluate(input)
            }
            .buttonStyle(.borderedProminent)

            if let evaluation {
                Text("PPS Score: \(evaluation.score)")
                    .font(.title2.weight(.semibold))

                Text(interpretation(for: evaluation.score))
                    .foregroundStyle(.primary)
                    .font(.body)

                if !evaluation.matchedExactly {
                    Text("Selection did not exactly match a canonical PPS row; nearest conservative score shown.")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 680)
    }

    private func selectionRow<T: PPSOption>(_ title: String, selection: Binding<T>) -> some View {
        Picker(title, selection: selection) {
            ForEach(Array(T.allCases), id: \.id) { option in
                Text(option.displayName)
                    .tag(option)
            }
        }
        .pickerStyle(.menu)
    }

    private func interpretation(for score: Int) -> String {
        switch score {
        case 90...100:
            return "Interpretation: near full function and independence."
        case 70...80:
            return "Interpretation: reduced function, but largely self-sufficient."
        case 50...60:
            return "Interpretation: significant disease impact with growing care needs."
        case 30...40:
            return "Interpretation: mainly bed-bound with substantial assistance required."
        case 10...20:
            return "Interpretation: very limited function and total care needs."
        default:
            return "Interpretation: score outside standard PPS deciles."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
