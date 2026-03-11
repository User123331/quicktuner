struct TuningNote: Codable, Hashable {
    let name: String  // "E", "F#", "Bb"
    let octave: Int   // 0-4 typical range

    init(name: String, octave: Int) {
        self.name = name
        self.octave = octave
    }
}
