//
//  ContentView.swift
//  LibraryFix
//
//  Created by Vebrillia Santoso on 23/11/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CategoryListView()
                .tabItem {
                    Label("Kategori", systemImage: "folder")
                }

            BookListView()
                .tabItem {
                    Label("Buku", systemImage: "book")
                }

            MemberListView()
                .tabItem {
                    Label("Anggota", systemImage: "person.2")
                }

            BorrowingListView()
                .tabItem {
                    Label("Peminjaman", systemImage: "book.circle")
                }
        }
    }
}


#Preview {
    ContentView()
}
