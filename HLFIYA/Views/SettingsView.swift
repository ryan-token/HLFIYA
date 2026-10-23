//
//  SettingsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI

/// App settings, support links, purchases, and data management.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreManager.self) private var storeManager

    @State private var isShowingAboutScreen = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                SettingsSupportSection(errorMessage: $errorMessage)
                SettingsGeneralSection(isShowingAboutScreen: $isShowingAboutScreen)
                SettingsDataSection()

                if storeManager.hasRemovedAds {
                    Text("You paid to remove ads. Thank you!")
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .locationPermissions:
                    LocationRequestView()
                case .swipeStats:
                    SwipesStatsView()
                case .deleteData:
                    DeleteDataView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingAboutScreen) {
                AboutView()
            }
            .alert("Something Went Wrong", item: $errorMessage) { _ in
            } message: { message in
                Text(message)
            }
            .sensoryFeedback(.error, trigger: errorMessage != nil) { _, isShowingError in
                isShowingError
            }
        }
        .tint(.fuchsia)
    }
}

#Preview {
    SettingsView()
        .environment(StoreManager())
        .environment(LocationViewModel())
}
