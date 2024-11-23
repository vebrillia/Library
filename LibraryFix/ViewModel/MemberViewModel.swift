//
//  MemberViewModel.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import Foundation
import SQLite3

class MemberViewModel: ObservableObject {
    @Published var members: [Member] = []
    private let db = DatabaseHelper.shared

    // Fetch all members
    func fetchMembers() {
        members.removeAll()
        let query = "SELECT * FROM member"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                members.append(Member(id: id, name: name))
            }
        }
        sqlite3_finalize(stmt)
    }

    // Add a new member
    func addMember(name: String) {
        guard !name.isEmpty else { return }
        let query = "INSERT INTO member (name) VALUES ('\(name)')"
        db.executeQuery(query)
        fetchMembers()
    }

    // Update a member
    func updateMember(id: Int, name: String) {
        guard !name.isEmpty else { return }
        let query = "UPDATE member SET name = '\(name)' WHERE member_id = \(id)"
        db.executeQuery(query)
        fetchMembers()
    }

    // Delete a member
    func deleteMember(id: Int) {
        let query = "DELETE FROM member WHERE member_id = \(id)"
        db.executeQuery(query)
        fetchMembers()
    }
}
