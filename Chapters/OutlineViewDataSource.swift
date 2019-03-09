//
//  OutlineViewDataSource.swift
//  Chapters
//
//  This class provides data to the outline view.
//
//  Created by Raphael Reyna on 3/9/19.
//  Copyright © 2019 Raphael Reyna. All rights reserved.


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
