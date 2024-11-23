//
//  CategoryListView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject var viewModel = CategoryViewModel()
    @State private var newCategoryName: String = ""  // Untuk tambah kategori
    @State private var editingCategory: Category? = nil // Kategori yang sedang diedit
    @State private var showAddCategorySheet = false // Untuk membuka sheet add category

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            if editingCategory?.id == category.id {
                                // Jika kategori sedang diedit, tampilkan TextField
                                TextField("Nama Kategori", text: $newCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: newCategoryName) { _ in
                                        // Update kategori yang sedang diedit
                                        editingCategory?.name = newCategoryName
                                    }
                                    .frame(width: 200) // Membatasi lebar textfield

                                Spacer()

                                // Tombol untuk menyimpan perubahan saat edit selesai
                                Button(action: {
                                    // Update kategori jika sedang diedit
                                    if let updatedCategoryName = editingCategory?.name, !updatedCategoryName.isEmpty {
                                        viewModel.updateCategory(id: category.id, name: updatedCategoryName)
                                    }
                                    editingCategory = nil  // Menyelesaikan editing dan reset
                                    newCategoryName = ""
                                }) {
                                    Text("Selesai")
                                        .foregroundColor(.blue)
                                }
                            } else {
                                // Jika tidak sedang diedit, tampilkan nama kategori biasa
                                Text(category.name)
                                    .onTapGesture {
                                        // Set kategori untuk diedit
                                        editingCategory = category
                                        newCategoryName = category.name  // Isi dengan nama kategori yang dipilih
                                    }

                                Spacer()

                                // Tombol untuk mengedit kategori
                                Button(action: {
                                    // Memulai proses edit untuk kategori ini
                                    editingCategory = category
                                    newCategoryName = category.name
                                }) {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let category = viewModel.categories[index]
                            viewModel.deleteCategory(id: category.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Kategori Buku", displayMode: .inline)
                
                .onAppear {
                    viewModel.fetchCategories()
                }
                .navigationBarItems(trailing: Button(action: {
                    // Pastikan kategori dimuat sebelum menampilkan AddBookView
                    showAddCategorySheet = true
                }) {
                    Image(systemName: "plus")
                })
                // Tombol untuk menambah kategori baru
                
                .sheet(isPresented: $showAddCategorySheet) {
                    // Sheet untuk menambahkan kategori baru
                    AddCategorySheet(viewModel: viewModel)
                }
            }
        }
    }
}
