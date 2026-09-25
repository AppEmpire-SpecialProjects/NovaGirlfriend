import Foundation

extension Array where Element == PremiumProduct {

    /// Пара продуктов, между которыми переключаются тоггл и пикер пейвола.
    ///
    /// Если среди продуктов есть и триальный, и безтриальный — классическая пара
    /// «триал / не триал»: безтриальный слева («выкл»), триальный справа («вкл»).
    /// Если из Apphud пришли продукты одного типа (два триала или два безтриала),
    /// первый продукт занимает левый сегмент («выкл») и выбран по умолчанию,
    /// второй — правый сегмент («вкл»).
    var togglePair: (on: PremiumProduct, off: PremiumProduct)? {
        guard count >= 2 else { return nil }
        if let trial = first(where: { $0.hasTrial }),
           let regular = first(where: { !$0.hasTrial }) {
            return (on: trial, off: regular)
        }
        return (on: self[1], off: self[0])
    }
}
