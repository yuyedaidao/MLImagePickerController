//
//  MLImagePickerAssetsCell.swift
//  MLImagePickerController
//
//  Created by zhanglei on 16/3/15.
//  Copyright © 2016年 zhanglei. All rights reserved.
//

import UIKit

protocol MLImagePickerAssetsCellDelegate {
    func imagePickerSelectAssetsCellWithSelected(indexPath:NSIndexPath,let selected:Bool);
}

class MLImagePickerAssetsCell: UICollectionViewCell {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var imageV: UIImageView!
    var delegate:MLImagePickerAssetsCellDelegate?
    var localIdentifier:String!
    var indexPath:NSIndexPath!
    var selectButtonSelected:Bool! {
        didSet{
            if self.selectButton.selected == selectButtonSelected {
                return
            }
            self.selectButton.selected = selectButtonSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let noImage = self.ml_imageFromBundleNamed("zl_icon_image_no") as UIImage
        let yesImage = self.ml_imageFromBundleNamed("zl_icon_image_yes") as UIImage
        
        self.selectButton.setImage(noImage, forState: .Normal)
        self.selectButton.setImage(yesImage, forState: .Selected)
    }

    func ml_imageFromBundleNamed(named:String)->UIImage{
        let image = UIImage(named: "ZLPhotoLib.bundle".stringByAppendingString("/"+(named as String)))!
return image
//        let data = NSData(data: UIImagePNGRepresentation(image)!)
//        return UIImage(data: data)!
    }
    
    @IBAction func selectPhoto() {
        
        self.selectButton.selected = !self.selectButton.selected
        if self.delegate != nil {
            self.delegate?.imagePickerSelectAssetsCellWithSelected(self.indexPath, selected: self.selectButton.selected)
        }
    }
}
