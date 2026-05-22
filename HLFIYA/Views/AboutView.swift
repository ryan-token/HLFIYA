//
//  AboutView.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/12/22.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            VStack(spacing: 7) {
                Image("HLF-1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(radius: 10)
                    .padding(.bottom, 7)

                Text("Hot Local Food")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 7)

                Text("Made with 💜 by an independent developer")
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("Made with love by an independent developer")

                Form {
                    Section {
                        Text("Hot Local Food was built by two friends who just needed a better way to find some good food nearby.")

                        Text("Thank you for using the app. Please leave a review if you find it valuable.")

                        Button(action: requestReviewManually) {
                            Label("Rate on the App Store", systemImage: "heart.square.fill")
                                .font(.headline)
                                .foregroundStyle(.fuchsia)
                        }
                    }
                    .padding(5)

                    Section("Try my other apps") {
						OtherAppRow(
							image: "CatchUp-1024",
							title: "CatchUp: Keep in Touch",
							subtitle: "Personal relationship manager",
							url: URL(string: "itms-apps://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550"),
							accessibility: "Try out this developer's other app, CatchUp: Keep in Touch"
						)

                        OtherAppRow(
                            image: "Outrank-1024",
                            title: "Outrank: CFB Stat Rankings",
                            subtitle: "College football team stats",
                            url: URL(string: "itms-apps://apps.apple.com/us/app/outrank/id1588983785"),
                            accessibility: "Try out this developer's other app, Outrank: CFB Stat Rankings"
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                        .font(.headline)
                }
            }
        }
        .tint(.fuchsia)
    }

    private func requestReviewManually() {
        guard let url = URL(string: "https://apps.apple.com/us/app/hot-local-food/id1621818779?action=write-review") else { return }
        openURL(url)
    }
}

private struct OtherAppRow: View {
	@Environment(\.openURL) private var openURL

	let image: String
	let title: String
	let subtitle: String
	let url: URL?
	let accessibility: String

	var body: some View {
		Button {
			if let url { openURL(url) }
		} label: {
			HStack {
				Image(image)
					.resizable()
					.scaledToFit()
					.frame(width: 60, height: 60)
					.clipShape(.rect(cornerRadius: 11))

				Spacer()
					.frame(width: 15)

				VStack(alignment: .leading, spacing: 3) {
					Text(title)
						.font(.headline)
						.foregroundStyle(.primary)

					Text(subtitle)
						.multilineTextAlignment(.leading)
						.foregroundStyle(.gray)
				}
			}
		}
		.buttonStyle(.plain)
		.accessibilityLabel(accessibility)
	}
}

#Preview {
    AboutView()
}
