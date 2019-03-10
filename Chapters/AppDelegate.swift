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

    // MARK: - IBOutlets
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var pdfView: PDFView!
    
    // MARK: - IBActions
    @IBAction func selectPDFAction(sender: AnyObject){
        self.selectPDF(sender: sender)
    }
    
    @IBAction func selectSaveFolderAction(sender: AnyObject){
        self.selectSaveFolder(sender: sender)
    }
    
    // MARK: - Properties
    
    var rootOutline: PDFOutline?
    var flatRootOutline: [PDFOutline] = [] // A flat, sequential list of all of root outlines descendents.
    var pdf: PDFDocument? // PDF that is to be split.
    var pdfName: String? // Name of PDF that is to be split.
    var dirtyPDF: PDFDocument? // Sub PDF waiting to be displayed.
    var prevPDF: PDFDocument? // Sub PDF being displayed.
    var outlineViewDataSource: OutlineDataSource? {
        didSet {
            self.outlineView.dataSource = outlineViewDataSource!
        }
    }
    
    // MARK: - Callbacks
    
    func openFileCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedPath = openPanel.urls[0]
            
            self.pdf = PDFDocument(url: selectedPath)!
            self.pdfView.document = self.pdf!
            if self.pdf!.outlineRoot != nil {
                self.rootOutline = self.pdf!.outlineRoot!
                self.outlineViewDataSource = OutlineDataSource(for: self.pdf!)
                self.pdfName = selectedPath.deletingPathExtension().lastPathComponent
                
                flatten(outline: self.rootOutline!, into: &(self.flatRootOutline))
                
                self.window!.makeKeyAndOrderFront(nil)
                self.outlineView.reloadData()
            }
            else {
                let alert = NSAlert()
                alert.informativeText = "Would you like to cancel or select another PDF?"
                alert.messageText = "The PDF you have selected does not have an outline/table of contents."
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Select another PDF")
                alert.addButton(withTitle: "Cancel")
                if alert.runModal() == .alertFirstButtonReturn {
                    self.selectPDF(sender: self)
                }
                else {
                    NSApplication.shared.terminate(self)
                }
            }
        }
    }
    
    func openDirectoryCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedURL = openPanel.urls[0].absoluteString
            let rootDirectoryName = selectedURL+pdfName!
            let rootDirectoryURL = URL(string: rootDirectoryName)
            do {
                try FileManager.default.createDirectory(at: rootDirectoryURL!, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            for i in 0..<self.flatRootOutline.count {
                let outline = self.flatRootOutline[i]
                let newPDF = makePDF(from: outline, within: self.flatRootOutline, outOf: self.pdf!)
                let path = makeURL(for: outline, relativeTo: rootDirectoryURL!)
                newPDF.write(to: path)
                #if DEBUG
                print("Wrote temp pdf to: "+path.absoluteString)
                #endif
            }
        }
    }
    
    // MARK: - File System Methods
    
    func selectPDF(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin() { (response) in
            self.openFileCallBack(response: response, openPanel: openPanel)
        }
    }
    
    func selectSaveFolder(sender: AnyObject){
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.begin() { (response) in
            self.openDirectoryCallBack(response: response, openPanel: openPanel)
        }
    }
    
    // MARK: - App Delegate Methods

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.outlineView.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
