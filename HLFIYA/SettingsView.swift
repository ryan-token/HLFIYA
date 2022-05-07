//
//  SettingsView.swift
//  HLFIYA
//
//  Created by Ryan Token on 5/6/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Stats")) {
                    NavigationLink(destination: SwipesStatsView()) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right.square.fill")
                                .font(.title)
                                .foregroundColor(.purple)
                            Text("Swipes")
                        }
                    }
                }
                
                Section(header: Text("Support")) {
                    
                }
                
                Section(header: Text("General")) {
                    
                }
            }
            
            .navigationTitle("Settings")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
