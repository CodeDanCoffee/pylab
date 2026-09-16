//
//  OnboardingView.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct OnboardingView: View {
    @State private var pageIndex = 0
    @State private var didTapGetStarted = false

    private struct Page: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let body: String
    }

    private let pages: [Page] = [
        .init(icon: "rectangle.stack.fill",
              title: "Learn Python\nin focused cards",
              body: "Bite-sized lessons covering syntax, examples, and output — designed to fit in a coffee break."),
        .init(icon: "sparkles",
              title: "Fundamentals\nto mastery",
              body: "Start with the basics and grow into advanced patterns, web development, and data."),
        .init(icon: "bolt.fill",
              title: "Code, not theory",
              body: "Every card comes with real Python snippets you can read, run, and remember.")
    ]

    var body: some View {
        ZStack {
            if didTapGetStarted {
                MainView().transition(.opacity)
            } else {
                onboardingContent.transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: didTapGetStarted)
    }

    private var onboardingContent: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { idx, page in
                        pageView(page: page).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.bottom, 18)

                actionRow
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func pageView(page: Page) -> some View {
        VStack(spacing: PyTheme.S.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(PyTheme.accentGradient)
                    .frame(width: 140, height: 140)
                    .shadow(color: PyTheme.accent.opacity(0.4), radius: 30, x: 0, y: 14)
                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(PyTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == pageIndex ? AnyShapeStyle(PyTheme.accentGradient) : AnyShapeStyle(PyTheme.surfaceHi))
                    .frame(width: i == pageIndex ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: pageIndex)
            }
        }
    }

    private var actionRow: some View {
        VStack(spacing: 12) {
            Button {
                if pageIndex < pages.count - 1 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        pageIndex += 1
                    }
                } else {
                    didTapGetStarted = true
                }
            } label: {
                Text(pageIndex < pages.count - 1 ? "Continue" : "Get Started")
            }
            .buttonStyle(PrimaryButtonStyle())

            if pageIndex < pages.count - 1 {
                Button {
                    didTapGetStarted = true
                } label: {
                    Text("Skip")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(PyTheme.textTertiary)
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}
