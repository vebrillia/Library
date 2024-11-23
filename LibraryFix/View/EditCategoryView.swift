//
//  EditCategoryView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//

import SwiftUI

struct EditCategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @Binding var category: Category?  // Kategori yang sedang diedit
    @State private var updatedCategoryName: String = "" // Nama kategori yang diupdate

    var body: some View {
        VStack {
            TextField("Nama Kategori", text: $updatedCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Update Kategori") {
                if let category = category {
                    viewModel.updateCategory(id: category.id, name: updatedCategoryName)
                }
                // Tutup sheet setelah selesai
                category = nil
                updatedCategoryName = ""
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .onAppear {
            // Isi dengan nama kategori yang diedit
            if let category = category {
                updatedCategoryName = category.name
            }
        }
    }
}
