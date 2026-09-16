//
//  RequestView.swift
//  python-flash
//
//  Created by Israa on 30/10/2023.
//

import SwiftUI
import WishKit

struct RequestView: View {
    var body: some View {
        VStack {
            WishKit.view.withNavigation()
            Spacer().frame(height: 10)
        }
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
    }
}
