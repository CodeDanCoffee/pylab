//
//  CodeSyntaxComponent.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI
import HighlightSwift


struct CodeSyntaxComponent: View {
    let code: String = """
    import math
    num = 4
    factorial = math.factorial(num)
    print(factorial)  
    """
    var body: some View {
        
        HStack {
            CodeText(code, style: .stackoverflow)
                Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray)
        .cornerRadius(15)
            
        
    }
}

struct CodeSyntaxComponent_Previews: PreviewProvider {
    static var previews: some View {
        CodeSyntaxComponent()
    }
}
