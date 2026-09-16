//
//  CategoriesComponent.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct CategoriesComponent: View {
    let category:String;
    let active:Bool;
    var body: some View {
        if (active) {
            HStack {
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
                Text(category)
                    .foregroundColor(.white)
                    
            }
            .padding(10)
            .background(Color.cardBackground)
            .cornerRadius(15)
        } else {
            Text(category)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.cardBackground)
                .cornerRadius(15)
                .opacity(0.8)
        }
        
        
    }
}

struct CategoriesComponent_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesComponent(category: "Categories", active: true)
    }
}
