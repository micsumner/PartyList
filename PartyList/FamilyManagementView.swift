//
//  FamilyManagementView.swift
//  PartyList
//
//  Created by Michael Sumner on 2/3/26.
//

import SwiftUI
import SwiftData

struct FamilyManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Family.name) private var families: [Family]
    @State private var isEditing = false
    @State private var showingAddFamily = false
    @State private var selectedFamily: Family?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(families) { family in
                    Section(header: Text(family.name)) {
                        if isEditing {
                            Button(role: .destructive, action: {
                                deleteFamily(family)
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete \(family.name)")
                                }
                            }
                        }
                        
                        ForEach(family.members) { member in
                            HStack {
                                Text(member.name)
                                Spacer()
                                Text(member.typeLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            deleteMembers(from: family, at: offsets)
                        }
                        .onMove { offsets, destination in
                            moveMembers(in: family, from: offsets, to: destination)
                        }
                        
                        Button(action: {
                            selectedFamily = family
                        }) {
                            Label("Add Member", systemImage: "person.badge.plus")
                        }
                    }
                }
            }
            .navigationTitle("Families")
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFamily = true
                    }) {
                        Label("Add Family", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFamily) {
                AddFamilySheet(isPresented: $showingAddFamily)
            }
            .sheet(item: $selectedFamily) { family in
                AddMemberSheet(family: family)
            }
        }
    }
    
    private func deleteFamily(_ family: Family) {
        withAnimation {
            modelContext.delete(family)
        }
    }
    
    private func deleteMembers(from family: Family, at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let member = family.members[index]
                modelContext.delete(member)
            }
        }
    }
    
    private func moveMembers(in family: Family, from offsets: IndexSet, to destination: Int) {
        withAnimation {
            family.members.move(fromOffsets: offsets, toOffset: destination)
        }
    }
}

struct AddFamilySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var familyName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Family Name", text: $familyName)
            }
            .navigationTitle("Add Family")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addFamily()
                        isPresented = false
                    }
                    .disabled(familyName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addFamily() {
        let family = Family(name: familyName)
        modelContext.insert(family)
    }
}

struct AddMemberSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let family: Family
    @State private var memberName = ""
    @State private var isAdult = true
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Member Name", text: $memberName)
                
                Picker("Type", selection: $isAdult) {
                    Text("Adult").tag(true)
                    Text("Child").tag(false)
                }
                .pickerStyle(.segmented)
            }
            .navigationTitle("Add Member to \(family.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                        dismiss()
                    }
                    .disabled(memberName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func addMember() {
        let member = FamilyMember(name: memberName, isAdult: isAdult, family: family)
        modelContext.insert(member)
    }
}

#Preview {
    FamilyManagementView()
        .modelContainer(for: [Family.self, FamilyMember.self], inMemory: true)
}
