//
//  AddBookView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct AddBookView: View {
    @ObservedObject var viewModel: BookViewModel
    @State private var title: String = ""
    @State private var author: String = ""
    @Environment(\.presentationMode) var presentationMode

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
                                isSelected: viewModel.selectedCategories.contains(category.id)
                            ) {
                                if viewModel.selectedCategories.contains(category.id) {
                                    viewModel.selectedCategories.removeAll { $0 == category.id }
                                } else {
                                    viewModel.selectedCategories.append(category.id)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Tambah Buku", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Batal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Simpan") {
                    viewModel.addBook(title: title, author: author)
                    viewModel.selectedCategories.removeAll()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(title.isEmpty || author.isEmpty || viewModel.selectedCategories.isEmpty)
            )
        }
    }
}


