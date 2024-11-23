//
//  BorrowingListView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//

import SwiftUI

struct BorrowingListView: View {
    @StateObject var viewModel = BorrowingViewModel()
    @State private var showAddBorrowingForm = false
    @State private var selectedMemberId: Int? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Dropdown untuk memilih anggota
                HStack {
                    Picker("Pilih Anggota", selection: $selectedMemberId) {
                        Text("Semua Anggota").tag(nil as Int?)
                        ForEach(viewModel.members) { member in
                            Text(member.name).tag(member.id as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Spacer()
                }
                .padding(.leading, 8)

                // Daftar peminjaman
                List {
                    
                    ForEach(viewModel.borrowings) { borrowing in
                        VStack(alignment: .leading) {
//                            HStack{
//                                NavigationLink(destination: EditBorrowingView(viewModel: viewModel, borrowing: borrowing)) {
//                                    Text("Edit")
//                                        .foregroundColor(borrowing.returnDate == nil ? .blue : .gray)
//                                }
//                                .disabled(borrowing.returnDate != nil)
//                            }
                            
                            Text("Buku: \(borrowing.bookTitle)")
                                .font(.headline)
                            Text("Anggota: \(borrowing.memberName)")
                                .font(.subheadline)
                            Text("Tanggal Pinjam: \(borrowing.borrowedDate)")
                                .font(.subheadline)
                            if let returnDate = borrowing.returnDate {
                                Text("Tanggal Kembali: \(returnDate)")
                                    .font(.subheadline)
                            }
                            
                            

                                // Return Book Button (Disabled if the book is returned)
                            HStack{
                                if borrowing.returnDate == nil {
                                    NavigationLink(destination: ReturnBookView(viewModel: viewModel, borrowing: borrowing)) {
                                        Text("Kembalikan Buku")
                                            .foregroundColor(.red)
                                    }
                                    .disabled(false)
                                } else {
                                    Text("Buku Sudah Dikembalikan")
                                        .foregroundColor(.gray)
                                        .italic()
                                        .disabled(true) // Disable if the book is already returned
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let borrowing = viewModel.borrowings[index]
                            viewModel.deleteBorrowing(id: borrowing.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Peminjaman", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    viewModel.fetchMembersAndBooks()
                    showAddBorrowingForm = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $showAddBorrowingForm) {
                AddBorrowingView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchMembersAndBooks()
                fetchBorrowingsBasedOnSelection()
            }
            .onChange(of: selectedMemberId) { _ in
                fetchBorrowingsBasedOnSelection()
            }
        }
    }

    private func fetchBorrowingsBasedOnSelection() {
        if let memberId = selectedMemberId {
            viewModel.fetchBorrowings(forMemberId: memberId)
        } else {
            viewModel.fetchBorrowings()
        }
    }
}
