import SwiftUI

/// Полноэкранный «циферблат»: большой час, тонкие минуты, погода | день.
struct FaceView: View {
    @Environment(\.isLuminanceReduced) private var dimmed
    @StateObject private var weather = Weather()

    var body: some View {
        TimelineView(.everyMinute) { context in
            GeometryReader { geo in
                let w = geo.size.width
                let ink = dimmed ? Eink.nightInk : Eink.ink
                ZStack {
                    (dimmed ? Eink.nightPaper : Eink.paper)
                    if !dimmed { EinkTexture() }

                    VStack(spacing: w * 0.06) {
                        HStack(alignment: .lastTextBaseline, spacing: w * 0.02) {
                            Text(Eink.hours(context.date))
                                .font(.system(size: w * 0.56, weight: .bold, design: .rounded))
                                .kerning(-w * 0.02)
                            Text(Eink.minutes(context.date))
                                .font(.system(size: w * 0.24, weight: .thin))
                                .offset(y: w * 0.02)
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                        HStack(spacing: w * 0.05) {
                            if let symbol = weather.symbol {
                                Image(systemName: symbol)
                                    .font(.system(size: w * 0.11, weight: .light))
                                Rectangle()
                                    .frame(width: 1.2, height: w * 0.13)
                                    .rotationEffect(.degrees(15))
                            }
                            Text(Eink.day(context.date))
                                .font(.system(size: w * 0.11, weight: .semibold))
                        }
                    }
                    .foregroundStyle(ink)
                    .monospacedDigit()
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { weather.refresh() }
    }
}

#Preview { FaceView() }
