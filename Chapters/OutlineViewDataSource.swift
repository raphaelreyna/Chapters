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
import Quartz

class OutlineDataSource: NSObject, NSOutlineViewDataSource {
    
    var pdf: PDFDocument
    var rootOutline: PDFOutline
    
    init(for pdf: PDFDocument){
        self.pdf = pdf
        self.rootOutline = pdf.outlineRoot!
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let outline = item as? PDFOutline {
            return outline.numberOfChildren
        }
        return self.rootOutline.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let outline = item as? PDFOutline {
            return outline.child(at: index) as Any
        }
        return self.rootOutline.child(at: index) as Any
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let outline = item as? PDFOutline {
            print(index)
            if outline.numberOfChildren == 0 {
                return false
            }
            return true
        }
        if self.rootOutline.numberOfChildren == 0 {
            return false
        }
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let outline = item as? PDFOutline {
            return outline.label!
        }
        return ""
    }
}
