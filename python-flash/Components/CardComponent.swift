//
//  CardComponent.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI
import HighlightSwift

struct CardComponent: View {
    let title: String
    let description: String
    let snippet: String
    let output: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PyTheme.S.l) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lesson")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(PyTheme.accent)
                        .textCase(.uppercase)
                    Text(title)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(PyTheme.textPrimary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(PyTheme.textSecondary)
                        .lineSpacing(3)
                }

                codeSection(title: "Syntax",
                            icon: "chevron.left.forwardslash.chevron.right",
                            code: snippet,
                            style: .solarFlare)

                codeSection(title: "Output",
                            icon: "terminal.fill",
                            code: output,
                            style: .xcode)
            }
            .padding(20)
        }
        .glassCard()
    }

    private func codeSection(title: String, icon: String,
                             code: String, style: HighlightStyle.Name) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }
}

struct CardComponent_Previews: PreviewProvider {
    static var previews: some View {
        CardComponent(title: "title", description: "description", snippet: "print('hi')", output: "hi")
            .padding()
            .background(PyTheme.backgroundGradient)
            .preferredColorScheme(.dark)
    }
}
