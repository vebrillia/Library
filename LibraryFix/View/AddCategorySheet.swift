//
//  AddCategorySheet.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var categoryName: String = ""
    var viewModel: CategoryViewModel

    var body: some View {
        NavigationView {
            VStack {
                TextField("Nama Kategori", text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                

                Spacer()
            }
            .navigationBarTitle("Tambah Kategori", displayMode: .inline)
            .navigationBarItems(leading: Button("Batal") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Simpan") {
                viewModel.addCategory(name: categoryName)
                presentationMode.wrappedValue.dismiss()
            }
                .disabled(categoryName.isEmpty)
            )
        }
    }
}
