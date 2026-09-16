//
//  CardView.swift
//  python-flash
//
//  Created by Quantmis on 15/09/2023.
//

import SwiftUI
import HighlightSwift

struct CardView: View {
    var currentCardGroup: CardGroup

    @State private var selectedIndex: Int = 0
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var contentStore: ContentStore

    private var currentCard: [Card] {
        contentStore.cards.filter { $0.cardgroup_id == currentCardGroup.id }
    }

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                TabView(selection: $selectedIndex) {
                    ForEach(Array(currentCard.enumerated()), id: \.element.id) { idx, card in
                        cardPage(card: card)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedIndex)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PyTheme.canvas, for: .navigationBar)
    }

    // MARK: - Progress

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(selectedIndex + 1) of \(max(currentCard.count, 1))")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textSecondary)
                Spacer()
                Text(currentCardGroup.title)
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundStyle(PyTheme.textTertiary)
                    .lineLimit(1)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(PyTheme.surface)
                    Capsule()
                        .fill(PyTheme.accentGradient)
                        .frame(width: geo.size.width * progressFraction)
                        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedIndex)
                }
            }
            .frame(height: 6)
        }
    }

    private var progressFraction: CGFloat {
        guard currentCard.count > 0 else { return 0 }
        return CGFloat(selectedIndex + 1) / CGFloat(currentCard.count)
    }

    // MARK: - Card page

    private func cardPage(card: Card) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PyTheme.S.l) {
                // Title block
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lesson")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(PyTheme.accent)
                        .textCase(.uppercase)
                    Text(card.title)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(PyTheme.textPrimary)
                    Text(card.description.replacingOccurrences(of: "\n", with: " "))
                        .font(.subheadline)
                        .foregroundStyle(PyTheme.textSecondary)
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                // Code block
                codeBlock(title: "Syntax",
                          icon: "chevron.left.forwardslash.chevron.right",
                          code: card.syntax,
                          style: .solarFlare)

                // Output block
                codeBlock(title: "Output",
                          icon: "terminal.fill",
                          code: card.output,
                          style: .xcode)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
        }
    }

    private func codeBlock(title: String, icon: String, code: String, style: HighlightStyle.Name) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PyTheme.accent)
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textPrimary)
                Spacer()
            }
            CodeText(code, style: style)
                .font(.system(.footnote, design: .monospaced))
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(PyTheme.canvas)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(PyTheme.stroke, lineWidth: 1)
                )
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CardView(currentCardGroup: CardGroup(id: 1, title: "String", total_cards: 5,
                                                 category_id: 1, description: "Text operations"))
                .environmentObject(UserViewModel())
                .environmentObject(ContentStore.preview)
        }
        .preferredColorScheme(.dark)
    }
}
