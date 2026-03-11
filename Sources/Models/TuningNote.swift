struct TuningNote: Codable, Hashable {
    var name: String  // "E", "F#", "Bb"
    var octave: Int   // 0-4 typical range

    init(name: String, octave: Int) {
        self.name = name
        self.octave = octave
    }
}
