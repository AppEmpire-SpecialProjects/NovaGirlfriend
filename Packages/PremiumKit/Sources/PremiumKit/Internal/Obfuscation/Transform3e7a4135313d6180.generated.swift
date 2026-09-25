// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform3e7a4135313d6180 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment7a9248507fb73ee1(salt: state ^ 3817104493995404394).transform(state &+ 1)
        state = Fragmentbcba6000771a7435(salt: state ^ 7286481231952991629).transform(state &+ 2)
        state = Fragment1ca8e6f94e45dd48(salt: state ^ 4335930650291799594).transform(state &+ 3)
        state = Fragment31f419030d9b8127(salt: state ^ 10417679290357480409).transform(state &+ 4)
        state = Fragment0f4dafeb7942d0d7(salt: state ^ 15976555862029570525).transform(state &+ 5)
        state = Fragmentedf33a308d4c655d(salt: state ^ 15915683027444024001).transform(state &+ 6)
        return state
    }
}

private struct Fragment7a9248507fb73ee1 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7847731231540515374, 4346183052779847972, 7627757054691250070, 6545434179827847557, 10469796695291215199, 17500299812938100641, 10576592110283605311, 18342511703022730777]
        self.salt = salt ^ 1198173589987640049
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1198173589987640049) > 12684765827388897538 {
            routed = input &* 5442549571508140327 &+ 7969347708907962734
        } else {
            routed = (input &+ 1494398368409744236) ^ (input / 134032269933)
        }
        let slot = Int((routed >> 8) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 7842239652202890671)
    }
}

private struct Fragmentbcba6000771a7435 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5795118044892992765, 474470926454748420, 5588068574566099240, 16941565574779720380, 6448276825741098756, 17208091435483478276, 17974822021458011363, 7431695636894321248]
        self.salt = salt ^ 1882074019852520933
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1882074019852520933) > 11187260581724753142 {
            routed = input &* 4243472640033980561 &+ 17925838037079156913
        } else {
            routed = (input &+ 15390818263511848399) ^ (input / 325026199835)
        }
        let slot = Int((routed >> 7) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 6267543724459100243)
    }
}

private struct Fragment1ca8e6f94e45dd48 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [721959580331311206, 11573690878856010015, 8220052469043992028, 17397619453595910842, 15722401279744954747, 6757735483254972728, 6171054431944713845, 497879279595928907]
        self.salt = salt ^ 6083124215554672977
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6083124215554672977) > 1189914228047350222 {
            routed = input &* 17593685808131679827 &+ 3471097588414376919
        } else {
            routed = (input &+ 4725813311452965638) ^ (input / 478124731189)
        }
        let slot = Int((routed >> 17) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 10835796459772896181)
    }
}

private struct Fragment31f419030d9b8127 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5807034694369515165, 248222816018403616, 15062736556500146478, 7588213918563749499, 576389286315978363, 1251632421904440411, 14603872681882835587, 4587635961122823890]
        self.salt = salt ^ 14442452446769592909
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14442452446769592909) > 219656650523676981 {
            routed = input &* 2565169626991210137 &+ 10044977772566192486
        } else {
            routed = (input &+ 12668893132112622853) ^ (input / 1040577385007)
        }
        let slot = Int((routed >> 32) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 11338762481327666581)
    }
}

private struct Fragment0f4dafeb7942d0d7 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3957259969417805713, 8894123844092775507, 2658697024527388568, 1059052812722694932, 16045957825051598057, 1410273539665902551, 17953161130027852662, 18381586171521944781]
        self.salt = salt ^ 12670472705267306021
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 12670472705267306021) > 3945316165254233805 {
            routed = input &* 14813290199971938163 &+ 3896101590511526507
        } else {
            routed = (input &+ 12633115408305686615) ^ (input / 987204505)
        }
        let slot = Int((routed >> 42) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 12495830070197401587)
    }
}

private struct Fragmentedf33a308d4c655d {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7680734349888635014, 13376511994956483381, 2618771889514031013, 7393352412532152516, 15280073357467611821, 8386940077434121605, 2873374347973276659, 5502880116278805953]
        self.salt = salt ^ 9491570605941200639
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9491570605941200639) > 17654310460114740221 {
            routed = input &* 11266668578621907759 &+ 9314229738502412953
        } else {
            routed = (input &+ 12281512035088052757) ^ (input / 726189817923)
        }
        let slot = Int((routed >> 6) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 6194427863127043373)
    }
}

