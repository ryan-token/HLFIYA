//
//  RenameListAlert.swift
//  HLFIYA
//

import CoreData
import os
import SwiftUI

/// An alert with a text field for renaming a saved list.
///
/// The draft name lives here rather than in the presenting screen, so typing
/// doesn't re-evaluate that screen's body on every keystroke.
struct RenameListAlert: ViewModifier {
    @Binding var isPresented: Bool
    let list: SavedList

    @State private var newName = ""
    @Environment(\.managedObjectContext) private var moc

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Lists")

    func body(content: Content) -> some View {
        content
            .alert("Rename List", isPresented: $isPresented) {
                TextField("New List Name", text: $newName)
                    .textInputAutocapitalization(.words)
                Button("Rename", action: rename)
                    .disabled(trimmedName.isEmpty)
                Button("Cancel", role: .cancel) {}
            }
            // Seeded while hidden, so the field already holds the name when the alert appears.
            .onChange(of: isPresented, initial: true) { _, isPresented in
                if !isPresented {
                    newName = list.wrappedName
                }
            }
    }

    private var trimmedName: String {
        newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func rename() {
        guard !trimmedName.isEmpty else { return }
        list.name = trimmedName

        do {
            try moc.save()
        } catch {
            Self.logger.error("Failed to rename list: \(error.localizedDescription, privacy: .public)")
            moc.rollback()
        }
    }
}

extension View {
    func renameListAlert(isPresented: Binding<Bool>, list: SavedList) -> some View {
        modifier(RenameListAlert(isPresented: isPresented, list: list))
    }
}
