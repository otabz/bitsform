//
//  PDFGenerator.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/27/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PDFGenerator {
    
    var pageSize:CGSize!
    var pdfHeight = CGFloat(1024.0) //This is configurable
    var pdfWidth = CGFloat(768.0)
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    let headSeparatorStr = "\n______________________________________________________________________\n"
    let fieldSeparatorStr = "\n"
    let sectionSeparatorStr = "\n\n"
    
    func generate(id: String) ->  String{
        pageSize = CGSizeMake (850, 1100)
        
        let fileName: NSString = "Uform.pdf"
        
        let path:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentDirectory: AnyObject = path.objectAtIndex(0)
        
        let pdfPathWithFileName = documentDirectory.stringByAppendingPathComponent(fileName as String)
        
        self.generatePDFs(pdfPathWithFileName, id: id)
        
        //lines written to get the document directory path for the generated pdf file.
        
        if let documentsPath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first?.path {
            
            //print(documentsPath)
            
            // “var/folder/…/documents\n” copy the full path
            
        }
        return pdfPathWithFileName
    }
    
    func generatePDFs(filePath: String, id: String) {
        
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil)
        
        //UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil)
        
        //toPDF()
        
        //self.drawBackground()
        
        //self.drawImage()
        
        //self.drawText()
        
        let pdfString : PDFString = coreDataToStringForm(id)
        let currentText: CFAttributedStringRef  = CFAttributedStringCreate(nil, pdfString.str, nil)
        let framesetter: CTFramesetterRef = CTFramesetterCreateWithAttributedString(currentText);
        
        var done = false
        var currentRange : CFRange  = CFRangeMake(0, 0);
        var currentPage : Int  = 0;
        var imagesDone = false
        repeat {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
            
            // Draw a page number at the bottom of each page.
            currentPage += 1;
            self.drawPageNumber(currentPage)
            if !imagesDone {
                let range = pdfString.str.rangeOfString("Attached Images" + headSeparatorStr)
                if range != nil {
                    let subString = pdfString.str.substringToIndex((range?.last)!)
                    imagesDone = drawImage(id, currentRange: currentRange, textBeforeImage: subString)
                }
            }
            
            currentRange = self.renderPageWithTextRange(currentRange, framesetter: framesetter)
            //print(currentRange)
            if currentRange.location == CFAttributedStringGetLength(currentText) {
                done = true;
            }
            
        } while !done
        
        
        UIGraphicsEndPDFContext()
        
    }
    
    func renderPageWithTextRange(var currentRange: CFRange, framesetter: CTFramesetterRef) -> CFRange {
        // Get the graphics context.
        let currentContext : CGContextRef = UIGraphicsGetCurrentContext()!;
        
        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
        
        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect : CGRect  = CGRectMake(72, 72, 468, 648);
        let framePath : CGMutablePathRef  = CGPathCreateMutable();
        CGPathAddRect(framePath, nil, frameRect);
        
        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frameRef : CTFrameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil);
        //print(CFArrayGetCount(CTFrameGetLines(frameRef)))
        //CGPathRelease(framePath);
        
        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        CGContextTranslateCTM(currentContext, 0, 792);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        
        // Draw the frame.
        CTFrameDraw(frameRef, currentContext);
        
        // Update the current range based on what was drawn.
        currentRange = CTFrameGetVisibleStringRange(frameRef);
        currentRange.location += currentRange.length;
        currentRange.length = 0;
        //CFRelease(frameRef);
        
        return currentRange;
    }
    
    func drawPageNumber(pageNum: Int)
    {
        let pageString : NSString = NSString(format: "Page %d", pageNum)
        let theFont = UIFont(name: "Helvetica Bold", size: 12)
        
        let _ : CGSize = CGSizeMake(612, 72);
        let textAttributes = [NSFontAttributeName: theFont!]
        
        let pageStringSizeRect : CGRect  = pageString.boundingRectWithSize(CGSizeMake(320, 2000), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
        
        let pageStringSize: CGSize = pageStringSizeRect.size
        
        
        let stringRect : CGRect  = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
            720.0 + ((72.0 - pageStringSize.height) / 2.0),
            pageStringSize.width,
            pageStringSize.height);
        
        let parameters: NSDictionary = [ NSFontAttributeName:theFont!]
        pageString.drawInRect(stringRect, withAttributes: parameters as? [String : AnyObject])
        
    }
    
    // draw the custom background view to display the text and image in pdf.
    
    func drawBackground () {
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        let rect:CGRect = CGRectMake(0, 0, pageSize.width, pageSize.height)
        
        CGContextSetFillColorWithColor(context, UIColor.brownColor().CGColor)
        
        CGContextFillRect(context, rect)
        
    }
    
    // draw the custom textview to display the text enter into it into pdf.
    
    func drawText(){
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        
        let font = UIFont(name: "HelveticaNeue-UltraLight", size: CGFloat(20))!
        
        CGContextSetFillColorWithColor(context, UIColor.orangeColor().CGColor)
        
        //let textRect : CGRect = CGRectMake(200, 350, ((self.txtView).frame).size.width, ((self.txtView).frame).size.height)
        let textRect : CGRect = CGRectMake(10, 50, (1/2 * self.pdfWidth), (1/5 * self.pdfHeight))
        
        let myString : NSString = "Sulaiman"
        
        let paraStyle = NSMutableParagraphStyle()
        
        paraStyle.lineSpacing = 6.0
        
        let fieldFont = UIFont(name: "Helvetica Neue", size: 30)
        
        let parameters: NSDictionary = [ NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle , NSFontAttributeName: fieldFont!]
        
        myString.drawInRect(textRect, withAttributes: parameters as? [String : AnyObject])
        
    }
    
    // draw the custom image to display into pdf with the given text you enter into textview
    
    func drawImage(id: String,  currentRange: CFRange, textBeforeImage: String) -> Bool {
        // selete form
        let form = NSFetchRequest(entityName: "Form")
        form.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            // Create a path object to enclose the text. Use 72 point
            // margins all around the text.
            let currentText: CFAttributedStringRef  = CFAttributedStringCreate(nil, textBeforeImage, nil)
            let framesetter: CTFramesetterRef = CTFramesetterCreateWithAttributedString(currentText);
            let frameRect : CGRect  = CGRectMake(72, 72, 468, 648);
            let framePath : CGMutablePathRef  = CGPathCreateMutable();
            CGPathAddRect(framePath, nil, frameRect);
            
            // Get the frame that will do the rendering.
            // The currentRange variable specifies only the starting point. The framesetter
            // lays out as much text as will fit into the frame.
            let frameRef : CTFrameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil);
            let y = (CFArrayGetCount(CTFrameGetLines(frameRef))*(15))
            let yAxis = CGFloat(y) + 77
            if 792 <= yAxis + 130 {
                return false
            }
            let frm = try self.Context.executeFetchRequest(form) as? [Form]
            if frm?.count > 0 {
                let form = frm![0]
                var xAxis: CGFloat = 72
                if let image1_ = form.photo1 {
                    UIImage(data: image1_, scale: 0.5)?.drawInRect(CGRectMake(xAxis, yAxis, 180, 130))
                    xAxis = xAxis + 200
                }
                
                if let image2_ = form.photo2 {
                    UIImage(data: image2_, scale: 0.5)?.drawInRect(CGRectMake(xAxis, yAxis, 180, 130))
                }
            }
        } catch {
            print(error)
        }
        return true
    }
    
    func coreDataToStringForm(id: String) -> PDFString {
        let rs = PDFString()
        var bigStr = ""
        var str = ""
        var imageStr = ""
        // selete specialty
        let specialty = NSFetchRequest(entityName: "Section_Specialty")
        specialty.predicate = NSPredicate(format: "form_id = %@", id)
        // selete time
        let time = NSFetchRequest(entityName: "Section_Time")
        time.predicate = NSPredicate(format: "form_id = %@", id)
        // selete form
        let form = NSFetchRequest(entityName: "Form")
        form.predicate = NSPredicate(format: "id = %@", id)
        // selete more fields
        let moreFields = NSFetchRequest(entityName: "More_Fields")
        moreFields.predicate = NSPredicate(format: "form_id = %@", id)
        
        do {
            
            let frm = try self.Context.executeFetchRequest(form) as? [Form]
            if frm?.count > 0 {
                let form = frm![0]
                // updated date
                if let updatedAt_ = form.updated_at {
                    //Format date
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                    dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                    let dateString = dateFormatter.stringFromDate(updatedAt_)
                    bigStr = bigStr + dateString + headSeparatorStr
   
                }
                // name
                if let name_ = form.name_en where !name_.isEmpty {
                    bigStr = bigStr + name_ + fieldSeparatorStr
               
                }
                // client identifier
                if let client_ = form.client_id where !client_.isEmpty {
                    bigStr = bigStr + client_ + fieldSeparatorStr
               
                }
                bigStr = bigStr + sectionSeparatorStr
                
                // contact & address
                // url
                if let url_ = form.url where !url_.isEmpty {
                    //bigStr = bigStr + url_ + fieldSeparatorStr
                    str = str + url_ + fieldSeparatorStr
                }
                // phone 1
                if let phone1_ = form.phone_reception where !phone1_.isEmpty {
                    //bigStr = bigStr + phone1_ + fieldSeparatorStr
                    str = str + phone1_ + fieldSeparatorStr
                }
                // phone 2
                if let phone2_ = form.phone_emergency where !phone2_.isEmpty {
                    //bigStr = bigStr + phone2_ + fieldSeparatorStr
                    str = str + phone2_ + fieldSeparatorStr
                }
                // latitude
                if let latitude_ = form.latitude where latitude_ != 0 {
                    //bigStr = bigStr + "Latitude: \(latitude_)" + fieldSeparatorStr
                    str = str + "Latitude: \(latitude_)" + fieldSeparatorStr
                }
                // longitude
                if let longitude_ = form.longitude where longitude_ != 0 {
                    //bigStr = bigStr + "Longitude: \(longitude_)" + fieldSeparatorStr
                    str = str + "Longitude: \(longitude_)" + fieldSeparatorStr
                }
                if !str.isEmpty {
                    bigStr = bigStr + "Contact & Address" + headSeparatorStr
                    bigStr = bigStr + str
                    bigStr = bigStr + sectionSeparatorStr
                }
                // images
                if form.photo1 != nil || form.photo2 != nil {
                    imageStr = imageStr + "Attached Images" + headSeparatorStr
                    imageStr = imageStr + sectionSeparatorStr + sectionSeparatorStr + sectionSeparatorStr + sectionSeparatorStr + sectionSeparatorStr
                    bigStr = bigStr + imageStr
                }
            }
            // working hours
            let tme = try self.Context.executeFetchRequest(time) as? [Section_Time]
            str = ""
            for each in tme! {
                str = str + each.day! + fieldSeparatorStr
                str = str + each.open_at! + "    " + each.close_at! + fieldSeparatorStr
               //bigStr = bigStr + each.day! + fieldSeparatorStr
               //bigStr = bigStr + each.open_at! + "    " + each.close_at! + fieldSeparatorStr
            }
            if !str.isEmpty {
                bigStr = bigStr + "Working Hours" + headSeparatorStr
                bigStr = bigStr +  str
                bigStr = bigStr + sectionSeparatorStr
            }
            
            // specialty
            let spe = try self.Context.executeFetchRequest(specialty) as? [Section_Specialty]
            str = ""
            for each in spe! {
                //bigStr = bigStr + each.name! + fieldSeparatorStr
                str = str + each.name! + fieldSeparatorStr
            }
            if !str.isEmpty {
                bigStr = bigStr + "Specialty/Department" + headSeparatorStr
                bigStr = bigStr + str
                bigStr = bigStr + sectionSeparatorStr
            }
            // more fields
            let more = try self.Context.executeFetchRequest(moreFields) as? [More_Fields]
            str = ""
            for each in more! {
                let fstr = try coreToStringMoreFields(each.field_id!, formId: id)
                str = str + fstr
            }
            bigStr = bigStr + str
            rs.str = bigStr
        } catch {
            print(error)
        }
        return rs
    }
    
    func coreToStringMoreFields(id: String, formId: String) throws -> String {
        // selete fields
        var str = ""
        let field = NSFetchRequest(entityName: "Field")
        field.predicate = NSPredicate(format: "id = %@", id)
        do {
            let found = try self.Context.executeFetchRequest(field) as? [Field]
            if found!.count > 0 {
                let f = found![0]
                let vstr = try coreToStringFieldValues(f.id!, formId: formId)
                if !vstr.isEmpty {
                    str = str + f.name! + headSeparatorStr + vstr + sectionSeparatorStr
                }
            }
        }
        return str
    }
    
    func coreToStringFieldValues(id: String, formId: String) throws -> String {
        // selete values
        var str = ""
        let field = NSFetchRequest(entityName: "More_Fields_Values")
        field.predicate = NSPredicate(format: "field_id = %@ AND form_id = %@", id, formId)
        do {
            let found = try self.Context.executeFetchRequest(field) as? [More_Fields_Values]
            if found!.count > 0 {
                for each in found! {
                    str = str + each.value! + fieldSeparatorStr
                }
            }
        }
        return str
    }
    
    class PDFString {
        var str: String = ""
        var numberOfPhotoSeparators: Int = 0
        var numberOfCharacters: Int = 0
    }

}
