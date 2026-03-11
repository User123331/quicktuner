enum TuningCategory: String, Codable, CaseIterable {
    case standard
    case drop
    case open
    case modal
    case alternative
    case custom

    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .drop: return "Drop"
        case .open: return "Open"
        case .modal: return "Modal"
        case .alternative: return "Alternative"
        case .custom: return "Custom"
        }
    }
}
