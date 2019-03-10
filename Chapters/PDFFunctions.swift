//
//  PDFFunctions.swift
//  Chapters
//
// This file contains all of the methods for working with PDF related objects.
//
//  Created by Raphael Reyna on 3/9/19.
//  Copyright © 2019 Raphael Reyna. All rights reserved.
//

import Foundation
import Quartz

func traverse(_ outline: PDFOutline, with method: (PDFOutline)->()) {
    for index in 0..<outline.numberOfChildren{
        let child = outline.child(at: index)!
        method(child)
        if (child.numberOfChildren != 0){
            traverse(child, with: method)
        }
    }
}

func flatten(outline: PDFOutline, into list: inout [PDFOutline]) {
    traverse(outline) { child in if child.destination != nil { list.append(child) } }
}

func printLabels(outline: PDFOutline) {
    traverse(outline) { child in print(child.label!) }
}

func makePDF(from startOutline: PDFOutline, within outlines: [PDFOutline], outOf pdf: PDFDocument) -> PDFDocument{
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
    for i in startIndex...endIndex {
        let page = pdf.page(at: i)
        subPDF.insert(page!, at: i-startIndex)
    }
    return subPDF
}

func makeFileName(for outline: PDFOutline) -> String {
    var fileName = outline.label!
    fileName = fileName.replacingOccurrences(of: ".", with: "-")
    fileName = fileName.forSorting
    fileName = fileName + ".pdf"
    return fileName
}

func makeURL(for outline: PDFOutline, relativeTo root: URL) -> URL {
    let filename = makeFileName(for: outline)
    let path = root.absoluteString+"/"+filename
    return URL(string: path)!
}
