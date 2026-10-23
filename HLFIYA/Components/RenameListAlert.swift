//
//  RenameListAlert.swift
//  HLFIYA
//

import CoreData
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

    func body(content: Content) -> some View {
        content
            .alert("Rename List", isPresented: $isPresented) {
                TextField("New List Name", text: $newName)
                    .textInputAutocapitalization(.words)
                Button("Rename", action: rename)
                Button("Cancel", role: .cancel) {}
            }
            .onChange(of: isPresented) { _, isPresented in
                if isPresented {
                    newName = list.wrappedName
                }
            }
    }

    private func rename() {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        list.name = trimmedName

        do {
            try moc.save()
        } catch {
            moc.rollback()
        }
    }
}

extension View {
    func renameListAlert(isPresented: Binding<Bool>, list: SavedList) -> some View {
        modifier(RenameListAlert(isPresented: isPresented, list: list))
    }
}
