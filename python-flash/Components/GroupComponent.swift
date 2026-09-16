//
//  GroupComponent.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI

struct GroupComponent: View {
    let title:String;
    var body: some View {
        VStack (spacing: 0) {
            
            // MARK: Main
            VStack(alignment: .center, spacing: 25) {
                HStack {
                    Text(title).font(.title).foregroundColor(.white).bold()
                    Spacer()
                }
            }
            .padding(60)
            .background(Color.cardBackground)
            
            // MARK: Description of Card
            
            HStack {
                VStack(alignment: .leading, spacing: 20){
                    Text("In SwiftUI, you can get the width of the screen using the").font(.headline).foregroundColor(.white).bold()
                    VStack(alignment: .leading, spacing: 10){
                        HStack {
                            Image(systemName: "globe").foregroundColor(.white)
                            Text("N Cards").font(.subheadline).foregroundColor(.white).bold()
                        }
                        HStack {
                            Image(systemName: "globe").foregroundColor(.white)
                            Text("5 Minutes").font(.subheadline).foregroundColor(.white).bold()
                        }
                    }
                }
                Spacer()
            }
            .padding(.all, 20)
            .background(Color.background.opacity(0))
            
            
        }
    }
}

struct GroupComponent_Previews: PreviewProvider {
    static var previews: some View {
        GroupComponent(title: "placeholder")
    }
}
