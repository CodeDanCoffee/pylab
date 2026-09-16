//
//  CardGroupView.swift
//  python-flash
//
//  Created by Quantmis on 15/09/2023.
//

import SwiftUI

struct CardGroupView: View {
    var currentCategory: Category
    @State private var isShowingPaywall = false
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var contentStore: ContentStore

    private var currentCardGroup: [CardGroup] {
        contentStore.cardgroups.filter { $0.category_id == currentCategory.id }
    }

    private var isLocked: Bool {
        currentCategory.is_premium && !userViewModel.isSubscriptionActive
    }

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: PyTheme.S.l) {
                    header
                    groupList
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .navigationTitle(currentCategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PyTheme.canvas, for: .navigationBar)
        .sheet(isPresented: $isShowingPaywall) {
            PayWallView(isPresented: $isShowingPaywall)
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PyTheme.accent)
                Text("Topic")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textTertiary)
                    .textCase(.uppercase)
                Spacer()
                if currentCategory.is_premium {
                    HStack(spacing: 4) {
                        Image(systemName: userViewModel.isSubscriptionActive ? "checkmark.seal.fill" : "lock.fill")
                            .font(.caption2)
                        Text(userViewModel.isSubscriptionActive ? "Unlocked" : "Pro")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(PyTheme.accentGradient))
                }
            }

            Text(currentCategory.title)
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(PyTheme.textPrimary)

            Text(currentCategory.description)
                .font(.subheadline)
                .foregroundStyle(PyTheme.textSecondary)
                .multilineTextAlignment(.leading)

            HStack(spacing: 16) {
                metric(icon: "rectangle.on.rectangle", value: "\(currentCardGroup.count)", label: "Lessons")
                metric(icon: "clock", value: "~\(max(5, currentCardGroup.count * 3))m", label: "Read time")
            }
            .padding(.top, 6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private func metric(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(PyTheme.accent)
                .frame(width: 28, height: 28)
                .background(Circle().fill(PyTheme.accentSoft))
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(PyTheme.textTertiary)
            }
        }
    }

    // MARK: - Group list

    private var groupList: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(currentCardGroup.enumerated()), id: \.element.id) { idx, group in
                groupRow(group: group, index: idx + 1)
            }
        }
    }

    @ViewBuilder
    private func groupRow(group: CardGroup, index: Int) -> some View {
        let row = CardGroupRow(group: group, index: index, isLocked: isLocked)

        if isLocked {
            Button { isShowingPaywall.toggle() } label: { row }
                .buttonStyle(.plain)
        } else {
            NavigationLink {
                CardView(currentCardGroup: group)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(group.title)
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                .foregroundStyle(PyTheme.textPrimary)
                        }
                    }
            } label: { row }
                .buttonStyle(.plain)
        }
    }
}

// MARK: - Row

private struct CardGroupRow: View {
    let group: CardGroup
    let index: Int
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(PyTheme.surfaceHi)
                    .frame(width: 44, height: 44)
                Text(String(format: "%02d", index))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(group.title)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textPrimary)
                    .lineLimit(1)
                Text(group.description)
                    .font(.footnote)
                    .foregroundStyle(PyTheme.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 8)
            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isLocked ? PyTheme.accent : PyTheme.textTertiary)
        }
        .padding(16)
        .glassCard()
        .contentShape(Rectangle())
    }
}

struct CardGroupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CardGroupView(currentCategory: Category(id: 1, title: "String",
                                                    description: "Text operations in Python",
                                                    is_premium: false, tag: "fundamentals"))
                .environmentObject(UserViewModel())
                .environmentObject(ContentStore.preview)
        }
        .preferredColorScheme(.dark)
    }
}
