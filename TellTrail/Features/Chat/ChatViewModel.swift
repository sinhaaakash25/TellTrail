import Foundation
import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {
    @Published private(set) var threads: [ChatThread]

    init(threads: [ChatThread] = PreviewTrailData.chats) {
        self.threads = threads
    }
}
