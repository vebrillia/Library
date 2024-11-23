//
//  EditBookView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct EditBookView: View {
    @ObservedObject var viewModel: BookViewModel
    @State private var title: String
    @State private var author: String
    @State private var selectedCategories: [Int]
    @Environment(\.presentationMode) var presentationMode
    var book: Book

    // Custom initializer
    init(viewModel: BookViewModel, book: Book) {
        self.viewModel = viewModel
        self.book = book
        // Initialize state variables
        _title = State(initialValue: book.title)
        _author = State(initialValue: book.author)
        _selectedCategories = State(initialValue: viewModel.selectedCategories(for: book.id))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informasi Buku")) {
                    TextField("Judul Buku", text: $title)
                    TextField("Penulis", text: $author)
                }

                Section(header: Text("Pilih Kategori")) {
                    List {
                        ForEach(viewModel.categories) { category in
                            MultipleSelectionRow(
                                title: category.name,
                                isSelected: selectedCategories.contains(category.id)
                            ) {
                                if selectedCategories.contains(category.id) {
                                    selectedCategories.removeAll { $0 == category.id }
                                } else {
                                    selectedCategories.append(category.id)
                                }
                            }
                        }
                    }
                }
            }
            
            .navigationBarTitle("Edit Buku", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Batal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Simpan") {
                    viewModel.updateBook(id: book.id, title: title, author: author, categories: selectedCategories)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || author.isEmpty || selectedCategories.isEmpty)
            )
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Ensure categories are loaded when editing the book
            if viewModel.categories.isEmpty {
                viewModel.fetchCategories {
                    // When categories are fetched, update the state or UI if needed
                }
            }
        }
    }
}
