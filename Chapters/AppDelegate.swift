//
//  AppDelegate.swift
//  Chapters
//
//  Created by Raphael Reyna on 3/7/19.
//  Copyright © 2019 Raphael Reyna. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var outlineView: NSOutlineView!

    @IBAction func selectPDF(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin() { (response) in
            self.openFileCallBack(response: response, openPanel: openPanel)
        }
    }
    
    var rootOutline: PDFOutline?
    var pdf: PDFDocument?

    func openFileCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedPath = openPanel.urls[0]
            pdf = PDFDocument(url: selectedPath)!
            rootOutline = pdf!.outlineRoot!
            self.window!.makeKeyAndOrderFront(nil)
            self.outlineView.reloadData()
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension AppDelegate: NSOutlineViewDelegate {
    func outlineView(_: NSOutlineView, shouldExpandItem: Any) -> Bool {
        return true
    }
    
    func outlineView(_: NSOutlineView, shouldCollapseItem: Any) -> Bool {
        return true
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

extension AppDelegate: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if self.rootOutline != nil {
            if let outline = item as? PDFOutline {
                return outline.numberOfChildren
            }
            return self.rootOutline!.numberOfChildren
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if self.rootOutline != nil {
            if let outline = item as? PDFOutline {
                return outline.child(at: index)
            }
            return self.rootOutline!.child(at: index)
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if self.rootOutline != nil {
            if let outline = item as? PDFOutline {
                print(index)
                if outline.numberOfChildren == 0 {
                    return false
                }
                return true
            }
            if self.rootOutline!.numberOfChildren == 0 {
                return false
            }
            return true
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if self.rootOutline != nil {
            if let outline = item as? PDFOutline {
                return outline.label!
            }
            return "idk"
        }
        return nil
    }
}

