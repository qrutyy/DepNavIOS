//
//  BottomSearchSheetView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//

import SwiftUI

struct BottomSearchSheetView: View {
    let callOnSubmit: () -> Void
    @Binding var idToFind: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Maps-style search bar - always visible
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search Maps", text: $idToFind)
                    .font(.system(size: 16))
                    .onSubmit(callOnSubmit)
                
                if !idToFind.isEmpty {
                    Button(action: {
                        idToFind = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.top, 25)
            .padding(.bottom, 20)
            
            // Content that only shows when sheet is expanded beyond the smallest detent
            ScrollView {
                VStack(spacing: 0) {
                    // Favorites section
                    VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Favourites")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("More") {
                        // More action
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                
                // Favorites grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                    FavoriteItemView(
                        icon: "house.fill",
                        title: "SE lab",
                        subtitle: "7777",
                        iconColor: .blue,
                        backgroundColor: Color(.systemGray5)
                    )
                    
                    FavoriteItemView(
                        icon: "briefcase.fill",
                        title: "Work",
                        subtitle: "Add",
                        iconColor: .blue,
                        backgroundColor: Color(.systemGray5)
                    )
                    
                    FavoriteItemView(
                        icon: "location.fill",
                        title: "Auditorium",
                        subtitle: "Main building",
                        iconColor: .white,
                        backgroundColor: .red
                    )
                    
                    FavoriteItemView(
                        icon: "plus",
                        title: "Add",
                        subtitle: "",
                        iconColor: .blue,
                        backgroundColor: Color(.systemGray5)
                    )
                }
                .padding(.horizontal, 16)
                    }
                    .padding(.top, 10)
            
            // Search results or recent section
            if !idToFind.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Results")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    LazyVStack(spacing: 0) {
                        SearchResultRow(
                            icon: "building.2.fill",
                            title: "Room \(idToFind)",
                            subtitle: "Main Building, Floor 2"
                        )
                        
                        SearchResultRow(
                            icon: "person.fill",
                            title: "Professor \(idToFind)",
                            subtitle: "Mathematics Department"
                        )
                    }
                }
                .padding(.horizontal, 16)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recents")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button("More") {
                            // More action
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    LazyVStack(spacing: 0) {
                        SearchResultRow(
                            icon: "building.2.fill",
                            title: "Lecture Hall 405",
                            subtitle: "Mathematics Building"
                        )
                        
                        SearchResultRow(
                            icon: "book.fill",
                            title: "Library",
                            subtitle: "Main Building, 1st Floor"
                        )
                    }
                }
            }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct FavoriteItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchResultRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .onTapGesture {
            print("Tapped on \(title)")
        }
    }
}

#Preview() {
    SearchResultRow(icon: "person.circle", title: "John Doe", subtitle: "johndoe@example.com")
}

