//
//  UserViewModel.swift
//  python-flash
//
//  Created by Quantmis on 16/09/2023.
//

import Foundation
import SwiftUI
import RevenueCat

class UserViewModel: ObservableObject {
    @Published var isSubscriptionActive = false
    
    init() {
        /// - this is to check the user subscription status and published the status to be used on the entire app lifecycle
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if (customerInfo?.entitlements.all["Pro"]?.isActive == true) {
                self.isSubscriptionActive = true
            }
        }
    }
}
