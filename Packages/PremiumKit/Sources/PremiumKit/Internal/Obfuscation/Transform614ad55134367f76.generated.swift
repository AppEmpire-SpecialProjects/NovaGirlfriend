// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform614ad55134367f76 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment6621732cb7ecd473(salt: state ^ 3796013287151430798).transform(state &+ 1)
        state = Fragment05bbcd349dc91d21(salt: state ^ 17258410773505250657).transform(state &+ 2)
        state = Fragment30df9d74c3630d26(salt: state ^ 12412953009829253731).transform(state &+ 3)
        state = Fragmentbb8d4a10efabdf8a(salt: state ^ 12391361195196648726).transform(state &+ 4)
        state = Fragment8266dd7815bfee4c(salt: state ^ 16515499488083093816).transform(state &+ 5)
        state = Fragment674e4bab245fcc92(salt: state ^ 13257322588417591160).transform(state &+ 6)
        return state
    }
}

private struct Fragment6621732cb7ecd473 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15926928834915035143, 8838535205197145486, 14284715705707662368, 5628494099304519146, 11296964063324756270, 14393767265302482901, 7986191162350555187, 15653932924949366923]
        self.salt = salt ^ 17721325835778003919
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17721325835778003919) > 16618880837076301352 {
            routed = input &* 13343154514008242989 &+ 3699553702402972286
        } else {
            routed = (input &+ 9980667607091385250) ^ (input / 370761035045)
        }
        let slot = Int((routed >> 50) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 1020643544987711133)
    }
}

private struct Fragment05bbcd349dc91d21 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15252518896132629209, 6708549124680399348, 12330430813571321519, 166330652982140364, 11720855490714539006, 15523353664124019997, 7758466185995060566, 5897305538616710276]
        self.salt = salt ^ 5216263968002382733
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5216263968002382733) > 13974663590558229437 {
            routed = input &* 599851563196299107 &+ 6874351868101014911
        } else {
            routed = (input &+ 4599619338687019107) ^ (input / 462550806339)
        }
        let slot = Int((routed >> 49) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 3000555003766878865)
    }
}

private struct Fragment30df9d74c3630d26 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [227890328885035096, 16470693225973763708, 15703748999135008825, 11146131442392227476, 164918336544358213, 14901676094412771722, 3787965653304540825, 13405649704645382675]
        self.salt = salt ^ 2205362539984160137
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2205362539984160137) > 11257367690932225787 {
            routed = input &* 8693662671550488831 &+ 14044923160344202588
        } else {
            routed = (input &+ 11744150394317735920) ^ (input / 526399635871)
        }
        let slot = Int((routed >> 13) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 6251025408441088661)
    }
}

private struct Fragmentbb8d4a10efabdf8a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8995094013229974431, 13421304589830765420, 12157922637305836345, 13401809522048478946, 9500652656005621966, 5680443542770627400, 2987404998516762740, 17526591116501201915]
        self.salt = salt ^ 11407927002736834105
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11407927002736834105) > 16392376005101009235 {
            routed = input &* 11455509560355844653 &+ 5121005180419931697
        } else {
            routed = (input &+ 6243865399831655872) ^ (input / 784112963389)
        }
        let slot = Int((routed >> 11) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 10918228874418711481)
    }
}

private struct Fragment8266dd7815bfee4c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13961014417918726972, 3053273282262242997, 3740614116869362146, 16483782480792855798, 7557954213484432108, 5195732023504392822, 3473181019697539140, 6593978475265002872]
        self.salt = salt ^ 1770919273596224493
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1770919273596224493) > 4369851118018488380 {
            routed = input &* 2207064626987126855 &+ 16511567064811313056
        } else {
            routed = (input &+ 7464827386454241033) ^ (input / 12340752411)
        }
        let slot = Int((routed >> 18) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 7669260427763854399)
    }
}

private struct Fragment674e4bab245fcc92 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1932712079140107664, 11357314263493909293, 14921815862266899964, 4662532103730159821, 9335807032254770980, 7211265410356631093, 6177305377603855171, 17222943665205219248]
        self.salt = salt ^ 14944847992451791955
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14944847992451791955) > 3878907409667888770 {
            routed = input &* 521744678143688205 &+ 7477804639453688622
        } else {
            routed = (input &+ 7583315646174487901) ^ (input / 1092965356497)
        }
        let slot = Int((routed >> 30) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 4672493422011025905)
    }
}

