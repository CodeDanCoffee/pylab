//
//  Extensions.swift
//  TBD
//
//  Created by Israa on 04/09/2023.
//

import SwiftUI
import RevenueCat
import StoreKit

// MARK: - Design System

enum PyTheme {
    // Brand
    static let accent       = Color(red: 0.98, green: 0.30, blue: 0.55)   // pink
    static let accentSoft   = Color(red: 0.98, green: 0.30, blue: 0.55).opacity(0.16)
    static let accentDeep   = Color(red: 0.78, green: 0.18, blue: 0.42)
    static let secondary    = Color(red: 0.55, green: 0.45, blue: 0.95)   // purple
    static let success      = Color(red: 0.30, green: 0.85, blue: 0.55)

    // Surfaces (dark-first)
    static let canvas       = Color(red: 0.04, green: 0.04, blue: 0.07)
    static let surface      = Color(red: 0.09, green: 0.09, blue: 0.13)
    static let surfaceHi    = Color(red: 0.13, green: 0.13, blue: 0.18)
    static let stroke       = Color.white.opacity(0.08)
    static let strokeStrong = Color.white.opacity(0.16)

    // Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textTertiary  = Color.white.opacity(0.45)

    // Gradients
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.04, blue: 0.10),
            Color(red: 0.02, green: 0.02, blue: 0.05)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.98, green: 0.30, blue: 0.55),
                 Color(red: 0.78, green: 0.18, blue: 0.62)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Radii & spacing
    enum R { static let s: CGFloat = 10, m: CGFloat = 16, l: CGFloat = 22, xl: CGFloat = 28 }
    enum S { static let xs: CGFloat = 4, s: CGFloat = 8, m: CGFloat = 12, l: CGFloat = 16, xl: CGFloat = 24, xxl: CGFloat = 32 }
}

// MARK: - Reusable view modifiers

struct GlassCard: ViewModifier {
    var radius: CGFloat = PyTheme.R.l
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(PyTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(PyTheme.cardGradient)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(PyTheme.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: PyTheme.R.m, style: .continuous)
                    .fill(PyTheme.accentGradient)
            )
            .shadow(color: PyTheme.accent.opacity(0.45), radius: 16, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded).weight(.medium))
            .foregroundColor(PyTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: PyTheme.R.m, style: .continuous)
                    .fill(PyTheme.surfaceHi)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PyTheme.R.m, style: .continuous)
                    .strokeBorder(PyTheme.stroke, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

extension View {
    func glassCard(radius: CGFloat = PyTheme.R.l) -> some View {
        modifier(GlassCard(radius: radius))
    }

    func pyBackground() -> some View {
        background(PyTheme.backgroundGradient.ignoresSafeArea())
    }
}

// MARK: - Legacy color helpers kept for back-compat

extension Color {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.04, blue: 0.10),
            Color(red: 0.02, green: 0.02, blue: 0.05)
        ],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let tabBarBackground = LinearGradient(
        colors: [Color.white.opacity(0.06), Color.white.opacity(0.02)],
        startPoint: .top, endPoint: .bottom
    )
    static let cardBackground = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

// MARK: - RevenueCat helpers

extension Package {
    func terms(for package: Package) -> String {
        if let intro = package.storeProduct.introductoryDiscount {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle) free trial"
            } else {
                return "\(package.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}

extension RevenueCat.SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "Unknown"
        }
    }

    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "s" : periodString
        return pluralized
    }
}
