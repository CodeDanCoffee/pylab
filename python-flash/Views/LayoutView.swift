//
//  LayoutView.swift
//  python-flash
//
//  Created by Israa on 26/10/2023.
//

import SwiftUI
import UIKit

struct LayoutView: View {
    init() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1)
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        nav.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }

    var body: some View {
        HomeView()
            .tint(PyTheme.accent)
            .preferredColorScheme(.dark)
    }
}

struct LayoutView_Previews: PreviewProvider {
    static var previews: some View {
        LayoutView()
            .environmentObject(UserViewModel())
    }
}
