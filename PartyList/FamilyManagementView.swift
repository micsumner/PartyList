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
    @State private var showingAddFamily = false
    @State private var newFamilyName = ""
    @State private var selectedFamily: Family?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(families) { family in
                    Section(header: Text(family.name)) {
                        ForEach(family.members) { member in
                            HStack {
                                Text(member.name)
                                Spacer()
                                Text(member.isAdult ? "Adult" : "Child")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { offsets in
                            deleteMembers(from: family, at: offsets)
                        }
                        
                        Button(action: {
                            selectedFamily = family
                        }) {
                            Label("Add Member", systemImage: "person.badge.plus")
                        }
                    }
                }
                .onDelete(perform: deleteFamilies)
            }
            .navigationTitle("Families")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
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
                AddMemberSheet(family: family, isPresented: .constant(true))
            }
        }
    }
    
    private func deleteFamilies(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(families[index])
            }
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
    @Binding var isPresented: Bool
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
        family.members.append(member)
    }
}

#Preview {
    FamilyManagementView()
        .modelContainer(for: [Family.self, FamilyMember.self], inMemory: true)
}
