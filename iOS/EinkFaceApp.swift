import SwiftUI

/// iPhone-часть нужна только как контейнер, чтобы поставить приложение на часы.
@main
struct EinkFaceApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Image(systemName: "applewatch").font(.largeTitle)
                Text("E-ink живёт на часах").font(.headline)
                Text("Открой E-ink на Apple Watch. Чтобы он не уходил с экрана: Watch → Основные → Возврат к циферблату → E-ink → «Вернуться к приложению».")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(32)
        }
    }
}
