//
//  MiscExtensions.swift
//  Chapters
//
//  Created by Raphael Reyna on 3/9/19.
//  Copyright © 2019 Raphael Reyna. All rights reserved.
//

import Foundation

extension String {
    var forSorting: String {
        let c = CharacterSet(charactersIn: "-")
        let charset = c.symmetricDifference(CharacterSet.alphanumerics)
        let simple = folding(options: [.diacriticInsensitive, .widthInsensitive], locale: nil)
        let nonAlphaNumeric = charset.inverted
        return simple.components(separatedBy: nonAlphaNumeric).joined(separator: "")
    }
}
