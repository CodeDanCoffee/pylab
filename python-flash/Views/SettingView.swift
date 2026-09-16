//
//  SettingView.swift
//  python-flash
//
//  Created by Israa on 26/10/2023.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var isShowingPaywall = false

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: PyTheme.S.l) {
                    proBanner
                    section(title: "Support", icon: "lifepreserver.fill") {
                        settingRow(icon: "envelope.fill",
                                   title: "Send Topic Suggestions",
                                   trailing: "chevron.right") { sendTopicRequest() }
                        divider
                        settingRow(icon: "text.bubble.fill",
                                   title: "Feedback",
                                   trailing: "chevron.right") { sendFeedback() }
                        divider
                        settingRow(icon: "star.fill",
                                   title: "Rate on App Store",
                                   trailing: "arrow.up.right") {
                            if let url = URL(string: "https://apps.apple.com/app/pycard/id6466706952") {
                                UIApplication.shared.open(url)
                            }
                        }
                        divider
                        NavigationLink {
                            ContactView()
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            settingRowLabel(icon: "person.fill", title: "Contact", trailing: "chevron.right")
                        }
                        .buttonStyle(.plain)
                    }

                    section(title: "About", icon: "info.circle.fill") {
                        HStack {
                            settingIcon("app.badge.fill")
                            Text("Version")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(PyTheme.textPrimary)
                            Spacer()
                            Text("1.4")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(PyTheme.textTertiary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PyTheme.canvas, for: .navigationBar)
        .sheet(isPresented: $isShowingPaywall) {
            PayWallView(isPresented: $isShowingPaywall)
                .preferredColorScheme(.dark)
        }
    }

    // MARK: - Pro banner

    private var proBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(PyTheme.accentGradient)
                        .frame(width: 44, height: 44)
                    Image(systemName: userViewModel.isSubscriptionActive ? "checkmark.seal.fill" : "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("PyLab")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(PyTheme.textPrimary)
                        Text("Pro")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(PyTheme.accentGradient)
                    }
                    Text(userViewModel.isSubscriptionActive ? "Active subscription" : "Unlock everything")
                        .font(.caption)
                        .foregroundStyle(PyTheme.textTertiary)
                }
                Spacer()
            }

            Text(userViewModel.isSubscriptionActive
                 ? "Thanks for supporting PyLab. Dive into every topic and enjoy the full experience."
                 : "Turbocharge your skills with exclusive snippets and advanced topics.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(PyTheme.textSecondary)
                .multilineTextAlignment(.leading)

            if !userViewModel.isSubscriptionActive {
                Button {
                    isShowingPaywall.toggle()
                } label: {
                    Text("See Pro plans")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Section builder

    @ViewBuilder
    private func section<Content: View>(title: String, icon: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PyTheme.accent)
                Text(title)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textTertiary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.leading, 6)

            VStack(spacing: 0) { content() }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(PyTheme.stroke)
            .frame(height: 1)
            .padding(.leading, 56)
    }

    // MARK: - Row builder

    @ViewBuilder
    private func settingRow(icon: String, title: String,
                            trailing: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            settingRowLabel(icon: icon, title: title, trailing: trailing)
        }
        .buttonStyle(.plain)
    }

    private func settingRowLabel(icon: String, title: String, trailing: String) -> some View {
        HStack(spacing: 14) {
            settingIcon(icon)
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(PyTheme.textPrimary)
            Spacer()
            Image(systemName: trailing)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PyTheme.textTertiary)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private func settingIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(PyTheme.accent)
            .frame(width: 32, height: 32)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(PyTheme.accentSoft))
    }

    // MARK: - Actions

    func sendFeedback() {
        let email = "codedancoffee@gmail.com"
        let subject = "Feedback on PyLab v1.0"
        if let emailURL = URL(string: "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(emailURL)
        }
    }

    func sendTopicRequest() {
        let email = "codedancoffee@gmail.com"
        let subject = "Topic Suggestions"
        if let emailURL = URL(string: "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(emailURL)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
