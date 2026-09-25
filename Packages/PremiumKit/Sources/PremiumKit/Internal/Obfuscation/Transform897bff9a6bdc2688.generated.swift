// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform897bff9a6bdc2688 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment82686c0c114aa976(salt: state ^ 3755764913301138395).transform(state &+ 1)
        state = Fragment467f145fa304f427(salt: state ^ 5015209094969519578).transform(state &+ 2)
        state = Fragment19c3392414948d9a(salt: state ^ 17333857743802904919).transform(state &+ 3)
        state = Fragment2d584f4d623a3138(salt: state ^ 4398225933390456693).transform(state &+ 4)
        state = Fragment29e98ecb17d761a2(salt: state ^ 9616017189695675602).transform(state &+ 5)
        state = Fragment9a6393e9719495ae(salt: state ^ 6702642296475933659).transform(state &+ 6)
        return state
    }
}

private struct Fragment82686c0c114aa976 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15094102359003043097, 8634928648972045055, 17867992267661700791, 13552557914371226214, 11723065758935309675, 8482286974132681745, 16048489201917482484, 3026585577706600420]
        self.salt = salt ^ 4055996311181951843
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4055996311181951843) > 8936751782250990920 {
            routed = input &* 47821469141119139 &+ 2837594752662036084
        } else {
            routed = (input &+ 16351544604747331865) ^ (input / 1044510725497)
        }
        let slot = Int((routed >> 9) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 1701920304171561097)
    }
}

private struct Fragment467f145fa304f427 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6735086384587359062, 7758813829987862256, 6765543920771123345, 8059234403696815820, 1501276880187877728, 6304873417462396874, 17471253121368041180, 17306423187601229216]
        self.salt = salt ^ 6614020414009380179
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6614020414009380179) > 12243907047349965980 {
            routed = input &* 15368432085029638881 &+ 4869138406786744312
        } else {
            routed = (input &+ 5172659918272442568) ^ (input / 337031059041)
        }
        let slot = Int((routed >> 48) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 6291692737173037105)
    }
}

private struct Fragment19c3392414948d9a {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3627299050552151858, 1177414512362913708, 13360775215112871172, 4272550607818210462, 1844711269577464180, 13570061816506250793, 9097043770253765831, 2529701317969093005]
        self.salt = salt ^ 8551306331292724305
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8551306331292724305) > 9267499181536493744 {
            routed = input &* 17366185214338000143 &+ 3197716056797128908
        } else {
            routed = (input &+ 11319618622361250953) ^ (input / 24890314327)
        }
        let slot = Int((routed >> 54) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 4696302693399677155)
    }
}

private struct Fragment2d584f4d623a3138 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12826320548745522301, 15092192518298554118, 12153524207696128967, 54759440442364345, 7193902041726811281, 829332711754137457, 9427489833815473164, 12781929779150482392]
        self.salt = salt ^ 3504986049516397005
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 3504986049516397005) > 12510816288457509506 {
            routed = input &* 5384114317477935617 &+ 2479968976179623841
        } else {
            routed = (input &+ 4844844959142152275) ^ (input / 8474837521)
        }
        let slot = Int((routed >> 3) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 3677723109974242133)
    }
}

private struct Fragment29e98ecb17d761a2 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6751226149733985635, 11476012887565955270, 1550526137425667257, 9386499688657637722, 5099563596520709310, 13710891681161642052, 2690475597128134186, 18326986941434326687]
        self.salt = salt ^ 11031148910842299857
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11031148910842299857) > 11071198511800729193 {
            routed = input &* 16590906966106857259 &+ 731782746746902980
        } else {
            routed = (input &+ 5796738670928854149) ^ (input / 223156319189)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 1936717155273660313)
    }
}

private struct Fragment9a6393e9719495ae {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18308339810364963917, 9714346131265219464, 2039371433847403359, 920082082873715041, 337690858432332192, 13521498503398425887, 3112814278385386595, 5482328812857186821]
        self.salt = salt ^ 14110481785928778711
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14110481785928778711) > 20816994552156538 {
            routed = input &* 2940799371635958303 &+ 6770125524024792917
        } else {
            routed = (input &+ 13517528752229488701) ^ (input / 158168096335)
        }
        let slot = Int((routed >> 2) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 5336347955953544859)
    }
}

