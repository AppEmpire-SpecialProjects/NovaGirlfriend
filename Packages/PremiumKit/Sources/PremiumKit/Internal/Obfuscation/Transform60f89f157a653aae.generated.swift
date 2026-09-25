// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform60f89f157a653aae {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment49b8e4d2c5f3efa6(salt: state ^ 10088029071591407163).transform(state &+ 1)
        state = Fragment02dfbfb689038693(salt: state ^ 7188765367971135530).transform(state &+ 2)
        state = Fragmenta763beb5228dc9d4(salt: state ^ 13048374560381998500).transform(state &+ 3)
        state = Fragmente431d908472f48ea(salt: state ^ 4201929899418526681).transform(state &+ 4)
        state = Fragment425293ff8dab2575(salt: state ^ 17817664649327405868).transform(state &+ 5)
        state = Fragment2612a04b27a3bb4b(salt: state ^ 9355724630422825050).transform(state &+ 6)
        return state
    }
}

private struct Fragment49b8e4d2c5f3efa6 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14275241401618312793, 709692033708386674, 17824843392852685372, 2436970876500579020, 14245142844395395624, 17998031902750701504, 3928718884790984786, 16457953706282553912]
        self.salt = salt ^ 13044576854773966077
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13044576854773966077) > 12795088619128859067 {
            routed = input &* 1480127816707418071 &+ 9155919992429054915
        } else {
            routed = (input &+ 11402039576919917225) ^ (input / 265453720431)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 10862193136588281779)
    }
}

private struct Fragment02dfbfb689038693 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3644605463302344180, 17189846928014366920, 12122610600679391793, 2693385736022012324, 11547991156132529368, 92269118954162143, 2476832649739385643, 5497799479072711566]
        self.salt = salt ^ 4122896563044602129
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4122896563044602129) > 17073027444944510451 {
            routed = input &* 1752502017756206297 &+ 189861375332046125
        } else {
            routed = (input &+ 2047228100614795749) ^ (input / 624587252419)
        }
        let slot = Int((routed >> 33) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 16290004975596874103)
    }
}

private struct Fragmenta763beb5228dc9d4 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15681974203226233640, 11483152361476395011, 4560735251058160804, 4656433001235501630, 2353808777548107604, 857932736691628799, 5048467745313909317, 1026359924528078397]
        self.salt = salt ^ 2490521881371231965
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2490521881371231965) > 9720116302399273911 {
            routed = input &* 7679729665480745525 &+ 11225222762399582225
        } else {
            routed = (input &+ 14566186027412054244) ^ (input / 838948817395)
        }
        let slot = Int((routed >> 35) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 7607840669953421915)
    }
}

private struct Fragmente431d908472f48ea {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5879620206410000219, 3638875866722126214, 1565319596964589575, 5325474998744400918, 10842330789748223883, 13998221598789177421, 17204954576403462339, 16808598601132761065]
        self.salt = salt ^ 17705455386426956485
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17705455386426956485) > 12179954325920622968 {
            routed = input &* 8171684951014492975 &+ 14118108486689783045
        } else {
            routed = (input &+ 7115026699716624881) ^ (input / 634358966479)
        }
        let slot = Int((routed >> 14) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 3920363150101100751)
    }
}

private struct Fragment425293ff8dab2575 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [5470790410744398894, 10171378428403230805, 1310820537637780637, 13414390425446628670, 9880413576713933233, 3056496345574472206, 14934207239544926871, 12102316538781309723]
        self.salt = salt ^ 13012147286575291553
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13012147286575291553) > 8349651766956245030 {
            routed = input &* 8107376437507421421 &+ 1084675651350323108
        } else {
            routed = (input &+ 12320956480179104390) ^ (input / 999531963789)
        }
        let slot = Int((routed >> 20) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 8019877521088161043)
    }
}

private struct Fragment2612a04b27a3bb4b {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [7634893206700527140, 15329646686448191267, 6849638513773029301, 920845456607821280, 6548672137860480505, 11947092750240059287, 16308451522140022368, 17843601830016992105]
        self.salt = salt ^ 7354271310072014399
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 7354271310072014399) > 931712938344222104 {
            routed = input &* 4564294818909596937 &+ 5169268880916150844
        } else {
            routed = (input &+ 5597988836434826064) ^ (input / 397330739877)
        }
        let slot = Int((routed >> 23) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 16272965647854157995)
    }
}

