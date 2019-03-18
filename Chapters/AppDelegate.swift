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
    @IBOutlet weak var structeredOutputButton: NSButton!
    
    // MARK: - IBActions
    @IBAction func selectPDFAction(sender: AnyObject){
        self.selectPDF(sender: sender)
    }
    
    @IBAction func selectSaveFolderAction(sender: AnyObject){
        self.selectSaveFolder(sender: sender)
    }
    
    // MARK: - Properties
    
    var rootOutline: PDFOutline?
    var flatRootOutline: [PDFOutline]? // A flat, sequential list of all of root outlines descendents.
    var pdf: PDFDocument? // PDF that is to be split.
    var pdfName: String? // Name of PDF that is to be split.
    var dirtyPDF: PDFDocument? // Sub PDF waiting to be displayed.
    var prevPDF: PDFDocument? // Sub PDF being displayed.
    var currentWorkingDir: URL?
    var outlineViewDataSource: OutlineDataSource? {
        didSet {
            self.outlineView.dataSource = outlineViewDataSource!
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
    
    // MARK: - Callbacks
    
    func openFileCallBack(response: NSApplication.ModalResponse, openPanel: NSOpenPanel){
        if response == .OK {
            let selectedPath = openPanel.urls[0]
            
            self.pdf = PDFDocument(url: selectedPath)!
            self.pdfView.document = self.pdf!
            self.pdfView.autoScales = true
            if self.pdf!.outlineRoot != nil {
                self.rootOutline = self.pdf!.outlineRoot!
                self.outlineViewDataSource = OutlineDataSource(for: self.pdf!)
                self.pdfName = selectedPath.deletingPathExtension().lastPathComponent
                
                self.flatRootOutline = flatten(outline: self.rootOutline!)
                
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
            let selectedURL = openPanel.urls[0]
            self.currentWorkingDir = selectedURL.appendingPathComponent(self.pdfName!, isDirectory: true)
            do {
                try FileManager.default.createDirectory(at: self.currentWorkingDir!, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            if structeredOutputButton.state == .on {
                self.saveWithStructure(to: self.currentWorkingDir!)
            }
            else {
                self.saveWithoutStructure(to: self.currentWorkingDir!)
            }
        }
    }
    
    // MARK: - Saving Methods
    
    func saveWithoutStructure(to rootDirectoryURL: URL) {
        for i in 0..<self.flatRootOutline!.count {
            let outline = self.flatRootOutline![i]
            let newPDF = makePDF(from: outline, within: self.flatRootOutline!, outOf: self.pdf!)
            let path = makeURL(for: outline, relativeTo: rootDirectoryURL)
            newPDF.write(to: path)
            #if DEBUG
            print("Wrote pdf to: "+path.absoluteString)
            #endif
        }
    }
    
    func moveIntoNewDir(for outline: PDFOutline) {
        let newDirName = makeCleanLabel(for: outline)
        let newWorkingPath = self.currentWorkingDir!.appendingPathComponent(newDirName, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: newWorkingPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        self.currentWorkingDir = newWorkingPath
    }
    
    func writeChildOutline(outline: PDFOutline) {
        if outline.destination != nil {
            let childPDF = makePDF(from: outline, within: self.flatRootOutline!, outOf: self.pdf!)
            let path = makeURL(for: outline, relativeTo: self.currentWorkingDir!)
            childPDF.write(to: path)
            #if DEBUG
            print("Wrote pdf to: "+path.absoluteString)
            #endif
        }
    }
    
    func saveWithStructure(to rootDirectoryURL: URL) {
        let write: ((PDFOutline)->()) = { childOutline in
            if childOutline.numberOfChildren != 0 {
                self.moveIntoNewDir(for: childOutline)
            }
            self.writeChildOutline(outline: childOutline)
        }
        
        traverse(outline: self.rootOutline!,
                startFunc: write,
                midFunc: write,
                endFunc: write,
                postRecursionFunc: { _ in self.currentWorkingDir = self.currentWorkingDir!.deletingLastPathComponent() })
    }
    
    // MARK: - App Delegate Methods

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.outlineView.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
