// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformea6b30f3c5e35202 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentbca7b140e3755369(salt: state ^ 5397981467372868163).transform(state &+ 1)
        state = Fragmente62a98a2a25839d2(salt: state ^ 6742997766845600950).transform(state &+ 2)
        state = Fragment468dea80c0cf288e(salt: state ^ 16378150599024379622).transform(state &+ 3)
        state = Fragment7f3e9a8f27ca0a4f(salt: state ^ 10275899518526208754).transform(state &+ 4)
        state = Fragment38fc38534ac5f0eb(salt: state ^ 12125935686155179901).transform(state &+ 5)
        state = Fragmentaf9c14756b7083e9(salt: state ^ 16455238004584253709).transform(state &+ 6)
        return state
    }
}

private struct Fragmentbca7b140e3755369 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6830664809034687075, 11294244394762425824, 11739666026671080122, 10279849574312314362, 3346450773616225519, 6523449397403860785, 7288857791663632083, 16089421991933825327]
        self.salt = salt ^ 11407900681767539167
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11407900681767539167) > 13412009897591508035 {
            routed = input &* 5100845533258556345 &+ 13938411560036673005
        } else {
            routed = (input &+ 10511642655003830263) ^ (input / 491675274179)
        }
        let slot = Int((routed >> 1) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 7224095144093510969)
    }
}

private struct Fragmente62a98a2a25839d2 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6344183832349627584, 16422803210125791734, 3803694227657929797, 17958186095359726009, 16834726340948982360, 3860143168618427714, 15506923311423946190, 5582736458813608000]
        self.salt = salt ^ 9221260584125224561
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9221260584125224561) > 4039089669386447254 {
            routed = input &* 8290676188090747261 &+ 8720214495860192370
        } else {
            routed = (input &+ 15248251093482861160) ^ (input / 332807584449)
        }
        let slot = Int((routed >> 11) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 7501453107585298675)
    }
}

private struct Fragment468dea80c0cf288e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15280169424784961684, 7768401745388732860, 17930495327775100741, 7024293616895344606, 4989130104999276299, 6785523141902380318, 2303049030165365811, 4658048963406296619]
        self.salt = salt ^ 14275985731408836155
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14275985731408836155) > 15830126087144619955 {
            routed = input &* 5906991528217446833 &+ 12281203675686382857
        } else {
            routed = (input &+ 14320681330579680719) ^ (input / 273584660499)
        }
        let slot = Int((routed >> 16) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 3035757386087414145)
    }
}

private struct Fragment7f3e9a8f27ca0a4f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [14964676658737771093, 5352185919879830080, 10990102576905544523, 14180046994097392987, 13889021856266521611, 18233323233486534657, 9662388117674803859, 5078006074168223980]
        self.salt = salt ^ 9544730141456653995
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9544730141456653995) > 7352952148141302579 {
            routed = input &* 15640432589397791595 &+ 11819624330504464279
        } else {
            routed = (input &+ 446677624515764784) ^ (input / 634810593601)
        }
        let slot = Int((routed >> 33) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 15703262051635001277)
    }
}

private struct Fragment38fc38534ac5f0eb {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11166243256878217232, 3010197033966084270, 7082901320783163814, 653748259324789411, 3630842451730005201, 8301180407230627957, 6892908413253427725, 3477045947873313187]
        self.salt = salt ^ 10340457002398102753
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 10340457002398102753) > 9638450441573167534 {
            routed = input &* 918765628107503943 &+ 13164564997657925546
        } else {
            routed = (input &+ 522895571879194364) ^ (input / 1097461125855)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 1530317537051971979)
    }
}

private struct Fragmentaf9c14756b7083e9 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18145862200509963032, 12837280582993103841, 12820893867562322968, 2339068591633411567, 756448754064795933, 5035946766863000817, 4635073632981294791, 5234086498205568000]
        self.salt = salt ^ 2623551523640935181
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2623551523640935181) > 5189012492878934050 {
            routed = input &* 5389187004100497133 &+ 15122488784037900035
        } else {
            routed = (input &+ 11680490585848129395) ^ (input / 1064050408399)
        }
        let slot = Int((routed >> 21) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 11046055338370133253)
    }
}

