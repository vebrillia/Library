//
//  EditBorrowingView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//

import SwiftUI

struct EditBorrowingView: View {
    @ObservedObject var viewModel: BorrowingViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedMemberId: Int
    @State private var selectedBookId: Int
    @State private var borrowedDate: Date
    @State private var borrowing: Borrowing

    init(viewModel: BorrowingViewModel, borrowing: Borrowing) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _borrowing = State(initialValue: borrowing)
        _selectedMemberId = State(initialValue: borrowing.memberId)
        _selectedBookId = State(initialValue: borrowing.bookId)
        _borrowedDate = State(initialValue: DateFormatter().date(from: borrowing.borrowedDate) ?? Date())
    }

    var body: some View {
        Form {
            Section(header: Text("Pilih Anggota")) {
                Picker("Anggota", selection: $selectedMemberId) {
                    ForEach(viewModel.members) { member in
                        Text(member.name).tag(member.id)
                    }
                }
            }

            Section(header: Text("Pilih Buku")) {
                Picker("Buku", selection: $selectedBookId) {
                    ForEach(viewModel.books.filter { book in
                        // Only show books that are NOT currently borrowed
                        !viewModel.borrowedBooks.contains(book.id) || book.id == selectedBookId
                    }) { book in
                        Text(book.title).tag(book.id)
                    }
                }
            }

            Section(header: Text("Tanggal Pinjam")) {
                DatePicker("Tanggal Pinjam", selection: $borrowedDate, displayedComponents: .date)
            }
        }
        .navigationBarTitle("Edit Peminjaman", displayMode: .inline)
        .navigationBarItems(
            trailing: Button("Simpan") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let borrowedDateString = dateFormatter.string(from: borrowedDate)

                // Update the borrowing
                viewModel.updateBorrowing(id: borrowing.id, memberId: selectedMemberId, bookId: selectedBookId, borrowedDate: borrowedDateString)

                // Close the view after saving
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}
