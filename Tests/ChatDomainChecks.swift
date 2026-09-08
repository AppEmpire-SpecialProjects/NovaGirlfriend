import Foundation
import SwiftData

// Files are not recorded in this macOS-only domain harness.
@MainActor enum RecordingController {
  static func remove(_ file: String) throws {}
}

@MainActor final class CapturingAI: AIServiceProtocol {
  var requests: [AICompletionRequest] = []
  var shouldFail = true
  var responseText = "Integration fixture response"
  var delay = false
  func complete(_ request: AICompletionRequest) async throws -> AICompletionResponse {
    requests.append(request)
    if shouldFail { throw ServiceError.notConfigured("test endpoint") }
    if delay { try await Task.sleep(for: .seconds(5)) }
    return AICompletionResponse(text: responseText)
  }
}

@main struct Checks {
  @MainActor static func main() async throws {
    let content = ProductContentRepository()
    precondition(content.characters.count == 8)
    precondition(Set(content.characters.map(\.id)).count == 8)
    precondition(Set(content.characters.map(\.name)).count == 8)
    precondition(Set(content.characters.compactMap(\.avatarAssetName)).count == 8)
    let scenarioIDs = Set(content.scenarios.map(\.id))
    for character in content.characters {
      precondition(character.origin == .builtIn)
      precondition(!character.name.isEmpty && !character.tagline.isEmpty)
      precondition(!character.biography.isEmpty)
      precondition(!character.personality.communicationStyle.isEmpty)
      precondition(character.preferredScenarioID.map(scenarioIDs.contains) == true)
    }
    let names = ["Astraea", "Zephyra", "Elowen", "Vespera", "Kaida", "Selene", "Aurelia", "Miyuki"]
    for (index, name) in names.enumerated() {
      let id = UUID(uuidString: "A1000000-0000-0000-0000-00000000000\(index + 1)")!
      precondition(content.characters.first { $0.id == id }?.name == name)
    }
    print("PASS: eight complete built-in companions, distinct avatars, valid scenarios, stable IDs")

    let container = try ModelContainer(
      for: ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: URL(fileURLWithPath: CommandLine.arguments[1])))
    let context = container.mainContext
    let character = ProductContentRepository().characters[0]
    let scenario = ProductContentRepository().scenarios[0]
    do {
      _ = try AppConfiguration().validatedAIBaseURL()
      preconditionFailure("Test bundle must be honestly unconfigured")
    } catch ServiceError.notConfigured {}
    let ai = CapturingAI()
    let model = ChatViewModel(ai: ai)
    model.open(context: context, character: character, scenario: scenario, existing: nil)
    let conversation = model.conversation!
    model.send(text: "Real harness input")
    precondition(model.isThinking)
    precondition(conversation.messages.first?.deliveryStateRawValue == "pending")
    for _ in 0..<100 where model.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(!model.isThinking)
    precondition(conversation.messages.count == 1)
    precondition(conversation.messages[0].deliveryStateRawValue == "failed")
    precondition(model.error != nil)
    precondition(ai.requests[0].character.personality == character.personality)
    precondition(ai.requests[0].scenario == scenario)
    precondition(ai.requests[0].messages.last?.text == "Real harness input")
    ai.shouldFail = false
    model.retry(conversation.messages[0])
    for _ in 0..<100 where model.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(conversation.messages.count == 2)
    precondition(conversation.orderedMessages[0].deliveryStateRawValue == "sent")
    precondition(conversation.orderedMessages[1].roleRawValue == "assistant")
    model.send(text: "", audioFileName: "fixture.m4a")
    precondition(conversation.messages.count == 3)
    precondition(conversation.orderedMessages.last?.audioFileName == "fixture.m4a")
    precondition(ai.requests.count == 2)
    let data = try JSONExportService().export(
      conversation.summary,
      messages: conversation.orderedMessages.map { $0.message(conversationID: conversation.id) })
    let exported = try JSONSerialization.jsonObject(with: data) as! [String: Any]
    precondition((exported["messages"] as! [[String: Any]]).count == 3)
    precondition(String(data: data, encoding: .utf8)!.contains("fixture.m4a"))
    let resumed = ChatViewModel(ai: ai)
    resumed.open(context: context, character: character, scenario: scenario, existing: nil)
    precondition(resumed.conversation?.id == conversation.id)
    let fresh = ChatViewModel(ai: ai)
    fresh.open(
      context: context, character: character, scenario: scenario, existing: nil, startNew: true)
    precondition(fresh.conversation?.id != conversation.id)
    ai.responseText = "   "
    fresh.send(text: "Reject empty response")
    for _ in 0..<100 where fresh.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(fresh.conversation?.messages.count == 1)
    precondition(fresh.conversation?.messages.first?.deliveryStateRawValue == "failed")
    ai.delay = true
    fresh.retry(fresh.conversation!.messages[0])
    fresh.stop()
    for _ in 0..<100 where fresh.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(!fresh.isThinking)
    precondition(fresh.conversation?.messages.count == 1)
    precondition(fresh.conversation?.messages.first?.deliveryStateRawValue == "failed")
    let emptyData = try JSONExportService().export(conversation.summary, messages: [])
    let emptyExport = try JSONSerialization.jsonObject(with: emptyData) as! [String: Any]
    precondition((emptyExport["messages"] as! [[String: Any]]).isEmpty)
    print(
      "PASS: whitespace response rejected, cancellation preserves failed message, empty export JSON"
    )
    try ConversationMaintenance(context: context).clear(conversation)
    precondition(conversation.messages.isEmpty)
    try ConversationMaintenance(context: context).delete(conversation)
    let verificationContext = ModelContext(container)
    let remaining = try verificationContext.fetch(FetchDescriptor<ConversationRecord>())
    precondition(remaining.count == 1)
    print(
      "PASS: append, pending-to-failed, retry-to-sent, single assistant append, real context/personality/scenario, audio metadata, JSON export, resume/new, clear, delete"
    )
    try await checkScenarioSelection(
      url: URL(fileURLWithPath: CommandLine.arguments[1] + "-scenarios"))
  }

  @MainActor
  private static func checkScenarioSelection(url: URL) async throws {
    let container = try ModelContainer(
      for: ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: url))
    let character = ProductContentRepository().characters[0]
    let scenarios = ProductContentRepository().scenarios
    let ai = CapturingAI()
    ai.shouldFail = false
    let model = ChatViewModel(ai: ai)
    precondition(!model.selectScenario(scenarios[0]))
    model.open(
      context: container.mainContext, character: character, scenario: nil, existing: nil,
      startNew: true)
    let conversation = model.conversation!
    let conversationID = conversation.id
    precondition(model.scenario == nil)

    for scenario in scenarios {
      let messages = conversation.orderedMessages.map(\.id)
      precondition(model.selectScenario(scenario))
      precondition(model.scenario == scenario)
      precondition(conversation.scenarioID == scenario.id)
      precondition(conversation.id == conversationID && conversation.characterID == character.id)
      precondition(conversation.orderedMessages.map(\.id) == messages)
      precondition(model.send(text: "Continue in \(scenario.title)"))
      precondition(model.isThinking)
      precondition(!model.selectScenario(nil))
      precondition(model.scenario == scenario && conversation.scenarioID == scenario.id)
      for _ in 0..<100 where model.isThinking { try await Task.sleep(for: .milliseconds(10)) }
      precondition(!model.isThinking && model.error == nil)
      precondition(ai.requests.last?.scenario == scenario)
      precondition(ai.requests.last?.messages.count == messages.count + 1)
      precondition(conversation.messages.count == messages.count + 2)
    }

    let reopenedContainer = try ModelContainer(
      for: ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: url))
    let saved = try reopenedContainer.mainContext.fetch(FetchDescriptor<ConversationRecord>())
    precondition(saved.count == 1 && saved[0].id == conversationID)
    let reopened = ChatViewModel(ai: ai)
    reopened.open(
      context: reopenedContainer.mainContext, character: character, scenario: scenarios[0],
      existing: saved[0])
    precondition(reopened.scenario == scenarios.last)
    precondition(saved[0].messages.count == scenarios.count * 2)
    precondition(reopened.send(text: "Continue the saved scenario"))
    for _ in 0..<100 where reopened.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(!reopened.isThinking && reopened.error == nil)
    precondition(ai.requests.last?.scenario == scenarios.last)

    let messageIDs = saved[0].orderedMessages.map(\.id)
    precondition(reopened.selectScenario(nil))
    precondition(reopened.scenario == nil && saved[0].scenarioID == nil)
    precondition(saved[0].orderedMessages.map(\.id) == messageIDs)
    let resetContainer = try ModelContainer(
      for: ConversationRecord.self, MessageRecord.self,
      configurations: ModelConfiguration(url: url))
    let resetRecords = try resetContainer.mainContext.fetch(FetchDescriptor<ConversationRecord>())
    precondition(resetRecords.count == 1 && resetRecords[0].id == conversationID)
    let resetModel = ChatViewModel(ai: ai)
    resetModel.open(
      context: resetContainer.mainContext, character: character, scenario: scenarios[0],
      existing: resetRecords[0])
    precondition(resetModel.scenario == nil)
    precondition(resetModel.send(text: "Continue without a scenario"))
    for _ in 0..<100 where resetModel.isThinking { try await Task.sleep(for: .milliseconds(10)) }
    precondition(!resetModel.isThinking && resetModel.error == nil)
    precondition(ai.requests.last?.scenario == nil)
    precondition(ai.requests.last?.messages.count == messageIDs.count + 1)
    print(
      "PASS: all four scenario selections reach AI requests; chat identity/history preserved; pending changes rejected; saved selection and reset survive reopening with stale launch arguments"
    )
  }
}
