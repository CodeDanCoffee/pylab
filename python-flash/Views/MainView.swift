//
//  MainView.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        LayoutView()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
