import XCTest

final class PPSCalculatorTests: XCTestCase {
    func testExactCanonicalRows() {
        XCTAssertEqual(score(
            ambulation: .full,
            activity: .normalNoEvidence,
            selfCare: .full,
            intake: .normal,
            consciousness: .full
        ).score, 100)

        XCTAssertEqual(score(
            ambulation: .full,
            activity: .normalWithEffort,
            selfCare: .full,
            intake: .reduced,
            consciousness: .full
        ).score, 80)

        XCTAssertEqual(score(
            ambulation: .reduced,
            activity: .unableHobbyHousework,
            selfCare: .occasionalAssistance,
            intake: .reduced,
            consciousness: .confusion
        ).score, 60)

        XCTAssertEqual(score(
            ambulation: .mainlyInBed,
            activity: .unableMostActivity,
            selfCare: .mainlyAssistance,
            intake: .reduced,
            consciousness: .drowsyOrComa
        ).score, 40)

        XCTAssertEqual(score(
            ambulation: .totallyBedBound,
            activity: .unableAnyActivity,
            selfCare: .totalCare,
            intake: .minimalToSips,
            consciousness: .confusion
        ).score, 20)

        XCTAssertEqual(score(
            ambulation: .totallyBedBound,
            activity: .unableAnyActivity,
            selfCare: .totalCare,
            intake: .mouthCareOnly,
            consciousness: .drowsyOrComa
        ).score, 10)
    }

    func testExactMatchFlagIsTrueForCanonicalRow() {
        let evaluation = score(
            ambulation: .reduced,
            activity: .unableNormalJob,
            selfCare: .full,
            intake: .normal,
            consciousness: .full
        )

        XCTAssertEqual(evaluation.score, 70)
        XCTAssertTrue(evaluation.matchedExactly)
    }

    func testInconsistentCombinationFallsBackConservatively() {
        let evaluation = score(
            ambulation: .full,
            activity: .unableAnyActivity,
            selfCare: .totalCare,
            intake: .mouthCareOnly,
            consciousness: .drowsyOrComa
        )

        XCTAssertEqual(evaluation.score, 10)
        XCTAssertFalse(evaluation.matchedExactly)
    }

    private func score(
        ambulation: PPSAmbulation,
        activity: PPSActivity,
        selfCare: PPSSelfCare,
        intake: PPSIntake,
        consciousness: PPSConsciousness
    ) -> PPSEvaluation {
        PPSCalculator.evaluate(
            PPSInput(
                ambulation: ambulation,
                activity: activity,
                selfCare: selfCare,
                intake: intake,
                consciousness: consciousness
            )
        )
    }
}
