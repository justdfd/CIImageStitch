//
//  GLKView.swift
//  CIImageStitch
//

import CoreImage
import GLKit

extension UIColor {
    func rgb() -> (Int?, Int?, Int?) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            return (iRed, iGreen, iBlue)
        } else {
            // Could not extract RGBA components:
            return (nil,nil,nil)
        }
    }
}

class ImageView: GLKView {
    var renderContext: CIContext
    var rgb:(Int?,Int?,Int?)!
    var myClearColor:UIColor!
    var clearColor: UIColor! {
        didSet {
            myClearColor = clearColor
        }
    }
    var image: CIImage! {
        didSet {
            setNeedsDisplay()
        }
    }
    var uiImage:UIImage? {
        get {
            let final = renderContext.createCGImage(self.image, from: self.image.extent)
            return UIImage(cgImage: final!)
        }
    }
    init() {
        let eaglContext = EAGLContext(api: .openGLES2)
        renderContext = CIContext(eaglContext: eaglContext!)
        super.init(frame: CGRect.zero)
        context = eaglContext!
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    override init(frame: CGRect, context: EAGLContext) {
        renderContext = CIContext(eaglContext: context)
        super.init(frame: frame, context: context)
        enableSetNeedsDisplay = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        let eaglContext = EAGLContext(api: .openGLES2)
        renderContext = CIContext(eaglContext: eaglContext!)
        super.init(coder: aDecoder)
        context = eaglContext!
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    func resize(image:CIImage, toRect:CGRect) -> CIImage {
        let cgimg = renderContext.createCGImage(image, from: toRect)
        return CIImage(cgImage: cgimg!)
    }
    override func draw(_ rect: CGRect) {
        if let image = image {
            let imageSize = image.extent.size
            var drawFrame = CGRect(x: 0, y: 0, width: CGFloat(drawableWidth), height: CGFloat(drawableHeight))
            let imageAR = imageSize.width / imageSize.height
            let viewAR = drawFrame.width / drawFrame.height
            if imageAR > viewAR {
                drawFrame.origin.y += (drawFrame.height - drawFrame.width / imageAR) / 2.0
                drawFrame.size.height = drawFrame.width / imageAR
            } else {
                drawFrame.origin.x += (drawFrame.width - drawFrame.height * imageAR) / 2.0
                drawFrame.size.width = drawFrame.height * imageAR
            }
            rgb = myClearColor.rgb()
            glClearColor(Float(rgb.0!)/256.0, Float(rgb.1!)/256.0, Float(rgb.2!)/256.0, 0.0);
            glClear(0x00004000)
            // set the blend mode to "source over" so that CI will use that
            glEnable(0x0BE2);
            glBlendFunc(1, 0x0303);
            renderContext.draw(image, in: drawFrame, from: image.extent)
        }
    }
}

// MARK: Scale Support

extension ImageView {
    var scaleFactor:CGFloat {
        guard let image = self.image, self.frame != CGRect.zero  else {
            return 0.0
        }
        
        let frame = self.frame
        let extent = image.extent
        let heightFactor = frame.height/extent.height
        let widthFactor = frame.width/extent.width
        
        if extent.height > frame.height || extent.width > frame.width {
            if heightFactor < 1 && widthFactor < 1 {
                if heightFactor > widthFactor {
                    return widthFactor
                } else {
                    return heightFactor
                }
            } else if extent.height > frame.height {
                return heightFactor
            } else {
                return widthFactor
            }
        } else if extent.height < frame.height && extent.width < frame.width {
            if heightFactor < widthFactor {
                return heightFactor
            } else {
                return widthFactor
            }
        } else {
            return 1
        }
    }
    
    var imageSize:CGSize {
        if self.image == nil {
            return CGSize.zero
        } else {
            return CGSize(width: (self.image?.extent.width)!, height: (self.image?.extent.height)!)
        }
    }
    
    var scaledSize:CGSize {
        guard let image = self.image, self.frame != CGRect.zero  else {
            return CGSize.zero
        }
        let factor = self.scaleFactor
        return CGSize(width: image.extent.width * factor, height: image.extent.height * factor)
    }
}
