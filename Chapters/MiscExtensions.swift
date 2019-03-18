//    Chapters: Split PDF's based on their table of contents.
//    Copyright (C) 2019 Raphael Reyna
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

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
