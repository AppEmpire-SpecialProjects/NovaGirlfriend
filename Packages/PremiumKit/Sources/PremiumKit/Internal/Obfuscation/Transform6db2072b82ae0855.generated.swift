// Generated source diversification. Regenerate from a clean clone; do not edit.
internal enum Transform6db2072b82ae0855 {
    @inline(never)
    static func mix(_ input: UInt64) -> UInt64 {
        var state = input
        state = Fragment4a4b4142fa0f9b85(salt: state ^ 16832486748280629839).transform(state &+ 1)
        state = Fragment30c20646747afacd(salt: state ^ 16367598676712977721).transform(state &+ 2)
        state = Fragment6b08f0dd1d7348b7(salt: state ^ 7093177825248286201).transform(state &+ 3)
        state = Fragment4a6b16846d3390d9(salt: state ^ 10625106886827916320).transform(state &+ 4)
        state = Fragmentc35aaad3ac87edf2(salt: state ^ 15753437523432398891).transform(state &+ 5)
        state = Fragment13fdeacb61d12713(salt: state ^ 5169398733953444527).transform(state &+ 6)
        return state
    }
}

private struct Fragment4a4b4142fa0f9b85 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15331756432490777296, 11983297531262736602, 11199457181044943047, 18339591164587012341, 7872908803974009621, 1811013120911193897, 10181204821986880711, 5590930693889625228]
        self.salt = salt ^ 5873371110257887123
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 5873371110257887123) > 918932483992954216 {
            routed = input &* 10495913807198855369 &+ 5605000046245340788
        } else {
            routed = (input &+ 6949641466472516735) ^ (input / 545298468161)
        }
        let slot = Int((routed >> 38) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 1452565591971337773)
    }
}

private struct Fragment30c20646747afacd {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10092418715313431134, 16981650115111928846, 11802878548375348250, 2269903941429779345, 6456047760819573276, 12543152991157531320, 1814082077967503867, 12681265341322642659]
        self.salt = salt ^ 2396137463107878791
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2396137463107878791) > 8673295178410204400 {
            routed = input &* 8863121359004184577 &+ 1005695579774364056
        } else {
            routed = (input &+ 397091325541277069) ^ (input / 726605143903)
        }
        let slot = Int((routed >> 31) % UInt64(table.count))
        let carried = (routed << 19) | (routed >> 45)
        return (carried ^ table[slot]) &+ (salt &* 8525929724158442003)
    }
}

private struct Fragment6b08f0dd1d7348b7 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [15912834079485678627, 11822437620016421481, 17345514165335603083, 9576630476207347821, 7376382752311262037, 9729088850226185922, 4829080233058611678, 16686058730442047712]
        self.salt = salt ^ 11353627239511717617
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11353627239511717617) > 12036841455663285191 {
            routed = input &* 7458218978131723099 &+ 17688927147396157764
        } else {
            routed = (input &+ 4805676019700137203) ^ (input / 508155661323)
        }
        let slot = Int((routed >> 30) % UInt64(table.count))
        let carried = (routed << 7) | (routed >> 57)
        return (carried ^ table[slot]) &+ (salt &* 5546020031143383443)
    }
}

private struct Fragment4a6b16846d3390d9 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [3314299254308061873, 17150002398233707575, 9259830976694493264, 12971843104161450989, 3058070417253983358, 1395419106548041185, 17417481166561973384, 9481659176051838422]
        self.salt = salt ^ 11489942596008703091
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 11489942596008703091) > 4386740880358392732 {
            routed = input &* 6325778818328449825 &+ 719043002875696715
        } else {
            routed = (input &+ 11741849562681129145) ^ (input / 228804912405)
        }
        let slot = Int((routed >> 17) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 10383989726967253071)
    }
}

private struct Fragmentc35aaad3ac87edf2 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [17197686653836558757, 5627374000323608501, 13327621530473790614, 17555940209279130273, 733787454313455598, 15535051069578362918, 18293404225835595509, 3104312764541314105]
        self.salt = salt ^ 2145314171661001809
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 2145314171661001809) > 601249602992309748 {
            routed = input &* 18109507909533099899 &+ 3072713091740701673
        } else {
            routed = (input &+ 6844862683712643429) ^ (input / 691573740219)
        }
        let slot = Int((routed >> 5) % UInt64(table.count))
        let carried = (routed << 17) | (routed >> 47)
        return (carried ^ table[slot]) &+ (salt &* 7146906654870746303)
    }
}

private struct Fragment13fdeacb61d12713 {
    private let table: [UInt64]
    private let salt: UInt64

    init(salt: UInt64) {
        table = [10369026743709059420, 5226854862101954236, 17825720386507470486, 14909953622453139273, 4704115255516787015, 4101456878816998541, 12612866043981709112, 1536945685219921692]
        self.salt = salt ^ 13917926504759349615
    }

    @inline(never)
    func transform(_ input: UInt64) -> UInt64 {
        let routed: UInt64
        if (input & 13917926504759349615) > 3335997493183637516 {
            routed = input &* 7585894618208683487 &+ 5040452036820836155
        } else {
            routed = (input &+ 1040533314344058842) ^ (input / 3573244797)
        }
        let slot = Int((routed >> 4) % UInt64(table.count))
        let carried = (routed << 23) | (routed >> 41)
        return (carried ^ table[slot]) &+ (salt &* 5545721006244697295)
    }
}

