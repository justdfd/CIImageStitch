//
//  Stitch.swift
//  CIImageStitch
//
//  Created by Dave Dombrowski on 8/30/18.
//  Copyright © 2018 justDFD. All rights reserved.
//

import UIKit

func openKernelFile(_ name:String) -> String {
    let filePath = Bundle.main.path(forResource: name, ofType: ".cikernel")
    do {
        return try String(contentsOfFile: filePath!)
    }
    catch let error as NSError {
        return error.description
    }
}

let CategoryStitched = "Stitch"

// MARK: Framer

class StitchedFilters: NSObject, CIFilterConstructor {
    static func registerFilters() {
        CIFilter.registerName(
            "Stitch",
            constructor: StitchedFilters(),
            classAttributes: [
                kCIAttributeFilterCategories: [CategoryStitched]
            ])
    }
    func filter(withName name: String) -> CIFilter? {
        switch name {
        case "Stitch":
            return Stitch()
        default:
            return nil
        }
    }
}

class Stitch:CIFilter {
    
    let kernel = CIKernel(source: openKernelFile("Stitch"))
    var inputThreshold:Float  = 0.25
    var inputPalette: CIImage!
    var inputOriginal: CIImage!
    var inputFlipped: CIImage!

    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "Stitch",
            
            "inputFade": [kCIAttributeIdentity: 0,
                          kCIAttributeClass: "NSNumber",
                          kCIAttributeDisplayName: "Fade",
                          kCIAttributeDefault: 0.5,
                          kCIAttributeMin: 0,
                          kCIAttributeSliderMin: 0,
                          kCIAttributeSliderMax: 1,
                          kCIAttributeType: kCIAttributeTypeScalar],
            
            "inputPalette": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
        
            "inputOriginal": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "CIImage",
                             kCIAttributeDisplayName: "Image",
                             kCIAttributeType: kCIAttributeTypeImage],
            
            "inputFlipped": [kCIAttributeIdentity: 0,
                             kCIAttributeClass: "CIImage",
                             kCIAttributeDisplayName: "Image",
                             kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    override init() {
        super.init()
    }
    override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputThreshold":
            inputThreshold = value as! Float
        case "inputPalette":
            inputPalette = value as! CIImage
        case "inputOriginal":
            inputOriginal = value as! CIImage
        case "inputFlipped":
            inputFlipped = value as! CIImage
        default:
            break
        }
    }
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var  outputImage: CIImage {
        return kernel!.apply(
            extent: inputPalette.extent,
            roiCallback: {(index, rect) in return rect},
            arguments: [
                inputThreshold as Any,
                inputPalette as Any,
                inputOriginal as Any,
                inputFlipped as Any
            ])!
    }
}
