import SwiftUI

/// Палитра и типографика «бумажного» экрана — общие для приложения и виджета.
enum Eink {
    static let paper = Color(red: 0.87, green: 0.87, blue: 0.85)
    static let ink = Color(red: 0.31, green: 0.32, blue: 0.33)
    static let nightPaper = Color.black
    static let nightInk = Color(white: 0.55)

    static func hours(_ date: Date) -> String {
        date.formatted(.dateTime.hour(.defaultDigits(amPM: .omitted)))
    }

    static func minutes(_ date: Date) -> String {
        date.formatted(.dateTime.minute(.twoDigits))
    }

    /// «ПТ 8» / «FRI 8» — по языку часов.
    static func day(_ date: Date) -> String {
        "\(date.formatted(.dateTime.weekday(.abbreviated))) \(date.formatted(.dateTime.day()))".uppercased()
    }
}

/// Мелкая сетка точек, как у e-ink матрицы.
struct EinkTexture: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 1.5
            var path = Path()
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    path.addRect(CGRect(x: x, y: y, width: 0.5, height: 0.5))
                    x += step
                }
                y += step
            }
            ctx.fill(path, with: .color(.black.opacity(0.07)))
        }
        .overlay(RadialGradient(colors: [.white.opacity(0.18), .black.opacity(0.08)],
                                center: .init(x: 0.5, y: 0.4), startRadius: 10, endRadius: 260))
        .allowsHitTesting(false)
    }
}
