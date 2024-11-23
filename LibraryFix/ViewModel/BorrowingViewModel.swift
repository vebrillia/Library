//
//  BorrowingViewModel.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SQLite3
import Foundation

class BorrowingViewModel: ObservableObject {
    @Published var borrowings: [Borrowing] = []
    @Published var members: [Member] = []
    @Published var books: [Book] = []

    private let db = DatabaseHelper.shared

    // Fungsi untuk menambahkan borrowing
    func addBorrowing(memberId: Int, bookId: Int, borrowedDate: String) {
        let query = """
        INSERT INTO borrowing (member_id, book_id, borrowed_date)
        VALUES (\(memberId), \(bookId), '\(borrowedDate)');
        """
        db.executeQuery(query)
        fetchBorrowings()
    }

    // Fungsi untuk menghapus borrowing
    func deleteBorrowing(id: Int) {
        let query = "DELETE FROM borrowing WHERE borrowing_id = \(id);"
        db.executeQuery(query)
        fetchBorrowings()
    }

    // Fetch borrowings
    func fetchBorrowings() {
        borrowings.removeAll()
        let query = """
        SELECT borrowing.borrowing_id, borrowing.member_id, borrowing.book_id, borrowing.borrowed_date,
               borrowing.return_date, member.name, book.title
        FROM borrowing
        INNER JOIN member ON borrowing.member_id = member.member_id
        INNER JOIN book ON borrowing.book_id = book.book_id;
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let memberId = Int(sqlite3_column_int(stmt, 1))
                let bookId = Int(sqlite3_column_int(stmt, 2))
                let borrowedDate = String(cString: sqlite3_column_text(stmt, 3))
                let returnDate = sqlite3_column_text(stmt, 4) != nil ? String(cString: sqlite3_column_text(stmt, 4)) : nil
                let memberName = String(cString: sqlite3_column_text(stmt, 5))
                let bookTitle = String(cString: sqlite3_column_text(stmt, 6))

                borrowings.append(Borrowing(id: id, memberId: memberId, bookId: bookId, borrowedDate: borrowedDate, returnDate: returnDate, memberName: memberName, bookTitle: bookTitle))
            }
        } else {
            print("Failed to fetch borrowings: \(query)")
            print(String(cString: sqlite3_errmsg(db.db)))
        }
        sqlite3_finalize(stmt)
    }

    // Fetch members and books
    func fetchMembersAndBooks() {
        // Fetch members
        var memberStmt: OpaquePointer?
        let memberQuery = "SELECT * FROM member;"
        members.removeAll()

        if sqlite3_prepare_v2(db.db, memberQuery, -1, &memberStmt, nil) == SQLITE_OK {
            while sqlite3_step(memberStmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(memberStmt, 0))
                let name = String(cString: sqlite3_column_text(memberStmt, 1))
                members.append(Member(id: id, name: name))
            }
        }
        sqlite3_finalize(memberStmt)

        // Fetch books
        var bookStmt: OpaquePointer?
        let bookQuery = "SELECT * FROM book;"
        books.removeAll()

        if sqlite3_prepare_v2(db.db, bookQuery, -1, &bookStmt, nil) == SQLITE_OK {
            while sqlite3_step(bookStmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(bookStmt, 0))
                let title = String(cString: sqlite3_column_text(bookStmt, 1))
                books.append(Book(id: id, title: title, author: ""))
            }
        }
        sqlite3_finalize(bookStmt)
    }
    
    // Fetch borrowings for a specific member
    func fetchBorrowings(forMemberId memberId: Int) {
        borrowings.removeAll()
        let query = """
        SELECT borrowing.borrowing_id, borrowing.member_id, borrowing.book_id, borrowing.borrowed_date,
               borrowing.return_date, member.name, book.title
        FROM borrowing
        INNER JOIN member ON borrowing.member_id = member.member_id
        INNER JOIN book ON borrowing.book_id = book.book_id
        WHERE member.member_id = \(memberId);
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let memberId = Int(sqlite3_column_int(stmt, 1))
                let bookId = Int(sqlite3_column_int(stmt, 2))
                let borrowedDate = String(cString: sqlite3_column_text(stmt, 3))
                let returnDate = sqlite3_column_text(stmt, 4) != nil ? String(cString: sqlite3_column_text(stmt, 4)) : nil
                let memberName = String(cString: sqlite3_column_text(stmt, 5))
                let bookTitle = String(cString: sqlite3_column_text(stmt, 6))

                borrowings.append(Borrowing(id: id, memberId: memberId, bookId: bookId, borrowedDate: borrowedDate, returnDate: returnDate, memberName: memberName, bookTitle: bookTitle))
            }
        } else {
            print("Failed to fetch borrowings for member: \(query)")
            print(String(cString: sqlite3_errmsg(db.db)))
        }
        sqlite3_finalize(stmt)
    }
    
    func updateReturnDate(forBorrowingId borrowingId: Int, returnDate: String) {
        if let index = borrowings.firstIndex(where: { $0.id == borrowingId }) {
            borrowings[index].returnDate = returnDate

            // Update the database
            let query = """
            UPDATE borrowing
            SET return_date = '\(returnDate)'
            WHERE borrowing_id = \(borrowingId);
            """
            db.executeQuery(query)
        }

        // Refresh the list of borrowings
        fetchBorrowings()
    }


    func updateBorrowing(id: Int, memberId: Int, bookId: Int, borrowedDate: String) {
        // Update in the local borrowings array
        if let index = borrowings.firstIndex(where: { $0.id == id }) {
            borrowings[index].memberId = memberId
            borrowings[index].bookId = bookId
            borrowings[index].borrowedDate = borrowedDate

            // Optionally, update the member and book names to reflect changes
            if let member = members.first(where: { $0.id == memberId }) {
                borrowings[index].memberName = member.name
            }
            if let book = books.first(where: { $0.id == bookId }) {
                borrowings[index].bookTitle = book.title
            }
        }
        
        // Update in the database
        let query = """
        UPDATE borrowing
        SET member_id = \(memberId), book_id = \(bookId), borrowed_date = '\(borrowedDate)'
        WHERE borrowing_id = \(id);
        """
        db.executeQuery(query)
        fetchBorrowings()  // Refresh the list of borrowings
    }

    
    var borrowedBooks: Set<Int> {
            Set(borrowings.filter { $0.returnDate == nil }.map { $0.bookId })
        }
}
