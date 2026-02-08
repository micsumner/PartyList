//
//  AttendanceView.swift
//  PartyList
//
//  Created by Michael Sumner on 2/3/26.
//

import SwiftUI
import SwiftData

struct AttendanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Family.name) private var families: [Family]
    
    // Calculate attendance counts
    private var attendingAdults: Int {
        families.flatMap { $0.members }
            .filter { $0.isAttending && $0.isAdult }
            .count
    }
    
    private var attendingChildren: Int {
        families.flatMap { $0.members }
            .filter { $0.isAttending && !$0.isAdult }
            .count
    }
    
    private var totalAttending: Int {
        attendingAdults + attendingChildren
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if families.isEmpty {
                    ContentUnavailableView(
                        "No Families Yet",
                        systemImage: "person.3.fill",
                        description: Text("Add families in the Families tab first")
                    )
                } else {
                    List {
                        ForEach(families) { family in
                            Section {
                                if family.members.isEmpty {
                                    Text("No members in this family")
                                        .foregroundStyle(.secondary)
                                        .font(.callout)
                                } else {
                                    ForEach(family.members) { member in
                                        HStack {
                                            Image(systemName: member.isAttending ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(member.isAttending ? .orange : .gray)
                                                .font(.title3)
                                            
                                            Text(member.name)
                                            
                                            Spacer()
                                            
                                            Text(member.isAdult ? "Adult" : "Child")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleAttendance(for: member)
                                        }
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(family.name)
                                    Spacer()
                                    Button(action: {
                                        toggleFamilySelection(family)
                                    }) {
                                        let allSelected = !family.members.isEmpty && family.members.allSatisfy { $0.isAttending }
                                        Text(allSelected ? "Select None" : "Select All")
                                            .font(.caption)
                                            .textCase(.none)
                                    }
                                    .disabled(family.members.isEmpty)
                                }
                            }
                        }
                    }
                    
                    // Attendance summary at the bottom
                    VStack(spacing: 8) {
                        Divider()
                        
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(attendingAdults)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Adults")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack {
                                Text("\(attendingChildren)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Children")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack {
                                Text("\(totalAttending)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("Attendance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetAttendance()
                    }
                    .disabled(totalAttending == 0)
                }
            }
        }
    }
    
    private func toggleAttendance(for member: FamilyMember) {
        member.isAttending.toggle()
    }
    
    private func resetAttendance() {
        for family in families {
            for member in family.members {
                member.isAttending = false
            }
        }
    }
    
    private func toggleFamilySelection(_ family: Family) {
        let allSelected = family.members.allSatisfy { $0.isAttending }
        for member in family.members {
            member.isAttending = !allSelected
        }
    }
}

#Preview {
    AttendanceView()
        .modelContainer(for: [Family.self, FamilyMember.self], inMemory: true)
}
