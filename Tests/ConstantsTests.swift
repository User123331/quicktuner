import Testing
import Foundation
@testable import QuickTuner

@Suite("Constants Tests")
struct ConstantsTests {

    @Test("PersistenceKeys selectedInstrument has correct value")
    func testSelectedInstrumentKey() {
        #expect(PersistenceKeys.selectedInstrument == "selectedInstrument")
    }

    @Test("PersistenceKeys selectedTuningId has correct value")
    func testSelectedTuningIdKey() {
        #expect(PersistenceKeys.selectedTuningId == "selectedTuningId")
    }

    @Test("PersistenceKeys referencePitch has correct value")
    func testReferencePitchKey() {
        #expect(PersistenceKeys.referencePitch == "referencePitch")
    }

    @Test("PersistenceKeys noiseGateThreshold has correct value")
    func testNoiseGateThresholdKey() {
        #expect(PersistenceKeys.noiseGateThreshold == "noiseGateThreshold")
    }

    @Test("PersistenceKeys selectedAudioDeviceId has correct value")
    func testSelectedAudioDeviceIdKey() {
        #expect(PersistenceKeys.selectedAudioDeviceId == "selectedAudioDeviceId")
    }

    @Test("ReferencePitchConstants min equals 420.0")
    func testMinReferencePitch() {
        #expect(ReferencePitchConstants.min == 420.0)
    }

    @Test("ReferencePitchConstants max equals 444.0")
    func testMaxReferencePitch() {
        #expect(ReferencePitchConstants.max == 444.0)
    }

    @Test("ReferencePitchConstants default equals 440.0")
    func testDefaultReferencePitch() {
        #expect(ReferencePitchConstants.default == 440.0)
    }

    @Test("ReferencePitchConstants step equals 0.1")
    func testStepReferencePitch() {
        #expect(ReferencePitchConstants.step == 0.1)
    }

    @Test("ReferencePitchConstants presets contains expected values")
    func testReferencePitchPresets() {
        let expectedPresets = [440.0, 432.0, 420.0]
        #expect(ReferencePitchConstants.presets == expectedPresets)
    }

    @Test("ReferencePitchConstants normalize clamps values")
    func testNormalizeClampsMin() {
        #expect(ReferencePitchConstants.normalize(400.0) == 420.0)
    }

    @Test("ReferencePitchConstants normalize clamps max")
    func testNormalizeClampsMax() {
        #expect(ReferencePitchConstants.normalize(500.0) == 444.0)
    }

    @Test("ReferencePitchConstants normalize preserves in-range values")
    func testNormalizePreservesInRange() {
        #expect(ReferencePitchConstants.normalize(440.0) == 440.0)
    }

    @Test("ReferencePitchConstants normalize rounds to 1 decimal place")
    func testNormalizeRounds() {
        #expect(ReferencePitchConstants.normalize(440.15) == 440.2)
        #expect(ReferencePitchConstants.normalize(440.14) == 440.1)
    }

    @Test("FilePaths applicationSupportDirectory returns valid URL")
    func testApplicationSupportDirectory() {
        let url = FilePaths.applicationSupportDirectory
        #expect(url.absoluteString.contains("Application%20Support"))
    }

    @Test("FilePaths quickTunerDirectory is subdirectory of Application Support")
    func testQuickTunerDirectory() {
        let quickTunerPath = FilePaths.quickTunerDirectory.path
        let appSupportPath = FilePaths.applicationSupportDirectory.path
        #expect(quickTunerPath.hasPrefix(appSupportPath))
        #expect(quickTunerPath.hasSuffix("QuickTuner"))
    }

    @Test("FilePaths customTuningsURL is JSON file in QuickTuner directory")
    func testCustomTuningsURL() {
        let customTuningsPath = FilePaths.customTuningsURL.path
        let quickTunerPath = FilePaths.quickTunerDirectory.path
        #expect(customTuningsPath.hasPrefix(quickTunerPath))
        #expect(customTuningsPath.hasSuffix("custom-tunings.json"))
    }
}
