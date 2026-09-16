//
//  PayWallView.swift
//  python-flash
//
//  Created by Quantmis on 16/09/2023.
//

import SwiftUI
import RevenueCat

struct PayWallView: View {
    @State var currentOffering: Offering?
    @State private var selectedPackageId: String?
    @State private var isPurchasing = false
    @Binding var isPresented: Bool
    @EnvironmentObject var userViewModel: UserViewModel

    private let benefits: [(String, String)] = [
        ("rectangle.stack.fill",   "Unlock every Pro topic & lesson"),
        ("sparkles",               "Customize code snippet themes"),
        ("bolt.fill",              "Priority access to new content"),
        ("heart.fill",             "Support indie development")
    ]

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: PyTheme.S.xl) {
                    closeButton
                    hero
                    benefitsList
                    if let offering = currentOffering {
                        plansList(offering)
                    } else {
                        ProgressView()
                            .tint(PyTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }
                    purchaseCTA
                    footer
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 22)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            Purchases.shared.getOfferings { (offerings, _) in
                if let pkg = offerings?.current {
                    currentOffering = pkg
                    selectedPackageId = pkg.availablePackages.first?.identifier
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Sub-views

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(PyTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(PyTheme.surface))
                    .overlay(Circle().strokeBorder(PyTheme.stroke, lineWidth: 1))
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(PyTheme.accentGradient)
                    .frame(width: 64, height: 64)
                    .shadow(color: PyTheme.accent.opacity(0.45), radius: 18, x: 0, y: 8)
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 6) {
                Text("PyLab")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textPrimary)
                Text("Pro")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.accentGradient)
            }

            Text("Go further with every Python topic, unlocked.")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(PyTheme.textSecondary)
        }
    }

    private var benefitsList: some View {
        VStack(spacing: 12) {
            ForEach(benefits, id: \.1) { (icon, text) in
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(PyTheme.accent)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(PyTheme.accentSoft))
                    Text(text)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(PyTheme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .glassCard(radius: PyTheme.R.m)
            }
        }
    }

    private func plansList(_ offering: Offering) -> some View {
        VStack(spacing: 10) {
            ForEach(offering.availablePackages) { pkg in
                planRow(pkg)
            }
        }
    }

    private func planRow(_ pkg: Package) -> some View {
        let isSelected = selectedPackageId == pkg.identifier
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selectedPackageId = pkg.identifier
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.clear : PyTheme.strokeStrong, lineWidth: 1.5)
                        .background(Circle().fill(isSelected ? AnyShapeStyle(PyTheme.accentGradient) : AnyShapeStyle(Color.clear)))
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pkg.storeProduct.localizedTitle)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(PyTheme.textPrimary)
                    Text(pkg.terms(for: pkg))
                        .font(.caption)
                        .foregroundStyle(PyTheme.textTertiary)
                }
                Spacer()
                Text(pkg.storeProduct.localizedPriceString)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(PyTheme.textPrimary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: PyTheme.R.l, style: .continuous)
                    .fill(PyTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PyTheme.R.l, style: .continuous)
                    .strokeBorder(isSelected ? PyTheme.accent : PyTheme.stroke,
                                  lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseCTA: some View {
        Button {
            guard let offering = currentOffering,
                  let pkg = offering.availablePackages.first(where: { $0.identifier == selectedPackageId })
                       ?? offering.availablePackages.first else { return }
            isPurchasing = true
            Purchases.shared.purchase(package: pkg) { (_, customerInfo, _, _) in
                isPurchasing = false
                if customerInfo?.entitlements["Pro"]?.isActive == true {
                    userViewModel.isSubscriptionActive = true
                }
                isPresented.toggle()
            }
        } label: {
            HStack {
                if isPurchasing { ProgressView().tint(.white) }
                Text(isPurchasing ? "Processing..." : "Continue")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(currentOffering == nil || isPurchasing)
        .opacity(currentOffering == nil ? 0.5 : 1)
    }

    private var footer: some View {
        VStack(spacing: 14) {
            Button {
                Purchases.shared.restorePurchases { customerInfo, _ in
                    if customerInfo?.entitlements["Pro"]?.isActive == true {
                        userViewModel.isSubscriptionActive = true
                    }
                    isPresented.toggle()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(PyTheme.textSecondary)
            }

            HStack(spacing: 18) {
                link("Privacy Policy", url: "https://codedancoffee.io/privacy-policy")
                Text("·").foregroundStyle(PyTheme.textTertiary)
                link("Terms of Service", url: "https://codedancoffee.io/terms")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func link(_ title: String, url: String) -> some View {
        Button {
            if let u = URL(string: url) { UIApplication.shared.open(u) }
        } label: {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.medium))
                .foregroundStyle(PyTheme.textTertiary)
        }
    }
}
