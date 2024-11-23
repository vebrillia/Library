//
//  DatabaseHelper.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import Foundation
import SQLite3

class DatabaseHelper {
    static let shared = DatabaseHelper()
    var db: OpaquePointer?

    private init() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Library.sqlite")
        print("path: \(fileURL.path)")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            createTables()
        }
    }
    
    private func createTables() {
        let createCategoryTable = """
        CREATE TABLE IF NOT EXISTS category (
            category_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        );
        """
        let createBookTable = """
        CREATE TABLE IF NOT EXISTS book (
            book_id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT NOT NULL
        );
        """
        let createMemberTable = """
        CREATE TABLE IF NOT EXISTS member (
            member_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        );
        """
        let createBorrowingTable = """
        CREATE TABLE IF NOT EXISTS borrowing (
            borrowing_id INTEGER PRIMARY KEY AUTOINCREMENT,
            member_id INTEGER NOT NULL,
            book_id INTEGER NOT NULL,
            borrowed_date TEXT NOT NULL,
            return_date TEXT,
            FOREIGN KEY(member_id) REFERENCES member(member_id),
            FOREIGN KEY(book_id) REFERENCES book(book_id)
        );
        """
        let createBookCategoryTable = """
        CREATE TABLE IF NOT EXISTS book_category (
            bc_id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            FOREIGN KEY(book_id) REFERENCES book(book_id),
            FOREIGN KEY(category_id) REFERENCES category(category_id)
        );
        """
        executeQuery(createCategoryTable)
        executeQuery(createBookTable)
        executeQuery(createMemberTable)
        executeQuery(createBorrowingTable)
        executeQuery(createBookCategoryTable)
    }
   
    
    func executeQuery(_ query: String) {
            var stmt: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("Query executed successfully: \(query)")
                } else {
                    print("Failed to execute query: \(query)")
                    print(String(cString: sqlite3_errmsg(db)))
                }
            } else {
                print("Failed to prepare statement: \(query)")
                print(String(cString: sqlite3_errmsg(db)))
            }
            sqlite3_finalize(stmt)
        }
    
    
}
