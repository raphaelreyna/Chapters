import Cocoa
import Quartz

let openPanel = NSOpenPanel()
openPanel.allowsMultipleSelection = false
openPanel.canChooseDirectories = false
openPanel.canCreateDirectories = false
openPanel.canChooseFiles = true
openPanel.begin() { (response) in
    if response == NSApplication.ModalResponse.OK {
        let selectedPath = openPanel.urls[0]
        let pdfDocument = PDFDocument(url: selectedPath)!
        let outline = pdfDocument.outlineRoot!
        print("Number of children: " + String(outline.numberOfChildren))
        for index in 0...outline.numberOfChildren {
            let child = outline.child(at: index)!
            print("Child label: " + child.label! + "\n")
            let numberOfSubChildren = child.numberOfChildren
            if numberOfSubChildren > 0 {
                for subindex in 0...numberOfSubChildren {
                    let subchild = child.child(at: subindex)!
                    print("Subchild label: " + subchild.label! + "\n")
                }
            }
        }
    }
}
