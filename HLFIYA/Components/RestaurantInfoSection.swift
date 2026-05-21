//
//  RestaurantInfoSection.swift
//  HLFIYA
//

import SwiftUI

struct RestaurantInfoSection: View {
    let restaurant: BusinessDetails
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section("Information") {
            phoneRow
            addressRow
            hoursRow
        }
    }

    private var phoneRow: some View {
        HStack {
            Text("Phone:")
                .foregroundStyle(.gray)

            Button {
                let phone = "tel://" + (restaurant.phone ?? "555-555-5555")
                if let url = URL(string: phone) {
                    openURL(url)
                }
            } label: {
                Text(restaurant.display_phone ?? "")
                    .foregroundStyle(.fuchsia)
            }
        }
    }

    private var addressRow: some View {
        VStack(alignment: .leading) {
            Text("Address:")
                .foregroundStyle(.gray)
                .padding(.vertical, 2)

            Button {
                let latitude = restaurant.coordinates?.latitude ?? 0.0
                let longitude = restaurant.coordinates?.longitude ?? 0.0
                if let url = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)") {
                    openURL(url)
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(restaurant.location?.display_address ?? [""], id: \.self) { addressPortion in
                            HStack {
                                Text(addressPortion)
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundStyle(.tertiary)
                        .font(.callout)
                }
            }
            .foregroundStyle(.fuchsia)
            .padding(.bottom, 5)
        }
    }

    private var hoursRow: some View {
        VStack(alignment: .leading) {
            Text("Full Hours:")
                .foregroundStyle(.gray)
                .padding(.top, 5)
                .padding(.bottom, 2)

            VStack(alignment: .leading) {
                ForEach(restaurant.hours?.first?.open ?? [], id: \.self) { chunk in
                    VStack(alignment: .leading) {
                        Text(weekdayName(for: chunk.day))
                            .foregroundStyle(.secondary)

                        HStack {
                            Text(localTime(from: chunk.start ?? ""))
                            Text("–")
                            Text(localTime(from: chunk.end ?? ""))
                        }
                        .font(.headline)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(weekdayName(for: chunk.day)) hours: \(localTime(from: chunk.start ?? "")) to \(localTime(from: chunk.end ?? ""))")
                    }
                    .padding(.bottom, 5)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    private func weekdayName(for day: Int?) -> String {
        switch day {
        case 0: "Monday"
        case 1: "Tuesday"
        case 2: "Wednesday"
        case 3: "Thursday"
        case 4: "Friday"
        case 5: "Saturday"
        case 6: "Sunday"
        default: "Unknown"
        }
    }

    private func localTime(from militaryTime: String) -> String {
        guard militaryTime.count == 4,
              let hour = Int(militaryTime.prefix(2)),
              let minute = Int(militaryTime.suffix(2)),
              let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) else {
            return militaryTime
        }
        return date.formatted(date: .omitted, time: .shortened)
    }
}
