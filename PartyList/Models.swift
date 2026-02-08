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
    var family: Family?
    
    var typeLabel: String {
        isAdult ? "Adult" : "Child"
    }
    
    init(name: String, isAdult: Bool, family: Family? = nil) {
        self.name = name
        self.isAdult = isAdult
        self.isAttending = false
        self.family = family
    }
}
