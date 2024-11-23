//
//  BookListView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct BookListView: View {
    @StateObject var viewModel = BookViewModel()
    @State private var showAddBookForm = false
    @State private var selectedCategoryId: Int? = nil  // Selected category ID

    var body: some View {
        NavigationView {
            VStack (spacing: 0){
                // Filter UI
                HStack {
                    // Category Filter
                    Picker("Select Category", selection: $selectedCategoryId) {
                        Text("Semua Kategori").tag(nil as Int?)  // Allow selecting all categories
                        ForEach(viewModel.categories, id: \.id) { category in
                            Text(category.name).tag(category.id as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedCategoryId) { _ in
                        // Fetch books based on selected category
                        viewModel.fetchBooksByCategory(categoryId: selectedCategoryId)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 8)
                

                // Book List
                List {
                    ForEach(viewModel.books) { book in
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text("Author: \(book.author)")
                                .font(.subheadline)

                            NavigationLink(
                                destination: EditBookView(viewModel: viewModel, book: book),
                                label: {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                }
                            )
                            .buttonStyle(PlainButtonStyle()) // Disable default button style
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let book = viewModel.books[index]
                            viewModel.deleteBook(id: book.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Daftar Buku", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    showAddBookForm = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $showAddBookForm) {
                if !viewModel.categories.isEmpty {
                    AddBookView(viewModel: viewModel)
                } else {
                    Text("Memuat kategori...") // Loading indicator
                }
            }
            .onAppear {
                // Fetch categories and books initially
                viewModel.fetchCategories {
                    viewModel.fetchBooksByCategory(categoryId: selectedCategoryId)
                }
            }
        }
    }
}



struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
