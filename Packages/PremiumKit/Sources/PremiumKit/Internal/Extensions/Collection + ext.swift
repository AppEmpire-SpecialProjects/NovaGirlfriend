extension Collection {
    subscript(safe index: Index) -> Element? {
        return saveObject(at: index)
    }
    
    public func saveObject(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
