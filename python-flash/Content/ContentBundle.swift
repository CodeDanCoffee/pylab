//
//  ContentBundle.swift
//  python-flash
//
//  Plain value type holding one fully-decoded set of learning content.
//

import Foundation

/// An all-or-nothing snapshot of the three content collections. Either every
/// collection decoded successfully or there is no bundle — there is no partial state.
struct ContentBundle {
    let categories: [Category]
    let cardgroups: [CardGroup]
    let cards: [Card]
}
