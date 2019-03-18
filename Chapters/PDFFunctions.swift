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

func traverse(outline: PDFOutline,
              startFunc: ((PDFOutline)->())?,
              midFunc: ((PDFOutline)->())?,
              endFunc: ((PDFOutline)->())?,
              postRecursionFunc: ((PDFOutline)->())?) {
    for index in 0..<outline.numberOfChildren {
        let child = outline.child(at: index)!
        if startFunc != nil && index == 0 {
            startFunc!(child)
        }
        if midFunc != nil && index > 0 && index < outline.numberOfChildren-1 {
            midFunc!(child)
        }
        if endFunc != nil && index == outline.numberOfChildren-1 {
            endFunc!(child)
        }
        if (child.numberOfChildren != 0){
            traverse(outline: child,
                     startFunc: startFunc,
                     midFunc: midFunc,
                     endFunc: endFunc,
                     postRecursionFunc: postRecursionFunc)
            if postRecursionFunc != nil {
                postRecursionFunc!(child)
            }
            
        }
    }
}

func flatten(outline: PDFOutline) -> [PDFOutline] {
    var list: [PDFOutline] = []
    let closure: ((PDFOutline)->()) = { child in if child.destination != nil { list.append(child) }
    }
    traverse(outline: outline,
             startFunc: closure,
             midFunc: closure,
             endFunc: closure,
             postRecursionFunc: nil)
    return list
}

func makePDF(from startOutline: PDFOutline,
             within outlines: [PDFOutline],
             outOf pdf: PDFDocument) -> PDFDocument {
    let startPage = startOutline.destination!.page!
    var endPage: PDFPage?
    let index = outlines.firstIndex(of: startOutline)!
    if (index+1 == outlines.count) {
        let pageCount = pdf.pageCount
        endPage = pdf.page(at: pageCount-1)
    } else {
        endPage = outlines[index+1].destination!.page!
    }
    let startIndex = pdf.index(for: startPage)
    let endIndex = pdf.index(for: endPage!)
    let subPDF = PDFDocument()
    if endIndex > startIndex {
        for i in startIndex...endIndex {
            let page = pdf.page(at: i)
            subPDF.insert(page!, at: i-startIndex)
        }
    } else {
        let page = pdf.page(at: startIndex)
        subPDF.insert(page!, at: 0)
    }
    return subPDF
}

func makeCleanLabel(for outline: PDFOutline) -> String {
    var label = outline.label!
    label = label.replacingOccurrences(of: ".", with: "-")
    label = label.forSorting
    return label
}

func makeURL(for outline: PDFOutline, relativeTo root: URL) -> URL {
    let filename = makeCleanLabel(for: outline)+".pdf"
    return root.appendingPathComponent(filename)
}
