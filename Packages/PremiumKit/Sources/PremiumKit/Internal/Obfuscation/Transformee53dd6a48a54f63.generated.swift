// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformee53dd6a48a54f63 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment81a5a1c2ef5cfa52(salt: state ^ 15505624020332941242).transform(state &+ 1)
        state = Fragmented1c9a5c03821045(salt: state ^ 12990568608147352937).transform(state &+ 2)
        state = Fragmentfdc6a685dd434927(salt: state ^ 2299829610117392027).transform(state &+ 3)
        state = Fragment768587ddf7e76315(salt: state ^ 15080122263690428842).transform(state &+ 4)
        state = Fragment9450cbf0d68af770(salt: state ^ 15123373962728459946).transform(state &+ 5)
        state = Fragment58447cc713626ee6(salt: state ^ 2148132380781901030).transform(state &+ 6)
        return state
    }
}

private struct Fragment81a5a1c2ef5cfa52 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [16575094267861141140, 14568516644031977517, 5931311434418590374, 15212886931833409484, 15364779744543877922, 327906960772035599, 8348861327750072163, 11264811259422166104]
        self.salt = salt ^ 11297980553349721917
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11297980553349721917) > 10338916875395223145 {
            routed = input &* 3669175077374836503 &+ 3866725959603082740
        } else {
            routed = (input &+ 4434722197040241031) ^ (input / 985429300695)
        }
        let slot = Int((routed >> 20) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 7378824836576642235)
    }
}

private struct Fragmented1c9a5c03821045 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [16284500428915482714, 235523916866203672, 874584288153048199, 887843579812635047, 13797467098784586833, 10065102836703174114, 247558083400930205, 4023699167325500049]
        self.salt = salt ^ 12981930159164221037
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 12981930159164221037) > 8051502661427806629 {
            routed = input &* 13016379663419565577 &+ 17614700751288065361
        } else {
            routed = (input &+ 15719650616643485202) ^ (input / 487722951343)
        }
        let slot = Int((routed >> 22) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 9456788688677784721)
    }
}

private struct Fragmentfdc6a685dd434927 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [8239843701322450964, 8121746218031500858, 16235334464659757854, 6443990967925442242, 10745786418421794677, 10604228679502699656, 17625183718908016006, 6899660041190837651]
        self.salt = salt ^ 15643225277051902411
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15643225277051902411) > 14851695943917982867 {
            routed = input &* 6118281686166312811 &+ 11124069737624695226
        } else {
            routed = (input &+ 13146776919000495202) ^ (input / 570367908183)
        }
        let slot = Int((routed >> 26) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 6918878086407995035)
    }
}

private struct Fragment768587ddf7e76315 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [16166919047047457177, 2036222853792214358, 13638153352382349140, 11305712845261129620, 3697898421491056370, 8049345205573896857, 13268895394654912617, 18033935322254277367]
        self.salt = salt ^ 3149900716139521801
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 3149900716139521801) > 1657292284487219458 {
            routed = input &* 15432710436582862585 &+ 11111737011454129184
        } else {
            routed = (input &+ 15006299243465085308) ^ (input / 633790929073)
        }
        let slot = Int((routed >> 22) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 6359103581550354891)
    }
}

private struct Fragment9450cbf0d68af770 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14545111502804448627, 1109789017582149698, 5363259988921421907, 8138895522068571267, 6403559650455021762, 5455476115485902121, 545078464273048326, 3273725371341953405]
        self.salt = salt ^ 6420288273020335335
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6420288273020335335) > 1907270857991967811 {
            routed = input &* 3419042223656616165 &+ 10322453747005853186
        } else {
            routed = (input &+ 3217215818064898889) ^ (input / 934048008949)
        }
        let slot = Int((routed >> 17) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 3861617410512843379)
    }
}

private struct Fragment58447cc713626ee6 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12994711085465976769, 18151216255436386442, 15323065650503030100, 9394726789577779276, 9068172656466056828, 9631969155245239553, 10237833082125496552, 13803117555589793257]
        self.salt = salt ^ 16158901531176944387
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 16158901531176944387) > 7803320196812090876 {
            routed = input &* 2288199193917622631 &+ 8487825299567132227
        } else {
            routed = (input &+ 10853520328245198013) ^ (input / 922282515073)
        }
        let slot = Int((routed >> 30) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 18226201609454894797)
    }
}

