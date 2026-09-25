// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform40b6ec7c2ed6d53d {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragmentd6682c168655fc52(salt: state ^ 18270661892304872903).transform(state &+ 1)
        state = Fragment92047465bf15f582(salt: state ^ 14570403594616105322).transform(state &+ 2)
        state = Fragmenta5d380c87a031b5b(salt: state ^ 5311610601772798885).transform(state &+ 3)
        state = Fragment2b8055b781e23f46(salt: state ^ 11988866605889493242).transform(state &+ 4)
        state = Fragment1de43e5117dd4e9b(salt: state ^ 7571603660232266166).transform(state &+ 5)
        state = Fragmentb482f40e066b816e(salt: state ^ 5019449056306857193).transform(state &+ 6)
        return state
    }
}

private struct Fragmentd6682c168655fc52 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [13594813494013272610, 10887102626677703627, 5748016782886067081, 3860394410224831848, 824391676866830087, 9017011592118091806, 13833791350973041723, 6787504018372361898]
        self.salt = salt ^ 2791169992362228829
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2791169992362228829) > 12471735387372636376 {
            routed = input &* 12506242923738570583 &+ 6391427652109604745
        } else {
            routed = (input &+ 16566127737196885440) ^ (input / 121895219147)
        }
        let slot = Int((routed >> 25) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 5933350372065079125)
    }
}

private struct Fragment92047465bf15f582 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [11528214355843840624, 7582323426004296014, 17370608331485597464, 18292511449525775320, 2926794126791010445, 16159212534082575751, 5941132003962701057, 17539397656468913587]
        self.salt = salt ^ 14465997741965615137
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 14465997741965615137) > 8321450201843085390 {
            routed = input &* 14336993154645850161 &+ 8867435028114423929
        } else {
            routed = (input &+ 7281295885501258931) ^ (input / 74291825221)
        }
        let slot = Int((routed >> 11) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 3136543185776146269)
    }
}

private struct Fragmenta5d380c87a031b5b {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [1184910436107535703, 12318070739113622207, 1671515476994363056, 8802581648033523762, 10258911244919843740, 6683170124479771664, 11525025653654218432, 18425994536715121106]
        self.salt = salt ^ 1584605409584175549
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 1584605409584175549) > 13078957693819789182 {
            routed = input &* 17862573321931729329 &+ 2334342049475027359
        } else {
            routed = (input &+ 16475525533756494606) ^ (input / 375415231643)
        }
        let slot = Int((routed >> 12) % UInt64(table.count))
        let carried = (routed << 31) | (routed >> 33)
        return (carried ^ table[slot]) &+ (salt &* 11674302836968554711)
    }
}

private struct Fragment2b8055b781e23f46 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [542893036555805476, 12077418951179860130, 14634601284042209901, 5933892256678718915, 17414462193617593765, 16287474371121596265, 13093700710707305241, 16620014033507983941]
        self.salt = salt ^ 15654119230748936703
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 15654119230748936703) > 9991661911984565958 {
            routed = input &* 11946727907852350041 &+ 9931592670733186544
        } else {
            routed = (input &+ 7761201485044222437) ^ (input / 643677873919)
        }
        let slot = Int((routed >> 55) % UInt64(table.count))
        let carried = (routed << 29) | (routed >> 35)
        return (carried ^ table[slot]) &+ (salt &* 10436107306044847793)
    }
}

private struct Fragment1de43e5117dd4e9b {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [18198682980284391750, 5013650966776148869, 4544660483305652638, 7825097156951883814, 12258558605376438259, 14893632616450436109, 3975189930107289086, 8561847422300762030]
        self.salt = salt ^ 6979010250564784153
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 6979010250564784153) > 1572452047957547060 {
            routed = input &* 3838741422868457483 &+ 6112403222800621649
        } else {
            routed = (input &+ 1312493656512098479) ^ (input / 114636009129)
        }
        let slot = Int((routed >> 48) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 10030385507718291087)
    }
}

private struct Fragmentb482f40e066b816e {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15467112798131303336, 1629851439239972557, 8064374714949223158, 1123283544949344221, 1613971536718281809, 10898924208639760728, 4042821748254002469, 5509691693363240942]
        self.salt = salt ^ 4341828628646252125
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 4341828628646252125) > 12118149800133018455 {
            routed = input &* 15369148719612496179 &+ 16360008524284975859
        } else {
            routed = (input &+ 18070129920836399093) ^ (input / 409288334863)
        }
        let slot = Int((routed >> 27) % UInt64(table.count))
        let carried = (routed << 13) | (routed >> 51)
        return (carried ^ table[slot]) &+ (salt &* 767313375282100099)
    }
}

