//
//  MLImagePickerController.swift
//  MLImagePickerController
//
//  Created by zhanglei on 16/3/14.
//  Copyright © 2016年 zhanglei. All rights reserved.
//

import UIKit
import Photos

class MLImagePickerController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,MLImagePickerAssetsCellDelegate {
    
    var assets:NSMutableArray = []
    var collectionView:UICollectionView?
    let CELL_MARGIN:CGFloat = 2
    let CELL_ROW:CGFloat = 3
    let selectAssets:NSMutableArray = []
    let photoIdentifiers:NSMutableArray = []
    
    func show(vc:UIViewController!){
        let imagePickerVc = MLImagePickerController()
        let navigationVc = UINavigationController(rootViewController: imagePickerVc)
        
        vc.presentViewController(navigationVc, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let options:PHFetchOptions = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result:PHFetchResult = PHAsset.fetchAssetsWithOptions(options)
        
        let imageManager:PHCachingImageManager = PHCachingImageManager()

        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .FastFormat
        requestOptions.networkAccessAllowed = true

        for (var i = 0; i < result.count; i++){
            let asset:PHAsset = result[i] as! PHAsset
            
            self.photoIdentifiers.addObject(asset.localIdentifier)
            imageManager.requestImageForAsset(asset, targetSize: CGSizeMake(100, 100), contentMode: .AspectFit, options: requestOptions) { (let image, let info:[NSObject : AnyObject]?) -> Void in
                
                if image != nil {
                    self.assets.addObject(image!)
                    self.collectionView?.reloadData()
                }
            }
            
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.setupNavigationBar()
        self.setupCollectionView()
    }
    
    func setupNavigationBar(){

        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(15)
        btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        btn.setTitle("所有图片", forState: .Normal)
        btn.addTarget(self, action: "tappenTitleView", forControlEvents: .TouchUpInside)
        self.navigationItem.titleView = btn
        
    }
    
    func setupCollectionView(){
        let width = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .Vertical
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.minimumLineSpacing = 2
        collectionViewFlowLayout.itemSize = CGSizeMake(width, width)
        
        let assetsCollectionView = UICollectionView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), collectionViewLayout: collectionViewFlowLayout)
        assetsCollectionView.registerNib(UINib(nibName: "MLImagePickerAssetsCell", bundle: nil), forCellWithReuseIdentifier: "MLImagePickerAssetsCell")
        assetsCollectionView.backgroundColor = UIColor.clearColor()
        assetsCollectionView.dataSource = self
        assetsCollectionView.delegate = self
        self.view.addSubview(assetsCollectionView)
        self.collectionView = assetsCollectionView
    }
    
    func tappenTitleView(){
        print(" --- ")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.assets.count > 0) ? self.assets.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MLImagePickerAssetsCell = collectionView.dequeueReusableCellWithReuseIdentifier("MLImagePickerAssetsCell", forIndexPath: indexPath) as! MLImagePickerAssetsCell
        
        cell.delegate = self
        cell.localIdentifier = self.photoIdentifiers[indexPath.item] as! String
        cell.selectButtonSelected = self.selectAssets.containsObject(cell.localIdentifier)
        cell.imageV.image = self.assets[indexPath.item] as? UIImage
        
        return cell
    }
    
    func imagePickerSelectAssetsCellWithSelected(cell: UICollectionViewCell, selected: Bool) {
        let indexPath:NSIndexPath = (self.collectionView?.indexPathForCell(cell))!
        
        let identifier = self.photoIdentifiers[indexPath.item]
        if selected == true {
            self.selectAssets.addObject(identifier)
        }else{
            self.selectAssets.removeObject(identifier)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}
