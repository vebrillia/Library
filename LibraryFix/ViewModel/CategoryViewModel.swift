//
//  CategoryViewModel.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import Foundation
import SQLite3

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    private let db = DatabaseHelper.shared

    func fetchCategories() {
        categories.removeAll()
        let query = "SELECT * FROM category"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                categories.append(Category(id: id, name: name))
            }
        }
        sqlite3_finalize(stmt)
    }

    func addCategory(name: String) {
        guard !name.isEmpty else { return }
        let query = "INSERT INTO category (name) VALUES ('\(name)')"
        db.executeQuery(query)
        fetchCategories()
    }

    func updateCategory(id: Int, name: String) {
        guard !name.isEmpty else { return }
        let query = "UPDATE category SET name = '\(name)' WHERE category_id = \(id)"
        db.executeQuery(query)
        fetchCategories()
    }

    func deleteCategory(id: Int) {
        let query = "DELETE FROM category WHERE category_id = \(id)"
        db.executeQuery(query)
        fetchCategories()
    }
}
