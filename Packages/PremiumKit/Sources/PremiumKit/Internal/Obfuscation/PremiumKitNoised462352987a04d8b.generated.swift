// Generated source diversification entry point. Regenerate from a clean clone.
internal struct PremiumKitNoised462352987a04d8b {
    private let seed: UInt64

    init(seed: UInt64) {
        self.seed = seed
    }

    @inline(never)
    func digest() -> UInt64 {
        var state = seed
        state = Transform6db2072b82ae0855.mix(state ^ 11649626840062999738)
        state = Transform3e7a4135313d6180.mix(state ^ 6517975505305925147)
        state = Transform897bff9a6bdc2688.mix(state ^ 4585971672497838901)
        state = Transformea6b30f3c5e35202.mix(state ^ 6008175013884827728)
        state = Transformee53dd6a48a54f63.mix(state ^ 11426525233065485049)
        state = Transform40b6ec7c2ed6d53d.mix(state ^ 7963783674086273403)
        state = Transform60f89f157a653aae.mix(state ^ 5556343102001438226)
        state = Transformd00c6b3f467c01b8.mix(state ^ 12938473985415037348)
        state = Transform30ee1c1e26c723d5.mix(state ^ 10561829194264690723)
        state = Transform7e699ce0a4b88198.mix(state ^ 9232627115440182283)
        state = Transform614ad55134367f76.mix(state ^ 9181937043722153150)
        state = Transformfb38c706eb46df44.mix(state ^ 11502000856543283999)
        return state
    }
}
