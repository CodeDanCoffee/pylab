//
//  ContentLoadingView.swift
//  python-flash
//
//  Game-style "Updating content…" screen shown while content is loaded or downloaded.
//

import SwiftUI

struct ContentLoadingView: View {
    /// `nil` → indeterminate (initial disk/bundle load).
    /// A value in `0...1` → determinate download progress.
    let progress: Double?

    @State private var pulse = false

    private var isUpdating: Bool { progress != nil }

    var body: some View {
        ZStack {
            PyTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 22) {
                Image(systemName: "command")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(PyTheme.accentGradient)
                    .scaleEffect(pulse ? 1.12 : 0.92)
                    .opacity(pulse ? 1 : 0.7)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)
                    .onAppear { pulse = true }

                VStack(spacing: 6) {
                    Text(isUpdating ? "Updating content" : "Loading")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(PyTheme.textPrimary)
                    Text(isUpdating
                         ? "Downloading the latest lessons…"
                         : "Getting things ready…")
                        .font(.subheadline)
                        .foregroundStyle(PyTheme.textTertiary)
                }

                Group {
                    if let progress {
                        VStack(spacing: 8) {
                            ProgressView(value: progress)
                                .tint(PyTheme.accent)
                                .frame(width: 220)
                            Text("\(Int(progress * 100))%")
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundStyle(PyTheme.textSecondary)
                        }
                    } else {
                        ProgressView()
                            .tint(PyTheme.accent)
                    }
                }
                .padding(.top, 4)
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentLoadingView(progress: nil)
            ContentLoadingView(progress: 0.6)
        }
        .preferredColorScheme(.dark)
    }
}
