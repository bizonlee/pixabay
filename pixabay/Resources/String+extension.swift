//
//  String+extension.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 03.04.2025.
//

import Foundation

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "\(self) banana")
    }
}
