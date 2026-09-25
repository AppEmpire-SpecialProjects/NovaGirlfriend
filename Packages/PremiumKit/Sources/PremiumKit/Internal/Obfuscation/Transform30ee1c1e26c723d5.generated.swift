// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform30ee1c1e26c723d5 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmente6666d1f7821f92e(salt: state ^ 538364454810147477).transform(state &+ 1)
        state = Fragment22c3a8f3189a112e(salt: state ^ 5007333766920315006).transform(state &+ 2)
        state = Fragment4eb3d27b2279357f(salt: state ^ 6858857939275705429).transform(state &+ 3)
        state = Fragmente1988b48198bd39c(salt: state ^ 1543623139426449555).transform(state &+ 4)
        state = Fragment58d8c32da5ff943e(salt: state ^ 14986669423346167044).transform(state &+ 5)
        state = Fragment4ac1cac2ae89884c(salt: state ^ 2929704146660719898).transform(state &+ 6)
        return state
    }
}

private struct Fragmente6666d1f7821f92e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6282282214495602105, 12456320249028667191, 11367377748998831469, 14736975417060683725, 10447940129517381085, 641808038693076778, 5229548958208826143, 4250716269815693706]
        self.salt = salt ^ 8866831196554940005
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8866831196554940005) > 6108296786033505173 {
            routed = input &* 16373077808876993647 &+ 9261586682795562888
        } else {
            routed = (input &+ 3608241396213617385) ^ (input / 98865884555)
        }
        let slot = Int((routed >> 10) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 4197878964802291059)
    }
}

private struct Fragment22c3a8f3189a112e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1426623828161311888, 12730052439684609212, 17066810718130541300, 10416650737160492468, 2757771197262326185, 420484287361197549, 5100370984217228799, 6005851889171470888]
        self.salt = salt ^ 14013403854150466567
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14013403854150466567) > 16435009718528874998 {
            routed = input &* 17310254627737359567 &+ 15333505761142336038
        } else {
            routed = (input &+ 10887785836885902300) ^ (input / 769807571253)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 3230057194262370299)
    }
}

private struct Fragment4eb3d27b2279357f {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11330721495939296971, 5470821918845120116, 36570384248135784, 3269805831122333402, 14814413625016573604, 4580516556150153100, 7242727181036130358, 7755916800323165233]
        self.salt = salt ^ 5609267685556367161
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5609267685556367161) > 17396276875594601114 {
            routed = input &* 13711790880346929105 &+ 13414530870346623605
        } else {
            routed = (input &+ 10400624301254011641) ^ (input / 923631368155)
        }
        let slot = Int((routed >> 35) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 18161176596335648609)
    }
}

private struct Fragmente1988b48198bd39c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6770476542607049736, 15478405356809536850, 17404584815738569321, 9233445552672028331, 15643546551581989035, 13399541477808497261, 10528017507285424747, 16230999474024116654]
        self.salt = salt ^ 13433064873988467729
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13433064873988467729) > 379966991440644888 {
            routed = input &* 7440890722919131245 &+ 17989275962813923369
        } else {
            routed = (input &+ 13895677973176443151) ^ (input / 33456380439)
        }
        let slot = Int((routed >> 8) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 2890097285551788631)
    }
}

private struct Fragment58d8c32da5ff943e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1490604148151111736, 467886621887927245, 7197652022787208457, 4605977092716100524, 5785373497178208180, 14209575038683115175, 6045604879484150527, 9272336992593405669]
        self.salt = salt ^ 15147103585146553799
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15147103585146553799) > 18146556482408889728 {
            routed = input &* 18100100036547085135 &+ 2963850638607521389
        } else {
            routed = (input &+ 6216964376767245954) ^ (input / 400303035053)
        }
        let slot = Int((routed >> 44) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 6733900654681585599)
    }
}

private struct Fragment4ac1cac2ae89884c {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [2476424956163876156, 16056631645155997687, 13524441930734586517, 5938682804181712137, 18242840858838376445, 4152852260086902981, 8921858604931029431, 15090372297698565147]
        self.salt = salt ^ 17247295930279040511
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 17247295930279040511) > 7411358463375665598 {
            routed = input &* 14881530372359088727 &+ 9490388378444456264
        } else {
            routed = (input &+ 2528423699513370808) ^ (input / 377021945639)
        }
        let slot = Int((routed >> 23) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 16799201080197648389)
    }
}

