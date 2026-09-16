//
//  Category.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import Foundation
struct Category: Identifiable, Decodable {
    var id: Int
    var title: String
    var description: String
    var is_premium: Bool
    var tag: String
}
