//
//  ContentView.swift
//  PartyList
//
//  Created by Michael Sumner on 2/3/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            AttendanceView()
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle.fill")
                }
            
            FamilyManagementView()
                .tabItem {
                    Label("Families", systemImage: "person.3.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Family.self, FamilyMember.self], inMemory: true)
}
