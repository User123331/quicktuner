enum InstrumentType: String, Codable, CaseIterable, Identifiable {
    case guitar6 = "guitar6"
    case guitar7 = "guitar7"
    case guitar8 = "guitar8"
    case bass4 = "bass4"
    case bass5 = "bass5"
    case bass6 = "bass6"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .guitar6: return "Guitar (6-String)"
        case .guitar7: return "Guitar (7-String)"
        case .guitar8: return "Guitar (8-String)"
        case .bass4: return "Bass (4-String)"
        case .bass5: return "Bass (5-String)"
        case .bass6: return "Bass (6-String)"
        }
    }

    var stringCount: Int {
        switch self {
        case .guitar6: return 6
        case .guitar7: return 7
        case .guitar8: return 8
        case .bass4: return 4
        case .bass5: return 5
        case .bass6: return 6
        }
    }
}
