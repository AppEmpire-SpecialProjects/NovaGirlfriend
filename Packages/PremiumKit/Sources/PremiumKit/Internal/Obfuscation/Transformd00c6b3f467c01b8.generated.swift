// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transformd00c6b3f467c01b8 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentf937c71cb8cc4989(salt: state ^ 7657150919874195939).transform(state &+ 1)
        state = Fragment7e23e1fb3eb53492(salt: state ^ 10276884145286967259).transform(state &+ 2)
        state = Fragment5d5cb157636ba5fe(salt: state ^ 15042296212458240528).transform(state &+ 3)
        state = Fragmente7afaec82091ef31(salt: state ^ 15289229836494100749).transform(state &+ 4)
        state = Fragment525cb4a6a3710bcd(salt: state ^ 5556041917040494422).transform(state &+ 5)
        state = Fragment15211907d539dbde(salt: state ^ 6601773024648593811).transform(state &+ 6)
        return state
    }
}

private struct Fragmentf937c71cb8cc4989 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [12463223521228348247, 3223420259032526266, 16063070142296728290, 15342629274685193278, 15146933802230405440, 5594405177663791204, 6551065320145254772, 13951611750801718574]
        self.salt = salt ^ 13200780352351850335
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13200780352351850335) > 12072503709502763102 {
            routed = input &* 18153113327817821947 &+ 11922206037395842921
        } else {
            routed = (input &+ 11323114951085738637) ^ (input / 329502745679)
        }
        let slot = Int((routed >> 32) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 5668621118497054341)
    }
}

private struct Fragment7e23e1fb3eb53492 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1806386458838567294, 5003945777150242450, 16536447258466938019, 15339263458971940028, 4015993991505026854, 12010595026960791083, 570733037751123347, 6574138431795453171]
        self.salt = salt ^ 8920050812996921679
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 8920050812996921679) > 1743461546324973145 {
            routed = input &* 8979823199399921185 &+ 16544024783954377303
        } else {
            routed = (input &+ 15961379694890961533) ^ (input / 1001250499117)
        }
        let slot = Int((routed >> 32) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 5727568043467823917)
    }
}

private struct Fragment5d5cb157636ba5fe {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3643761036724741652, 8151643918292210482, 12052085363290421378, 2292678455406787601, 1414745024739180584, 13914875373694019126, 14766999182359600474, 3838199843655281893]
        self.salt = salt ^ 3840636693195399153
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 3840636693195399153) > 17329841491920970522 {
            routed = input &* 4156090348702487589 &+ 11703044867685566656
        } else {
            routed = (input &+ 10598605349385757395) ^ (input / 774962631717)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 2724488550320844553)
    }
}

private struct Fragmente7afaec82091ef31 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17735377303806865926, 10783149707039612618, 12107337020873880292, 2987269659967945566, 14178121640118886979, 2284843422441408896, 4773623508831846922, 8372969077433729496]
        self.salt = salt ^ 15086109531148725011
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15086109531148725011) > 15902257123372737921 {
            routed = input &* 78028945219984101 &+ 803217872134895300
        } else {
            routed = (input &+ 3406185670510365285) ^ (input / 1034851161737)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 930071386805491027)
    }
}

private struct Fragment525cb4a6a3710bcd {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [6839848966964831402, 12211241303359413694, 5387300455826967845, 11516839068208630392, 13858821794785921794, 15537733801980841775, 11472480316184203665, 8808269798864765350]
        self.salt = salt ^ 9349875078429941577
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 9349875078429941577) > 10858431183684653801 {
            routed = input &* 8784040039351828455 &+ 18310711035591269330
        } else {
            routed = (input &+ 10530465725602608012) ^ (input / 1019690661829)
        }
        let slot = Int((routed >> 52) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 2977558790032257839)
    }
}

private struct Fragment15211907d539dbde {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [4041510834973076795, 11424140334810928868, 13459351054937472226, 8603471214167509853, 15716165553564980640, 6810563023622425989, 16482494308138433081, 14723411635532960668]
        self.salt = salt ^ 4466098525690807297
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4466098525690807297) > 1960375740806792888 {
            routed = input &* 2956034872307227761 &+ 13384058125028007029
        } else {
            routed = (input &+ 2928258979954899487) ^ (input / 116493677663)
        }
        let slot = Int((routed >> 2) % UInt64(table.count))
        let carried = (routed << 11) | (routed >> 53)
        return (carried ^ table[slot]) &+ (salt &* 17347612937084034837)
    }
}

