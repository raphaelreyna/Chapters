//
//  OutlineViewDelegate.swift
//  Chapters
//
//  Created by Raphael Reyna on 3/9/19.
//  Copyright © 2019 Raphael Reyna. All rights reserved.
//

import Foundation

extension AppDelegate: NSOutlineViewDelegate {
    func outlineView(_: NSOutlineView, shouldExpandItem: Any) -> Bool {
        return true
    }
    
    func outlineView(_: NSOutlineView, shouldCollapseItem: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionIsChanging(_ notification: Notification) {
        let selectedRow = self.outlineView!.selectedRow
        let outline = self.outlineView!.item(atRow: selectedRow) as! PDFOutline
        self.dirtyPDF = makePDF(from: outline, within: self.flatRootOutline, outOf: self.pdf!)
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        self.prevPDF = self.dirtyPDF
        self.pdfView.document = self.prevPDF!
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        if let outline = item as? PDFOutline {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SectionCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = outline.label!
            }
        }
        return view
    }
}
