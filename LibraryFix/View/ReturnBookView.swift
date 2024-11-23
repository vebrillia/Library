//
//  ReturnBookView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct ReturnBookView: View {
    @ObservedObject var viewModel: BorrowingViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var returnDate: Date
    @State private var borrowing: Borrowing

    init(viewModel: BorrowingViewModel, borrowing: Borrowing) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _borrowing = State(initialValue: borrowing)
        
        // Parse the borrowed date into a Date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure the format matches the borrowedDate format
        
        // Use the borrowed date if valid, else fallback to the current date
        let borrowedDate = dateFormatter.date(from: borrowing.borrowedDate) ?? Date()
        _returnDate = State(initialValue: borrowedDate)  // Set returnDate to borrowedDate initially
    }

    var body: some View {
        Form {
            Section(header: Text("Informasi Peminjaman")) {
                Text("Buku: \(borrowing.bookTitle)")
                    .font(.headline)
                Text("Anggota: \(borrowing.memberName)")
                    .font(.subheadline)
                Text("Tanggal Pinjam: \(borrowing.borrowedDate)")
                    .font(.subheadline)
            }

            Section(header: Text("Tanggal Kembali")) {
                // DatePicker with the correct date range
                DatePicker("Tanggal Kembali", selection: $returnDate, in: borrowingDateRange(), displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())  // Default DatePicker style
            }
        }
        .navigationBarTitle("Kembalikan Buku", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Batal") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Simpan") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let returnDateString = dateFormatter.string(from: returnDate)

                viewModel.updateReturnDate(forBorrowingId: borrowing.id, returnDate: returnDateString)
                presentationMode.wrappedValue.dismiss()
            }
        ).navigationBarBackButtonHidden(true)
    }
    
    // Helper method to get the borrowing date as a Date object
    private func borrowingDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure the format matches the borrowedDate format
        return dateFormatter.date(from: borrowing.borrowedDate) ?? Date()
    }

    // Helper method to return the allowed range for the return date (from borrow date to today)
    private func borrowingDateRange() -> ClosedRange<Date> {
        let borrowedDate = borrowingDate()  // Start from the borrowing date
        let currentDate = Date()            // End on the current date (today)
        
        // Ensure the range is valid
        print("Borrowing Date: \(borrowedDate), Current Date: \(currentDate)") // Debugging line
        return borrowedDate...currentDate   // Return date must be between the borrowed date and today
    }
}

