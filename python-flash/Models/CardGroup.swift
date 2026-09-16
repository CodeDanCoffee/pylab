//
//  CardGroup.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import Foundation
struct CardGroup: Identifiable, Decodable {
    var id: Int
    var title: String
    var total_cards: Int
    var category_id: Int
    var description: String
}
