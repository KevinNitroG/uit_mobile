import WidgetKit
import SwiftUI

// MARK: - Shared Data Models

struct CourseEntry: Codable {
    let classCode: String
    let room: String
    let periods: String
}

struct DeadlineEntry: Codable {
    let name: String
    let shortname: String
    let niceDate: String
}

// MARK: - Data Loader

struct WidgetDataLoader {
    static let groupId = "group.com.kevinnitro.uitMobile"

    static func loadCourses() -> [CourseEntry] {
        guard let prefs = UserDefaults(suiteName: groupId),
              let json = prefs.string(forKey: "today_courses"),
              let data = json.data(using: .utf8)
        else { return [] }
        return (try? JSONDecoder().decode([CourseEntry].self, from: data)) ?? []
    }

    static func loadDeadlines() -> [DeadlineEntry] {
        guard let prefs = UserDefaults(suiteName: groupId),
              let json = prefs.string(forKey: "upcoming_deadlines"),
              let data = json.data(using: .utf8)
        else { return [] }
        return (try? JSONDecoder().decode([DeadlineEntry].self, from: data)) ?? []
    }

    static func lastUpdated() -> String {
        guard let prefs = UserDefaults(suiteName: groupId),
              let iso = prefs.string(forKey: "last_updated")
        else { return "" }
        // Extract just HH:mm from ISO string
        if let tIndex = iso.firstIndex(of: "T") {
            let timeStart = iso.index(after: tIndex)
            let time = String(iso[timeStart...].prefix(5))
            return "Updated \(time)"
        }
        return ""
    }
}

// MARK: - Timetable Widget

struct TimetableTimelineEntry: TimelineEntry {
    let date: Date
    let courses: [CourseEntry]
    let updatedAt: String
}

struct TimetableProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimetableTimelineEntry {
        TimetableTimelineEntry(
            date: Date(),
            courses: [CourseEntry(classCode: "CS101", room: "A301", periods: "1-3")],
            updatedAt: ""
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimetableTimelineEntry) -> Void) {
        let entry = TimetableTimelineEntry(
            date: Date(),
            courses: WidgetDataLoader.loadCourses(),
            updatedAt: WidgetDataLoader.lastUpdated()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TimetableTimelineEntry>) -> Void) {
        let entry = TimetableTimelineEntry(
            date: Date(),
            courses: WidgetDataLoader.loadCourses(),
            updatedAt: WidgetDataLoader.lastUpdated()
        )
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TimetableWidgetView: View {
    let entry: TimetableTimelineEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today's Classes")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.accentColor)

            if entry.courses.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No classes today")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(entry.courses.prefix(5).enumerated()), id: \.offset) { _, course in
                    HStack(spacing: 6) {
                        Text("P\(course.periods)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.8))
                            .cornerRadius(4)

                        Text(course.classCode)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)

                        Spacer()

                        Text(course.room)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }

            if !entry.updatedAt.isEmpty {
                HStack {
                    Spacer()
                    Text(entry.updatedAt)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
    }
}

struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimetableProvider()) { entry in
            TimetableWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Classes")
        .description("Shows today's class schedule from UIT.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Deadlines Widget

struct DeadlinesTimelineEntry: TimelineEntry {
    let date: Date
    let deadlines: [DeadlineEntry]
    let updatedAt: String
}

struct DeadlinesProvider: TimelineProvider {
    func placeholder(in context: Context) -> DeadlinesTimelineEntry {
        DeadlinesTimelineEntry(
            date: Date(),
            deadlines: [DeadlineEntry(name: "Assignment 1", shortname: "CS101", niceDate: "Tomorrow")],
            updatedAt: ""
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DeadlinesTimelineEntry) -> Void) {
        let entry = DeadlinesTimelineEntry(
            date: Date(),
            deadlines: WidgetDataLoader.loadDeadlines(),
            updatedAt: WidgetDataLoader.lastUpdated()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeadlinesTimelineEntry>) -> Void) {
        let entry = DeadlinesTimelineEntry(
            date: Date(),
            deadlines: WidgetDataLoader.loadDeadlines(),
            updatedAt: WidgetDataLoader.lastUpdated()
        )
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct DeadlinesWidgetView: View {
    let entry: DeadlinesTimelineEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Upcoming Deadlines")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)

            if entry.deadlines.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No upcoming deadlines")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(entry.deadlines.prefix(3).enumerated()), id: \.offset) { _, deadline in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(deadline.name)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                        HStack {
                            Text(deadline.shortname)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(deadline.niceDate)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 2)
                }
                Spacer(minLength: 0)
            }

            if !entry.updatedAt.isEmpty {
                HStack {
                    Spacer()
                    Text(entry.updatedAt)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
    }
}

struct DeadlinesWidget: Widget {
    let kind: String = "DeadlinesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DeadlinesProvider()) { entry in
            DeadlinesWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Upcoming Deadlines")
        .description("Shows upcoming assignment deadlines from UIT.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct UitWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TimetableWidget()
        DeadlinesWidget()
    }
}
