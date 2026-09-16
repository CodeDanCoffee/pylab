//
//  FlashCardView.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct FlashCardView: View {
    let cardGroupId: Int
    let title: String

    @State private var index: Int = 0
    @EnvironmentObject var contentStore: ContentStore

    private var cardsTemp: [Card] {
        contentStore.cards.filter { $0.cardgroup_id == cardGroupId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PyTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 16) {
                    NavigationLink {
                        HomeView().navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "house.fill")
                                .foregroundStyle(PyTheme.accent)
                            Text(title)
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                .foregroundStyle(PyTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(PyTheme.textTertiary)
                        }
                        .padding(16)
                        .glassCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    TabView(selection: $index) {
                        ForEach(Array(cardsTemp.enumerated()), id: \.element.id) { i, card in
                            CardComponent(title: card.title,
                                          description: card.description,
                                          snippet: card.syntax,
                                          output: card.output)
                                .padding(.horizontal, 20)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                }
                .padding(.top, 10)
            }
        }
    }
}

struct FlashCardView_Previews: PreviewProvider {
    static var previews: some View {
        FlashCardView(cardGroupId: 2, title: "Sample Title")
            .environmentObject(ContentStore.preview)
            .preferredColorScheme(.dark)
    }
}
