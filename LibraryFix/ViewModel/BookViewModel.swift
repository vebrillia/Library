//
//  BookViewModel.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import Foundation
import SQLite3

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var categories: [Category] = []
    @Published var selectedCategories: [Int] = []
    @Published var borrowerName: String = ""

    private let db = DatabaseHelper.shared

    // Fetch books from database
    func fetchBooks() {
        books.removeAll()
        let query = "SELECT * FROM book"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let author = String(cString: sqlite3_column_text(stmt, 2))
                books.append(Book(id: id, title: title, author: author))
            }
        }
        sqlite3_finalize(stmt)
    }

    // Fetch categories from database
    func fetchCategories(completion: @escaping () -> Void) {
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
        
        // Panggil callback setelah kategori selesai dimuat
        completion()
    }

    // Add a new book with selected categories
    func addBook(title: String, author: String) {
        guard !title.isEmpty, !author.isEmpty, !selectedCategories.isEmpty else { return }
        let insertBookQuery = "INSERT INTO book (title, author) VALUES ('\(title)', '\(author)')"

        db.executeQuery(insertBookQuery)

        // Get the last inserted book ID
        let lastBookIdQuery = "SELECT last_insert_rowid()"
        var stmt: OpaquePointer?
        var lastBookId: Int = 0

        if sqlite3_prepare_v2(db.db, lastBookIdQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                lastBookId = Int(sqlite3_column_int(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)

        // Insert into book_category
        for categoryId in selectedCategories {
            let insertCategoryQuery = "INSERT INTO book_category (book_id, category_id) VALUES (\(lastBookId), \(categoryId))"
            db.executeQuery(insertCategoryQuery)
        }

        fetchBooks()
    }

    // Update book information
    func updateBook(id: Int, title: String, author: String, categories: [Int]) {
        let updateBookQuery = "UPDATE book SET title = '\(title)', author = '\(author)' WHERE book_id = \(id)"
        db.executeQuery(updateBookQuery)

        // Delete existing categories and reinsert selected categories
        let deleteCategoriesQuery = "DELETE FROM book_category WHERE book_id = \(id)"
        db.executeQuery(deleteCategoriesQuery)

        for categoryId in categories {
            let insertCategoryQuery = "INSERT INTO book_category (book_id, category_id) VALUES (\(id), \(categoryId))"
            db.executeQuery(insertCategoryQuery)
        }

        fetchBooks()
    }

    // Delete a book
    func deleteBook(id: Int) {
        let deleteBookQuery = "DELETE FROM book WHERE book_id = \(id)"
        let deleteBookCategoryQuery = "DELETE FROM book_category WHERE book_id = \(id)"
        db.executeQuery(deleteBookQuery)
        db.executeQuery(deleteBookCategoryQuery)
        fetchBooks()
    }

    // Fetch categories selected for a specific book
    func selectedCategories(for bookId: Int) -> [Int] {
        var selectedCategoryIds: [Int] = []
        let query = "SELECT category_id FROM book_category WHERE book_id = \(bookId)"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let categoryId = Int(sqlite3_column_int(stmt, 0))
                selectedCategoryIds.append(categoryId)
            }
        }
        sqlite3_finalize(stmt)

        return selectedCategoryIds
    }
    
    // Modify fetchBooksByCategory method
    func fetchBooksByCategory(categoryId: Int?) {
        books.removeAll()
        
        // Query based on selected category or show all books if categoryId is nil
        let query: String
        if let categoryId = categoryId {
            query = """
            SELECT * FROM book
            WHERE book_id IN (SELECT book_id FROM book_category WHERE category_id = \(categoryId))
            """
        } else {
            query = "SELECT * FROM book" // Show all books if no category is selected
        }

        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let author = String(cString: sqlite3_column_text(stmt, 2))
                books.append(Book(id: id, title: title, author: author))
            }
        }
        sqlite3_finalize(stmt)
    }

    
    func fetchBooksByBorrower() {
            books.removeAll()
            let query = """
            SELECT b.* FROM book b
            JOIN borrowing br ON br.book_id = b.book_id
            JOIN member m ON m.member_id = br.member_id
            WHERE m.name LIKE '%\(borrowerName)%'
            """
            var stmt: OpaquePointer?

            if sqlite3_prepare_v2(db.db, query, -1, &stmt, nil) == SQLITE_OK {
                while sqlite3_step(stmt) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(stmt, 0))
                    let title = String(cString: sqlite3_column_text(stmt, 1))
                    let author = String(cString: sqlite3_column_text(stmt, 2))
                    books.append(Book(id: id, title: title, author: author))
                }
            }
            sqlite3_finalize(stmt)
        }
    
    func fetchFilteredBooks(selectedCategoryId: Int?) {
        // First, clear the current book list
        books.removeAll()
        
        if !borrowerName.isEmpty {
            fetchBooksByBorrower()
        } else if let selectedCategoryId = selectedCategoryId {
            fetchBooksByCategory(categoryId: selectedCategoryId)
        } else {
            fetchBooks()  // No filters, fetch all books
        }
    
    }
    
}
