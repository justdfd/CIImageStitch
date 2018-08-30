//
//  ViewController.swift
//  CIImageStitch
//
//  Created by Dave Dombrowski on 8/30/18.
//  Copyright © 2018 justDFD. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let safeAreaView = UIView()
    let imageView = ImageView()
    let originalImage = CIImage(image: UIImage(named: "IMG_0190.JPG")!)
    var flippedImage:CIImage!
    var paletteImage:CIImage!
    var finalImage:CIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup a full screen GLKView
        
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeAreaView)
        imageView.clearColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        if #available(iOS 11, *) {
            safeAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            safeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            safeAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            safeAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            safeAreaView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
            safeAreaView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
            safeAreaView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            safeAreaView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        }
        imageView.topAnchor.constraint(equalTo: safeAreaView.topAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: safeAreaView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor).isActive = true
        
        // use CIPerspectiveCorrection to "flip" on the Y axis
        
        let minX:CGFloat = 0
        let maxY:CGFloat = 0
        let maxX = originalImage?.extent.width
        let minY = originalImage?.extent.height
        
        let flipFilter = CIFilter(name: "CIPerspectiveCorrection")
        flipFilter?.setValue(CIVector(x: minX, y: maxY), forKey: "inputTopLeft")
        flipFilter?.setValue(CIVector(x: maxX!, y: maxY), forKey: "inputTopRight")
        flipFilter?.setValue(CIVector(x: minX, y: minY!), forKey: "inputBottomLeft")
        flipFilter?.setValue(CIVector(x: maxX!, y: minY!), forKey: "inputBottomRight")
        flipFilter?.setValue(originalImage, forKey: "inputImage")
        flippedImage = flipFilter?.outputImage
        
        let paletteFilter = CIFilter(name: "CIConstantColorGenerator")
        paletteFilter?.setValue(CIColor(red: 0.7, green: 0.4, blue: 0.4), forKey: "inputColor")
        paletteImage = paletteFilter?.outputImage
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter?.setValue(paletteImage, forKey: "inputImage")
        cropFilter?.setValue(CIVector(x: 0, y: 0, z: (originalImage?.extent.width)! * 2, w: (originalImage?.extent.height)!), forKey: "inputRectangle")
        paletteImage = cropFilter?.outputImage
        
        // register and use stitch filer
        
        StitchedFilters.registerFilters()
        let stitchFilter = CIFilter(name: "Stitch")
        stitchFilter?.setValue(originalImage?.extent.width, forKey: "inputThreshold")
        stitchFilter?.setValue(paletteImage, forKey: "inputPalette")
        stitchFilter?.setValue(originalImage, forKey: "inputOriginal")
        stitchFilter?.setValue(flippedImage, forKey: "inputFlipped")
        finalImage = stitchFilter?.outputImage

        print(finalImage.extent)
        imageView.image = finalImage
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.setNeedsDisplay()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
