//
//  BookMarkView.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct BookMarkView: View {
    @ObservedObject private var bookmarkStorage = BookmarkStorage()

    var body: some View {
        NavigationStack {
            ZStack {
                PyTheme.backgroundGradient.ignoresSafeArea()

                if bookmarkStorage.bookmarks.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bookmarkStorage.bookmarks) { card in
                                bookmarkRow(card: card)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(PyTheme.canvas, for: .navigationBar)
        }
        .tint(PyTheme.accent)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(PyTheme.accentSoft)
                    .frame(width: 96, height: 96)
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(PyTheme.accentGradient)
            }
            Text("No bookmarks yet")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(PyTheme.textPrimary)
            Text("Tap the bookmark icon on any card to save it for quick access.")
                .font(.subheadline)
                .foregroundStyle(PyTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func bookmarkRow(card: Card) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PyTheme.accent)
                .frame(width: 44, height: 44)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(PyTheme.accentSoft))

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textPrimary)
                    .lineLimit(1)
                Text(card.description)
                    .font(.footnote)
                    .foregroundStyle(PyTheme.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PyTheme.textTertiary)
        }
        .padding(16)
        .glassCard()
    }
}

struct BookMarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookMarkView()
            .preferredColorScheme(.dark)
    }
}
