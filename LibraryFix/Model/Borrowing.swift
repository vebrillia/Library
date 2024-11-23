//
//  Borrowing.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import Foundation

struct Borrowing: Identifiable {
    var id: Int
    var memberId: Int
    var bookId: Int
    var borrowedDate: String
    var returnDate: String?

    var memberName: String
    var bookTitle: String
}
