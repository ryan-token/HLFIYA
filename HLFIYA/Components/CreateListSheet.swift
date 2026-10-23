//
//  CreateListSheet.swift
//  HLFIYA
//
//  Created by Ryan Token on 6/12/22.
//

import CoreData
import os
import SwiftUI

/// A sheet for naming and creating a new saved list.
struct CreateListSheet: View {
    @FocusState private var isNameFocused: Bool
    @State private var listName = ""

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Lists")

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        NavigationStack {
            Form {
                TextField("List Name", text: $listName)
                    .focused($isNameFocused)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit(save)
            }
            .navigationTitle("Create New List")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
        .tint(.fuchsia)
        .task {
            // Wait for the sheet to finish presenting so the keyboard appears with it.
            try? await Task.sleep(for: .milliseconds(750))
            isNameFocused = true
        }
    }

    private var trimmedName: String {
        listName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        guard !trimmedName.isEmpty else { return }

        let newList = SavedList(context: moc)
        newList.name = trimmedName
        do {
            try moc.save()
        } catch {
            Self.logger.error("Failed to create list: \(error.localizedDescription, privacy: .public)")
            moc.rollback()
        }
        dismiss()
    }
}

#Preview {
    CreateListSheet()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
