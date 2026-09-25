// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform7e699ce0a4b88198 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment560b3e3b96c57b3d(salt: state ^ 7391952153612999223).transform(state &+ 1)
        state = Fragment613204c2c9c056e9(salt: state ^ 9042868252856322937).transform(state &+ 2)
        state = Fragmentceb6cf47249f9531(salt: state ^ 11822128393101876405).transform(state &+ 3)
        state = Fragmentd324cac83be7fe39(salt: state ^ 12190919596934102572).transform(state &+ 4)
        state = Fragmentb2aee9683713c5a1(salt: state ^ 13786228845134952388).transform(state &+ 5)
        state = Fragmentaca707f5a9f083b5(salt: state ^ 7229811663913510631).transform(state &+ 6)
        return state
    }
}

private struct Fragment560b3e3b96c57b3d {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3505137313186550301, 9176872480591477671, 8314323894938850538, 2393786634466700801, 1394044732486341013, 5609273334286397899, 3999832328470133078, 16549137349547581103]
        self.salt = salt ^ 4781119801138585241
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4781119801138585241) > 17279253658665637302 {
            routed = input &* 10801365677924571459 &+ 6867972693704184106
        } else {
            routed = (input &+ 5135072328428842778) ^ (input / 881929192363)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 13730737805977179275)
    }
}

private struct Fragment613204c2c9c056e9 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [9527232315535235848, 13998828989485906835, 4772641645862060248, 2196102171876343259, 10091636539135400501, 8938096420977988209, 506277556984547356, 13098878560359395282]
        self.salt = salt ^ 10591308731263581469
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10591308731263581469) > 15861494586473538818 {
            routed = input &* 15781416238496770147 &+ 2211893148180579301
        } else {
            routed = (input &+ 192089459367432089) ^ (input / 885951672053)
        }
        let slot = Int((routed >> 32) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 15502491951808088879)
    }
}

private struct Fragmentceb6cf47249f9531 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6319362915494561228, 17124590461485876744, 7365514370304605016, 6416359204972244043, 3785022957678573139, 5213266462952790087, 885486245237739942, 9359121794513380998]
        self.salt = salt ^ 2735790079323720271
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2735790079323720271) > 17019531115284373707 {
            routed = input &* 16097347286379338095 &+ 8941585807636560268
        } else {
            routed = (input &+ 687289205916748640) ^ (input / 963318334639)
        }
        let slot = Int((routed >> 49) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 6823500558223164591)
    }
}

private struct Fragmentd324cac83be7fe39 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12262898616824443883, 14633144293945251614, 11154520611795437240, 14245956525128349005, 8199117508286452900, 4590795677675020599, 7558893831306584839, 13130633407201386433]
        self.salt = salt ^ 7362020943764386749
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 7362020943764386749) > 11029191874744759382 {
            routed = input &* 4382424746934153627 &+ 9700639010584456732
        } else {
            routed = (input &+ 538207217946862506) ^ (input / 288214435591)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 2636948395027331911)
    }
}

private struct Fragmentb2aee9683713c5a1 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8333307219850717967, 18270116438474272655, 16353151662808885797, 15791278819122010662, 865270665734162652, 917879294151049002, 2978174337187461854, 16356147605409621640]
        self.salt = salt ^ 11279847773630747223
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11279847773630747223) > 14294028648137114156 {
            routed = input &* 5676310317190033543 &+ 9439434065991823292
        } else {
            routed = (input &+ 4503051789593277426) ^ (input / 438543172417)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 5317986786210171037)
    }
}

private struct Fragmentaca707f5a9f083b5 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11197999664065415612, 11922089848139881825, 13576256652045745571, 6527606050776061911, 5932879525531646172, 2925659675455479266, 14715192725908284935, 10534645069830574281]
        self.salt = salt ^ 17282602311286916385
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17282602311286916385) > 16105259484478625293 {
            routed = input &* 4158788080593255161 &+ 2467540275082701343
        } else {
            routed = (input &+ 12020919360802080481) ^ (input / 144841500113)
        }
        let slot = Int((routed >> 20) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 3835358198386527057)
    }
}

