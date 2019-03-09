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
    @IBOutlet weak var pdfView: PDFView!
    
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
    
    @IBAction func selectSaveFolder(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin() { (response) in
            self.openDirectoryCallBack(response: response, openPanel: openPanel)
        }
    }
    
    var rootOutline: PDFOutline?
    var flatRootOutline: [PDFOutline] = []
    var pdf: PDFDocument?
    var rootDirectoryURL: URL?
    var pdfName: String?
    var tempDirURL: URL?
    
    func flatten(outline: PDFOutline) {
        for index in 0..<outline.numberOfChildren{
            let child = outline.child(at: index)!
            flatRootOutline.append(child)
            if (child.numberOfChildren != 0){
                flatten(outline: child)
            }
        }
    }
    
    func traverse(outline: PDFOutline) {
        for index in 0..<outline.numberOfChildren{
            let child = outline.child(at: index)
            print("Label: "+child!.label!+", Dest.: "+String(self.pdf!.index(for: child!.destination!.page!)))
            if (child!.numberOfChildren != 0){
                print("The child above has the following children.")
                traverse(outline: child!)
            }
        }
    }

    func openFileCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedPath = openPanel.urls[0]
            self.pdf = PDFDocument(url: selectedPath)!
            self.pdfView.document = self.pdf!
            self.rootOutline = pdf!.outlineRoot!
            flatten(outline: self.rootOutline!)
            pdfName = selectedPath.deletingPathExtension().lastPathComponent
            self.window!.makeKeyAndOrderFront(nil)
            self.outlineView.reloadData()
            
            for i in 0..<self.flatRootOutline.count {
                let outline = self.flatRootOutline[i]
                let startPage = outline.destination!.page!
                var endPage: PDFPage?
                if (i+1 == self.flatRootOutline.count) {
                    let pageCount = self.pdf!.pageCount
                    endPage = self.pdf!.page(at: pageCount-1)
                } else {
                    endPage = self.flatRootOutline[i+1].destination!.page!
                }
                let startIndex = self.pdf!.index(for: startPage)
                let endIndex = self.pdf!.index(for: endPage!)
                let newPDF = PDFDocument()
                for i in startIndex...endIndex {
                    let page = self.pdf!.page(at: i)
                    newPDF.insert(page!, at: i-startIndex)
                }
                var fileName = outline.label!
                fileName = fileName.replacingOccurrences(of: " ", with: "")
                fileName = fileName.replacingOccurrences(of: ".", with: "-")
                fileName = fileName.replacingOccurrences(of: "’", with: "")
                fileName = fileName.replacingOccurrences(of: "'", with: "")
                fileName = fileName+".pdf"
                let path = self.tempDirURL!.absoluteString+fileName
                newPDF.write(to: URL(string: path)!)
                print("Wrote temp pdf to: "+URL(string: path)!.absoluteString)
            }
        }
    }
    
    func openDirectoryCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedURL = openPanel.urls[0].absoluteString
            let rootDirectoryName = selectedURL+pdfName!
            rootDirectoryURL = URL(string: rootDirectoryName)
            do {
                try FileManager.default.createDirectory(at: rootDirectoryURL!, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.tempDirURL = FileManager.default.temporaryDirectory
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
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionIsChanging(_ notification: Notification) {
        print("Selected cell\n")
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
                return outline.child(at: index) as Any
            }
            return self.rootOutline!.child(at: index) as Any
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
            return ""
        }
        return nil
    }
}
