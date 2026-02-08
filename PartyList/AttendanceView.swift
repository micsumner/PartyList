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
    
    // Layout constants
    private let summarySpacing: CGFloat = 30
    private let summaryVerticalPadding: CGFloat = 8
    
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
                                    ForEach(family.sortedMembers) { member in
                                        HStack {
                                            Image(systemName: member.isAttending ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(member.isAttending ? .orange : .gray)
                                                .font(.title3)
                                                .accessibilityLabel(member.isAttending ? "Attending" : "Not attending")
                                            
                                            Text(member.name)
                                            
                                            Spacer()
                                            
                                            Text(member.typeLabel)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleAttendance(for: member)
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("\(member.name), \(member.typeLabel)")
                                        .accessibilityValue(member.isAttending ? "Attending" : "Not attending")
                                        .accessibilityHint("Double tap to toggle attendance")
                                    }
                                }
                            } header: {
                                HStack {
                                    Text(family.name)
                                    Spacer()
                                    Button(action: {
                                        toggleFamilySelection(family)
                                    }) {
                                        Text(isFamilyFullySelected(family) ? "Select None" : "Select All")
                                            .font(.caption)
                                            .textCase(.none)
                                    }
                                    .disabled(family.members.isEmpty)
                                    .accessibilityLabel(isFamilyFullySelected(family) ? "Deselect all members of \(family.name)" : "Select all members of \(family.name)")
                                }
                            }
                        }
                    }
                    
                    // Attendance summary at the bottom
                    AttendanceSummaryView(
                        adults: attendingAdults,
                        children: attendingChildren,
                        total: totalAttending,
                        spacing: summarySpacing,
                        verticalPadding: summaryVerticalPadding
                    )
                }
            }
            .navigationTitle("Attendance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetAttendance()
                    }
                    .disabled(totalAttending == 0)
                    .accessibilityLabel("Reset all attendance")
                    .accessibilityHint("Clears attendance for all family members")
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
        let allSelected = isFamilyFullySelected(family)
        for member in family.members {
            member.isAttending = !allSelected
        }
    }
    
    private func isFamilyFullySelected(_ family: Family) -> Bool {
        !family.members.isEmpty && family.members.allSatisfy { $0.isAttending }
    }
}

struct AttendanceSummaryView: View {
    let adults: Int
    let children: Int
    let total: Int
    let spacing: CGFloat
    let verticalPadding: CGFloat
    
    var body: some View {
        VStack(spacing: verticalPadding) {
            Divider()
            
            HStack(spacing: spacing) {
                CountBadge(count: adults, label: "Adults")
                CountBadge(count: children, label: "Children")
                CountBadge(count: total, label: "Total")
            }
            .padding(.vertical, verticalPadding)
        }
        .background(.regularMaterial)
    }
}

struct CountBadge: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AttendanceView()
        .modelContainer(for: [Family.self, FamilyMember.self], inMemory: true)
}
