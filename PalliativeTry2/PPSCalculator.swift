import Foundation

protocol PPSOption: CaseIterable, Identifiable, Hashable {
    var displayName: String { get }
    var severity: Int { get }
}

enum PPSAmbulation: Int, PPSOption {
    case full
    case reduced
    case mainlySitOrLie
    case mainlyInBed
    case totallyBedBound

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .full: return "Full ambulation"
        case .reduced: return "Reduced ambulation"
        case .mainlySitOrLie: return "Mainly sit/lie"
        case .mainlyInBed: return "Mainly in bed"
        case .totallyBedBound: return "Totally bed bound"
        }
    }

    var severity: Int { rawValue }
}

enum PPSActivity: Int, PPSOption {
    case normalNoEvidence
    case normalSomeEvidence
    case normalWithEffort
    case unableNormalJob
    case unableHobbyHousework
    case unableMostActivity
    case unableAnyActivity

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .normalNoEvidence: return "Normal activity (no disease evidence)"
        case .normalSomeEvidence: return "Normal activity (some disease evidence)"
        case .normalWithEffort: return "Normal activity with effort"
        case .unableNormalJob: return "Unable normal job/work"
        case .unableHobbyHousework: return "Unable hobby/house work"
        case .unableMostActivity: return "Unable most activity"
        case .unableAnyActivity: return "Unable any activity"
        }
    }

    var severity: Int { rawValue }
}

enum PPSSelfCare: Int, PPSOption {
    case full
    case occasionalAssistance
    case considerableAssistance
    case mainlyAssistance
    case totalCare

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .full: return "Full"
        case .occasionalAssistance: return "Occasional assistance"
        case .considerableAssistance: return "Considerable assistance"
        case .mainlyAssistance: return "Mainly assistance"
        case .totalCare: return "Total care"
        }
    }

    var severity: Int { rawValue }
}

enum PPSIntake: Int, PPSOption {
    case normal
    case reduced
    case minimalToSips
    case mouthCareOnly

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .reduced: return "Reduced"
        case .minimalToSips: return "Minimal to sips"
        case .mouthCareOnly: return "Mouth care only"
        }
    }

    var severity: Int { rawValue }
}

enum PPSConsciousness: Int, PPSOption {
    case full
    case confusion
    case drowsyOrComa

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .full: return "Full"
        case .confusion: return "Confusion"
        case .drowsyOrComa: return "Drowsy or coma"
        }
    }

    var severity: Int { rawValue }
}

struct PPSInput: Hashable {
    var ambulation: PPSAmbulation
    var activity: PPSActivity
    var selfCare: PPSSelfCare
    var intake: PPSIntake
    var consciousness: PPSConsciousness

    static let `default` = PPSInput(
        ambulation: .full,
        activity: .normalNoEvidence,
        selfCare: .full,
        intake: .normal,
        consciousness: .full
    )
}

struct PPSEvaluation: Equatable {
    let score: Int
    let matchedExactly: Bool
}

enum PPSCalculator {
    private struct Rule {
        let score: Int
        let ambulation: Set<PPSAmbulation>
        let activity: Set<PPSActivity>
        let selfCare: Set<PPSSelfCare>
        let intake: Set<PPSIntake>
        let consciousness: Set<PPSConsciousness>

        func matches(_ input: PPSInput) -> Bool {
            ambulation.contains(input.ambulation) &&
            activity.contains(input.activity) &&
            selfCare.contains(input.selfCare) &&
            intake.contains(input.intake) &&
            consciousness.contains(input.consciousness)
        }

        func distance(to input: PPSInput) -> Int {
            axisDistance(input.ambulation, allowed: ambulation) +
            axisDistance(input.activity, allowed: activity) +
            axisDistance(input.selfCare, allowed: selfCare) +
            axisDistance(input.intake, allowed: intake) +
            axisDistance(input.consciousness, allowed: consciousness)
        }

        private func axisDistance<T: PPSOption>(_ value: T, allowed: Set<T>) -> Int {
            if allowed.contains(value) {
                return 0
            }

            return allowed.map { abs($0.severity - value.severity) }.min() ?? Int.max
        }
    }

    private static let rules: [Rule] = [
        Rule(
            score: 100,
            ambulation: [.full],
            activity: [.normalNoEvidence],
            selfCare: [.full],
            intake: [.normal],
            consciousness: [.full]
        ),
        Rule(
            score: 90,
            ambulation: [.full],
            activity: [.normalSomeEvidence],
            selfCare: [.full],
            intake: [.normal],
            consciousness: [.full]
        ),
        Rule(
            score: 80,
            ambulation: [.full],
            activity: [.normalWithEffort],
            selfCare: [.full],
            intake: [.normal, .reduced],
            consciousness: [.full]
        ),
        Rule(
            score: 70,
            ambulation: [.reduced],
            activity: [.unableNormalJob],
            selfCare: [.full],
            intake: [.normal, .reduced],
            consciousness: [.full]
        ),
        Rule(
            score: 60,
            ambulation: [.reduced],
            activity: [.unableHobbyHousework],
            selfCare: [.occasionalAssistance],
            intake: [.normal, .reduced],
            consciousness: [.full, .confusion]
        ),
        Rule(
            score: 50,
            ambulation: [.mainlySitOrLie],
            activity: [.unableAnyActivity],
            selfCare: [.considerableAssistance],
            intake: [.normal, .reduced],
            consciousness: [.full, .confusion]
        ),
        Rule(
            score: 40,
            ambulation: [.mainlyInBed],
            activity: [.unableMostActivity],
            selfCare: [.mainlyAssistance],
            intake: [.normal, .reduced],
            consciousness: [.full, .confusion, .drowsyOrComa]
        ),
        Rule(
            score: 30,
            ambulation: [.totallyBedBound],
            activity: [.unableAnyActivity],
            selfCare: [.totalCare],
            intake: [.reduced],
            consciousness: [.full, .confusion, .drowsyOrComa]
        ),
        Rule(
            score: 20,
            ambulation: [.totallyBedBound],
            activity: [.unableAnyActivity],
            selfCare: [.totalCare],
            intake: [.minimalToSips],
            consciousness: [.full, .confusion, .drowsyOrComa]
        ),
        Rule(
            score: 10,
            ambulation: [.totallyBedBound],
            activity: [.unableAnyActivity],
            selfCare: [.totalCare],
            intake: [.mouthCareOnly],
            consciousness: [.drowsyOrComa]
        )
    ]

    static func evaluate(_ input: PPSInput) -> PPSEvaluation {
        if let rule = rules.first(where: { $0.matches(input) }) {
            return PPSEvaluation(score: rule.score, matchedExactly: true)
        }

        let closestRule = rules.min { lhs, rhs in
            let lhsDistance = lhs.distance(to: input)
            let rhsDistance = rhs.distance(to: input)

            if lhsDistance == rhsDistance {
                // Conservative tie-breaker to avoid overstating functional status.
                return lhs.score < rhs.score
            }

            return lhsDistance < rhsDistance
        }

        return PPSEvaluation(score: closestRule?.score ?? 0, matchedExactly: false)
    }
}
