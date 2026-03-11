struct Note: Sendable, Equatable {
    let name: String
    let octave: Int
    let cents: Double
    let frequency: Double

    init(name: String, octave: Int, cents: Double, frequency: Double) {
        self.name = name
        self.octave = octave
        self.cents = cents
        self.frequency = frequency
    }
}
