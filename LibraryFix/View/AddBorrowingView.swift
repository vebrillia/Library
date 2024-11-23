//
//  AddBorrowingView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct AddBorrowingView: View {
    @ObservedObject var viewModel: BorrowingViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedMemberId: Int = 0
    @State private var selectedBookId: Int = 0
    @State private var borrowedDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pilih Anggota")) {
                    Picker("Anggota", selection: $selectedMemberId) {
                        Text("Pilih Anggota").tag(0)
                        ForEach(viewModel.members) { member in
                            Text(member.name).tag(member.id)
                        }
                    }
                }

                Section(header: Text("Pilih Buku")) {
                    Picker("Buku", selection: $selectedBookId) {
                        Text("Pilih Buku").tag(0)
                        ForEach(availableBooks) { book in
                            Text(book.title).tag(book.id)
                        }
                    }
                }

                Section(header: Text("Tanggal Pinjam")) {
                    DatePicker("Tanggal Pinjam", selection: $borrowedDate, in: ...Date(), displayedComponents: .date)
                }
            }
            .navigationBarTitle("Tambah Peminjaman", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Batal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Simpan") {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let borrowedDateString = dateFormatter.string(from: borrowedDate)

                    viewModel.addBorrowing(memberId: selectedMemberId, bookId: selectedBookId, borrowedDate: borrowedDateString)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedMemberId == 0 || selectedBookId == 0)
            )
        }
    }

    // Filter out books that are already borrowed
    private var availableBooks: [Book] {
        let borrowedBookIds = viewModel.borrowings.filter { $0.returnDate == nil }.map { $0.bookId }
        return viewModel.books.filter { !borrowedBookIds.contains($0.id) }
    }
}
