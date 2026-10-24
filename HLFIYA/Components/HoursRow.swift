//
//  HoursRow.swift
//  HLFIYA
//

import SwiftUI

/// The restaurant's opening hours for each day of the week.
struct HoursRow: View {
    let openHours: [BusinessDetails.Hour]

    @Environment(\.calendar) private var calendar

    var body: some View {
        VStack(alignment: .leading) {
            Text("Full Hours")
                .foregroundStyle(.secondary)

            ForEach(openHours, id: \.self) { hour in
                let weekday = weekdayName(forYelpDay: hour.day)
                let opens = localTime(from: hour.start)
                let closes = localTime(from: hour.end)

                LabeledContent(weekday, value: "\(opens) – \(closes)")
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(weekday) hours: \(opens) to \(closes)")
            }
        }
    }

    /// Yelp numbers days from 0 for Monday; `weekdaySymbols` starts on Sunday.
    private func weekdayName(forYelpDay day: Int?) -> String {
        guard let day, (0..<7).contains(day) else { return String(localized: "Unknown") }
        return calendar.weekdaySymbols[(day + 1) % 7]
    }

    /// Converts Yelp's 24-hour "HHmm" times into the person's preferred time format.
    private func localTime(from time: String?) -> String {
        guard let time, time.count == 4,
              let hour = Int(time.prefix(2)),
              let minute = Int(time.suffix(2)),
              let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now) else {
            return time ?? ""
        }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    List {
        HoursRow(openHours: BusinessDetails.data.hours?.first?.open ?? [])
    }
}
