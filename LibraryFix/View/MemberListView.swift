//
//  MemberListView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//


import SwiftUI

struct MemberListView: View {
    @StateObject var viewModel = MemberViewModel()
    @State private var showAddMemberForm = false
    @State private var selectedMember: Member? = nil
    @State private var editedName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.members) { member in
                        HStack {
                            if selectedMember?.id == member.id {
                                // Inline text editing when this member is selected
                                TextField("Nama Anggota", text: $editedName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: editedName) { newValue in
                                        // Update the name in the member list as user types
                                        if let selectedMember = selectedMember {
                                            viewModel.updateMember(id: selectedMember.id, name: newValue)
                                        }
                                    }
                            } else {
                                // Display member name normally
                                Text(member.name)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if selectedMember?.id == member.id {
                                    // If the member is already selected, mark as done and save changes
                                    selectedMember = nil
                                    editedName = ""
                                } else {
                                    // Select member for editing
                                    selectedMember = member
                                    editedName = member.name
                                }
                            }) {
                                // Toggle between "Selesai" and "Pencil" based on editing state
                                Text(selectedMember?.id == member.id ? "Selesai" : "")
                                    .foregroundColor(.blue)
                                    .font(.body)
                                    .padding(.trailing, 10)
                                    .opacity(selectedMember?.id == member.id ? 1 : 0) // Show only when editing
                                
                                if selectedMember?.id != member.id {
                                    Image(systemName: "pencil.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let member = viewModel.members[index]
                            viewModel.deleteMember(id: member.id)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarTitle("Anggota", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    selectedMember = nil // Reset form for new member
                    showAddMemberForm = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $showAddMemberForm) {
                AddMemberView(viewModel: viewModel, member: $selectedMember)
            }
            .onAppear {
                viewModel.fetchMembers()
            }
        }
    }
}
