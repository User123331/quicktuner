struct AudioDevice: Sendable, Equatable, Hashable, Identifiable {
    let id: UInt32
    let name: String
    let uid: String
    let isInput: Bool

    var deviceID: UInt32 { id }
}
