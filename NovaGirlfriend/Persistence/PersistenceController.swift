import SwiftData

enum PersistenceController {
    static let schema = Schema([
        CharacterRecord.self,
        ScenarioRecord.self,
        ConversationRecord.self,
        MessageRecord.self,
        GalleryItemRecord.self,
        VoiceProfileRecord.self,
        AffinityRecord.self,
        AchievementRecord.self,
        UserStreakRecord.self,
        MemoryFactRecord.self
    ])

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            "NovaGirlfriend",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
