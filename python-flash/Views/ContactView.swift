//
//  ContactView.swift
//  python-flash
//
//  Created by Quantmis on 16/09/2023.
//

import SwiftUI

struct ContactView: View {
    private let developerText = """
    I'm Israa, the developer behind this app. I'm passionate about creating innovative solutions. This app is a result of that passion, and I hope it has been a valuable tool for you.

    If you've found this app useful, you can support the continued development by subscribing to the Pro version.
    """

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: PyTheme.S.l) {
                    profileCard
                    linksCard
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PyTheme.canvas, for: .navigationBar)
    }

    private var profileCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PyTheme.accentGradient)
                    .frame(width: 110, height: 110)
                    .shadow(color: PyTheme.accent.opacity(0.45), radius: 24, x: 0, y: 12)
                Image("dev")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            VStack(spacing: 4) {
                Text("Israa")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textPrimary)
                Text("Indie iOS developer")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(PyTheme.textTertiary)
            }

            Text(developerText)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(PyTheme.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    private var linksCard: some View {
        VStack(spacing: 0) {
            linkRow(title: "LinkedIn", icon: "link", url: "https://www.linkedin.com/in/israaibnusaifullah")
            Rectangle().fill(PyTheme.stroke).frame(height: 1).padding(.leading, 56)
            linkRow(title: "GitHub", icon: "chevron.left.forwardslash.chevron.right",
                    url: "https://github.com/QuantMis")
        }
        .glassCard()
    }

    private func linkRow(title: String, icon: String, url: String) -> some View {
        Button {
            if let u = URL(string: url) { UIApplication.shared.open(u) }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(PyTheme.accent)
                    .frame(width: 32, height: 32)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(PyTheme.accentSoft))
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(PyTheme.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(PyTheme.textTertiary)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContactView()
        }
        .preferredColorScheme(.dark)
    }
}
