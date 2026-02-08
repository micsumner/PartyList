//
//  Models.swift
//  PartyList
//
//  Created by Michael Sumner on 2/3/26.
//

import Foundation
import SwiftData

@Model
final class Family {
    var name: String
    @Relationship(deleteRule: .cascade) var members: [FamilyMember]
    
    var sortedMembers: [FamilyMember] {
        members.sorted { $0.order < $1.order }
    }
    
    init(name: String) {
        self.name = name
        self.members = []
    }
}

@Model
final class FamilyMember {
    var name: String
    var isAdult: Bool
    var isAttending: Bool
    var order: Int
    var family: Family?
    
    var typeLabel: String {
        isAdult ? "Adult" : "Child"
    }
    
    init(name: String, isAdult: Bool, order: Int = 0, family: Family? = nil) {
        self.name = name
        self.isAdult = isAdult
        self.isAttending = false
        self.order = order
        self.family = family
    }
}
