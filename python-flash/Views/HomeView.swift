//
//  HomeView.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct HomeView: View {
    private enum TopicTab: Int, CaseIterable, Identifiable {
        case fundamentals, mastery, handsOn
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .fundamentals: return "Fundamentals"
            case .mastery:      return "Mastery"
            case .handsOn:      return "Hands-On"
            }
        }
        var icon: String {
            switch self {
            case .fundamentals: return "books.vertical.fill"
            case .mastery:      return "sparkles"
            case .handsOn:      return "wrench.and.screwdriver.fill"
            }
        }
        var tag: String {
            switch self {
            case .fundamentals: return "fundamentals"
            case .mastery:      return "mastery"
            case .handsOn:      return "hands-on"
            }
        }
        var blurb: String {
            switch self {
            case .fundamentals: return "Master the building blocks of Python."
            case .mastery:      return "Level-up topics for production engineers."
            case .handsOn:      return "Real-world projects, ready to ship."
            }
        }
    }

    @State private var selectedTab: TopicTab = .fundamentals
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var contentStore: ContentStore

    private var visibleCategories: [Category] {
        contentStore.categories.filter { $0.tag == selectedTab.tag }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PyTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: PyTheme.S.xl) {
                        heroHeader
                        filterPills
                        sectionHeader
                        categoryList
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Topics")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(PyTheme.canvas, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(PyTheme.textPrimary)
                    }
                }
            }
        }
        .tint(PyTheme.accent)
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Hero

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "command")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(PyTheme.accent)
                Text("PyLab")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textSecondary)
                if userViewModel.isSubscriptionActive {
                    Text("PRO")
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(PyTheme.accentGradient))
                }
                Spacer()
            }

            Text("What do you want\nto learn today?")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(PyTheme.textPrimary)
                .lineSpacing(2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Filter pills

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TopicTab.allCases) { tab in
                    pill(for: tab)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func pill(for tab: TopicTab) -> some View {
        let isOn = tab == selectedTab
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(tab.title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            .foregroundStyle(isOn ? Color.white : PyTheme.textSecondary)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(
                Capsule().fill(isOn ? AnyShapeStyle(PyTheme.accentGradient)
                                    : AnyShapeStyle(PyTheme.surface))
            )
            .overlay(
                Capsule().strokeBorder(isOn ? Color.clear : PyTheme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section header

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedTab.title)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textPrimary)
                Text(selectedTab.blurb)
                    .font(.subheadline)
                    .foregroundStyle(PyTheme.textTertiary)
            }
            Spacer()
            Text("\(visibleCategories.count)")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(PyTheme.textSecondary)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(PyTheme.surface))
                .overlay(Capsule().strokeBorder(PyTheme.stroke, lineWidth: 1))
        }
    }

    // MARK: - Category list

    private var categoryList: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(visibleCategories.enumerated()), id: \.element.id) { idx, category in
                NavigationLink {
                    CardGroupView(currentCategory: category)
                } label: {
                    CategoryCard(category: category, index: idx + 1)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - CategoryCard

private struct CategoryCard: View {
    let category: Category
    let index: Int
    @EnvironmentObject var userViewModel: UserViewModel

    private var iconName: String {
        let icons = ["chevron.left.forwardslash.chevron.right",
                     "function", "shippingbox.fill", "cube.transparent.fill",
                     "terminal.fill", "bolt.fill", "circle.grid.cross.fill"]
        return icons[index % icons.count]
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(PyTheme.accentSoft)
                    .frame(width: 52, height: 52)
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(PyTheme.accentGradient)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(category.title)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundStyle(PyTheme.textPrimary)
                        .lineLimit(1)
                    if category.is_premium && !userViewModel.isSubscriptionActive {
                        Text("PRO")
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(PyTheme.accentGradient))
                    }
                }
                Text(category.description)
                    .font(.footnote)
                    .foregroundStyle(PyTheme.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PyTheme.textTertiary)
        }
        .padding(16)
        .glassCard(radius: PyTheme.R.l)
        .contentShape(Rectangle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserViewModel())
            .environmentObject(ContentStore.preview)
            .preferredColorScheme(.dark)
    }
}
