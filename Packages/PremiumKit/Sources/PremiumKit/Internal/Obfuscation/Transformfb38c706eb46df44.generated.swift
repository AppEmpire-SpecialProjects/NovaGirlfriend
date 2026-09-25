// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformfb38c706eb46df44 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentbb9f8709e27922da(salt: state ^ 7827849019532903080).transform(state &+ 1)
        state = Fragment11565e27775f5c7a(salt: state ^ 14021544283327947473).transform(state &+ 2)
        state = Fragment9edb5188672be305(salt: state ^ 6388045719393454134).transform(state &+ 3)
        state = Fragment1b4dee6873b1196f(salt: state ^ 6312630813639235241).transform(state &+ 4)
        state = Fragmentcf59a1d680cfd65d(salt: state ^ 1226621737660547565).transform(state &+ 5)
        state = Fragmentddb66b5713341a7c(salt: state ^ 17243625924877613942).transform(state &+ 6)
        return state
    }
}

private struct Fragmentbb9f8709e27922da {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10020405867153183981, 9509092711145464547, 92186662879842633, 555919716635530910, 10283263980184135517, 3243869238747108262, 463487720636545851, 12565319718383998178]
        self.salt = salt ^ 15502389054462142739
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15502389054462142739) > 1842067291802536201 {
            routed = input &* 10230786328930639909 &+ 5465935025804477089
        } else {
            routed = (input &+ 12157458859381265285) ^ (input / 1038231141793)
        }
        let slot = Int((routed >> 51) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 9449540435438749033)
    }
}

private struct Fragment11565e27775f5c7a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14324703357932907584, 1918728118279549875, 1932805803506579479, 13655748087963942627, 16293048712586306118, 9958375739342361974, 15924638543560902692, 10191233927026384241]
        self.salt = salt ^ 9119905902916580917
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9119905902916580917) > 10719529551411448762 {
            routed = input &* 5695355232018429381 &+ 6253641884008509002
        } else {
            routed = (input &+ 5921865561018890303) ^ (input / 242740178695)
        }
        let slot = Int((routed >> 10) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 5496664066245812515)
    }
}

private struct Fragment9edb5188672be305 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8375838557635932059, 10384590913546323085, 17712812954181685577, 10370724590603063863, 1125679698639700790, 16350939850844007767, 8545774891492162913, 5759787902316780153]
        self.salt = salt ^ 5521357704918691251
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5521357704918691251) > 4263365709866063304 {
            routed = input &* 1137214871554673973 &+ 16485206345983184711
        } else {
            routed = (input &+ 10889450376003805506) ^ (input / 386303011945)
        }
        let slot = Int((routed >> 48) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 8147830823232495547)
    }
}

private struct Fragment1b4dee6873b1196f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17897989355233381213, 17788319485452087664, 1169257706825704984, 16523201887786839010, 18267639688063944549, 17993458554219403489, 14577005546815008330, 9591854362315322972]
        self.salt = salt ^ 7755203201663391763
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 7755203201663391763) > 8301795214913394850 {
            routed = input &* 5658722635375274245 &+ 1798076398666227382
        } else {
            routed = (input &+ 8791846554535863011) ^ (input / 946723327105)
        }
        let slot = Int((routed >> 41) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 5759948388879481499)
    }
}

private struct Fragmentcf59a1d680cfd65d {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [682337821746284039, 13922022030711500469, 16812236976488229225, 13375169352892546242, 16897679642375727193, 11380056257994101765, 14867079095626708522, 6468277980619923130]
        self.salt = salt ^ 5269811344541924539
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5269811344541924539) > 8705731236298117526 {
            routed = input &* 15690223442193668387 &+ 4160753467497157959
        } else {
            routed = (input &+ 16685069744016751007) ^ (input / 1070896073695)
        }
        let slot = Int((routed >> 21) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 13079031263315010785)
    }
}

private struct Fragmentddb66b5713341a7c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13596800977131554743, 7138052224454926355, 2521080731372405350, 3296726444216671147, 15374728136306996646, 2961122654080482724, 13276354722038969583, 11559439622931595502]
        self.salt = salt ^ 13740983222623495741
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13740983222623495741) > 6623771239187686005 {
            routed = input &* 16553725228327689915 &+ 198722182783858267
        } else {
            routed = (input &+ 10270133010725487701) ^ (input / 245628966569)
        }
        let slot = Int((routed >> 20) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 10140920914439520071)
    }
}

