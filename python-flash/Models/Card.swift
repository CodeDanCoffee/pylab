//
//  Card.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import Foundation
struct Card: Identifiable, Decodable, Encodable {
    var id: String
    var cardgroup_id: Int
    var title: String
    var description: String
    var syntax: String
    var output: String
}
