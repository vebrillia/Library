//
//  AddMemberView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct AddMemberView: View {
    @ObservedObject var viewModel: MemberViewModel
    @Binding var member: Member?

    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informasi Anggota")) {
                    TextField("Nama Anggota", text: $name)
                        .autocapitalization(.words)
                }
            }
            .navigationBarTitle(member == nil ? "Tambah Anggota" : "Edit Anggota", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Batal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Simpan") {
                    if let member = member {
                        // Update existing member
                        viewModel.updateMember(id: member.id, name: name)
                    } else {
                        // Add new member
                        viewModel.addMember(name: name)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
            .onAppear {
                if let member = member {
                    name = member.name
                }
            }
        }
    }
}
