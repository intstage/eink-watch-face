import WidgetKit
import SwiftUI

/// Расширение для циферблата: тот же «12 45 | ПТ 8» в слотах штатных циферблатов.
struct Entry: TimelineEntry {
    let date: Date
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Записи на каждую минуту вперёд на 3 часа — система просто листает их.
        let start = Calendar.current.dateInterval(of: .minute, for: .now)!.start
        let entries = (0..<180).map { Entry(date: start.addingTimeInterval(Double($0) * 60)) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct EinkWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let date: Date

    var body: some View {
        switch family {
        case .accessoryRectangular:
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(Eink.hours(date))
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .kerning(-2)
                VStack(alignment: .leading, spacing: 0) {
                    Text(Eink.minutes(date))
                        .font(.system(size: 26, weight: .ultraLight))
                    Text(Eink.day(date))
                        .font(.system(size: 13, weight: .semibold))
                }
                Spacer(minLength: 0)
            }
            .monospacedDigit()
        case .accessoryInline:
            Text(Eink.day(date))
        case .accessoryCorner:
            Text(Eink.minutes(date))
                .font(.system(size: 22, weight: .ultraLight))
                .widgetLabel(Eink.day(date))
        default:
            VStack(spacing: -4) {
                Text(Eink.hours(date))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                Text(Eink.minutes(date))
                    .font(.system(size: 14, weight: .light))
            }
            .monospacedDigit()
        }
    }
}

@main
struct EinkWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "EinkWidget", provider: Provider()) { entry in
            EinkWidgetView(date: entry.date)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("E-ink время")
        .description("Крупный час и тонкие минуты")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryCorner, .accessoryInline])
    }
}
