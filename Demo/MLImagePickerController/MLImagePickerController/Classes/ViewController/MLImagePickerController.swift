//
//  MLImagePickerController.swift
//  MLImagePickerController
//
//  Created by zhanglei on 16/3/14.
//  Copyright © 2016年 zhanglei. All rights reserved.
//

import UIKit
import Photos

@objc protocol MLImagePickerControllerDelegate {
    optional func imagePickerDidSelectedAssets(assets: [PHAsset], data: [AnyObject])
    optional func imagePickerDidSelectedAssets(assets: NSArray, assetIdentifiers:NSArray)
}

private let MLImagePickerCellMargin:CGFloat = 2
private let MLImagePickerCellRowCount:CGFloat = 4
private let MLImagePickerMaxCount:Int = 9
private let MLImagePickerUIScreenScale = UIScreen.mainScreen().scale
private let MLImagePickerCellWidth = (UIScreen.mainScreen().bounds.size.width - MLImagePickerCellMargin * MLImagePickerCellRowCount + 1) / MLImagePickerCellRowCount

class MLImagePickerController:  UIViewController,
                                UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                MLImagePickerAssetsCellDelegate,
                                UITableViewDataSource,
                                UITableViewDelegate
{
    private var fetchResult:PHFetchResult!
//    private let selectImages:NSMutableArray = []
    var selectAssets = [PHAsset]()
//    private let photoIdentifiers:NSMutableArray = []
    private var groupSectionFetchResults:NSMutableArray = []
    private var AssetGridThumbnailSize:CGSize!
    private var imageManager:MLImagePickerAssetsManger!
    private var tableViewSelectedIndexPath:NSIndexPath! = NSIndexPath(forRow: 0, inSection: 0)
    
    private var collectionView:UICollectionView?
    private var navigationItemRightBtn:UIButton!
    private var groupTableContainerView:UIView?
    private var groupTableView:UITableView?
    private var messageLbl:UILabel!
    private var redTagLbl:UILabel!
    private var titleBtn:UIButton!
    
    // <MLImagePickerControllerDelegate>, SelectAssets CallBack
    var delegate:MLImagePickerControllerDelegate?
    // Setting Max Multiselect Count
    var selectPickerMaxCount:Int! = Int.max
    // Scroll Selecte Pickers, Default is YES
    var cancleLongGestureScrollSelectedPicker:Bool! = false
    
    func show(vc:UIViewController!){
        let imagePickerVc = MLImagePickerController()
        imagePickerVc.delegate = self.delegate
        imagePickerVc.selectPickerMaxCount = self.selectPickerMaxCount == nil ? MLImagePickerMaxCount : self.selectPickerMaxCount
        
        let navigationVc = UINavigationController(rootViewController: imagePickerVc)
        vc.presentViewController(navigationVc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()

        self.setupNavigationBar()
        self.setupCollectionView()
        self.initialization();
    }
    
    private func initialization(){
        
        self.imageManager = MLImagePickerAssetsManger()
        self.fetchResult = self.imageManager.result()
        AssetGridThumbnailSize = CGSizeMake(MLImagePickerCellWidth * MLImagePickerUIScreenScale, MLImagePickerCellWidth * MLImagePickerUIScreenScale);
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        
        if self.cancleLongGestureScrollSelectedPicker == false {
            self.collectionView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(MLImagePickerController.longPressGestureScrollPhoto(_:))))
        }
    }
    
    private func setupNavigationBar(){
        let titleBtn = UIButton(type: .Custom)
        titleBtn.frame = CGRectMake(0, 0, 200, 44)
        titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        titleBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        titleBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        titleBtn.setTitle("所有图片", forState: .Normal)
        titleBtn.addTarget(self, action: #selector(MLImagePickerController.tappenTitleView), forControlEvents: .TouchUpInside)

        titleBtn.setImage(UIImage.ml_imageFromBundleNamed("zl_xialajiantou"), forState: .Normal)
        self.navigationItem.titleView = titleBtn
        self.titleBtn = titleBtn
        
        let navigationItemRightBtn = UIButton(type: .Custom)
        navigationItemRightBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
        navigationItemRightBtn.frame = CGRectMake(0, 0, 30, 44)
        navigationItemRightBtn.setTitle("完成", forState: .Normal)
        
        navigationItemRightBtn.setTitleColor(UIColor(red: 49/256.0, green: 105/256.0, blue: 245/256.0, alpha: 1.0), forState: .Normal)
        
        navigationItemRightBtn.addTarget(self, action: #selector(MLImagePickerController.done), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationItemRightBtn)
        self.navigationItemRightBtn = navigationItemRightBtn
        
        let redTagLbl = UILabel()
        redTagLbl.hidden = (self.selectAssets.count == 0)
        redTagLbl.text = "\(self.selectAssets.count)"
        redTagLbl.layer.cornerRadius = 8.0
        redTagLbl.layer.masksToBounds = true
        redTagLbl.backgroundColor = UIColor.redColor()
        redTagLbl.textColor = UIColor.whiteColor()
        redTagLbl.font = UIFont.systemFontOfSize(12)
        redTagLbl.textAlignment = .Center
        redTagLbl.frame = CGRectMake(navigationItemRightBtn.frame.width-8,0, 16, 16)
        navigationItemRightBtn.addSubview(redTagLbl)
        self.redTagLbl = redTagLbl
    
    }
    
    func done(){
        if self.delegate != nil{
            //获取高清原图
        
//            self.delegate?.imagePickerDidSelectedAssets(self.selectImages, assetIdentifiers: self.selectIndentifiers)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func setupCollectionView(){
        let width = (self.view.frame.size.width - MLImagePickerCellMargin * MLImagePickerCellRowCount + 1) / MLImagePickerCellRowCount;
        
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
    
    func setupGroupTableView(){
        if (self.groupTableContainerView != nil){
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.groupTableContainerView?.alpha = (self.groupTableContainerView?.alpha == 1.0) ? 0.0 : 1.0
            })
            
        }else{
            let groupTableContainerView = UIView(frame: self.view.bounds)
            groupTableContainerView.alpha = 0.0
            groupTableContainerView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
            self.view.addSubview(groupTableContainerView)
            self.groupTableContainerView = groupTableContainerView
            
            let groupTableView = UITableView(frame: CGRectMake(0, 64, self.view.frame.width, 300), style: .Plain)
            groupTableView.registerNib(UINib(nibName: "MLImagePickerGroupCell", bundle: nil), forCellReuseIdentifier: "MLImagePickerGroupCell")
            groupTableView.separatorStyle = .None
            groupTableView.dataSource = self
            groupTableView.delegate = self
            self.groupTableContainerView!.addSubview(groupTableView)
            self.groupTableView = groupTableView
            
            let groupBackgroundView = UIView(frame: CGRectMake(0, CGRectGetMaxY(groupTableView.frame), groupTableContainerView.frame.width, groupTableContainerView.frame.height - CGRectGetMaxY(groupTableView.frame)))
            groupBackgroundView.backgroundColor = UIColor.clearColor()
            groupBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MLImagePickerController.setupGroupTableView)))
            self.groupTableContainerView!.addSubview(groupBackgroundView)
            
            let options:PHFetchOptions = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let allPhotos:PHFetchResult = PHAsset.fetchAssetsWithOptions(options)
            let smartAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: nil)
            let userCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
            self.groupSectionFetchResults = [allPhotos, smartAlbums, userCollections]
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.groupTableContainerView?.alpha = (self.groupTableContainerView?.alpha == 1.0) ? 0.0 : 1.0
            })
        }
    }
    
    func tappenTitleView(){
        self.setupGroupTableView()
    }
    
    // MARK: UICollectionViewDataSource && UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.fetchResult.count > 0) ? self.fetchResult.count : 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MLImagePickerAssetsCell = collectionView.dequeueReusableCellWithReuseIdentifier("MLImagePickerAssetsCell", forIndexPath: indexPath) as! MLImagePickerAssetsCell
        let asset:PHAsset = self.fetchResult[indexPath.item] as! PHAsset
        cell.delegate = self
        cell.asset = asset
        cell.indexPath = indexPath
        cell.localIdentifier = asset.localIdentifier
        cell.selectButtonSelected = self.selectAssets.contains(asset)
        cell.isShowVideo = (asset.mediaType == .Video)

        self.imageManager.requestImageForAsset(asset, targetSize: AssetGridThumbnailSize, contentMode: .AspectFill, options: nil) { (let image, let info:[NSObject : AnyObject]?) -> Void in
            
            // Set the cell's thumbnail image if it's still showing the same asset.
            if (cell.localIdentifier == asset.localIdentifier) {
                cell.imageV.image = image;
            }
        }
        
        return cell
    }
    
    // MARK: UITableViewDataSource && UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groupSectionFetchResults.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let result:PHFetchResult = self.groupSectionFetchResults[section] as! PHFetchResult
            return result.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let fetchResult:PHFetchResult = self.groupSectionFetchResults[indexPath.section] as! PHFetchResult
        
        let cell:MLImagePickerGroupCell = tableView.dequeueReusableCellWithIdentifier("MLImagePickerGroupCell") as! MLImagePickerGroupCell
        if indexPath.section == 0 {
            cell.titleLbl.text = "所有图片"
            cell.assetCountLbl.text = "\(fetchResult.count)"
        }else{
            let collection:PHAssetCollection = fetchResult[indexPath.row] as! PHAssetCollection
            let result:PHFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
            cell.titleLbl.text = collection.localizedTitle
            cell.assetCountLbl.text = "\(result.count)"
        }
        
        cell.selectedStatus = (self.tableViewSelectedIndexPath.section == indexPath.section && self.tableViewSelectedIndexPath.row == indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableViewSelectedIndexPath = indexPath
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.setupGroupTableView()
        
        let cell:MLImagePickerGroupCell = tableView.cellForRowAtIndexPath(indexPath) as! MLImagePickerGroupCell
        self.titleBtn.setTitle(cell.titleLbl.text, forState: .Normal)
        
        var fetchResult:PHFetchResult = self.groupSectionFetchResults[indexPath.section] as! PHFetchResult
        
        if indexPath.section != 0 {
            let collection:PHAssetCollection = fetchResult[indexPath.row] as! PHAssetCollection
            fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        }
        self.fetchResult = fetchResult
        self.groupTableView?.reloadData()
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: MLImagePickerAssetsCellDelegate
    func imagePickerSelectAssetsCellWithSelected(indexPath: NSIndexPath, selected: Bool) -> Bool {
        let asset:PHAsset = self.fetchResult[indexPath.item] as! PHAsset
        if selected == true {
            if !self.checkBeyondMaxSelectPickerCount() {
                return false
            }
            if !self.selectAssets.contains(asset) {
                self.selectAssets.append(asset)
            } else {
                return false
            }
        }else{
            // Delete
            if self.selectAssets.contains(asset) {
                self.selectAssets.removeAtIndex(self.selectAssets.indexOf(asset)!)
            }
        }
        self.redTagLbl.hidden = (self.selectAssets.count == 0)
        self.redTagLbl.text = "\(self.selectAssets.count)"
        return true
    }
    
    private func checkBeyondMaxSelectPickerCount()->Bool{
        if (self.selectAssets.count >= self.selectPickerMaxCount) {
            self.view.showWatting("选择照片不能超过\(self.selectPickerMaxCount!)张")
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.view.hideWatting()
            })
            return false
        }
        return true
    }
    
    // MARK: GestureRecognizer
    func longPressGestureScrollPhoto(gesture:UILongPressGestureRecognizer){
        let point = gesture.locationInView(self.collectionView)
        for cell in self.collectionView!.visibleCells() as! [MLImagePickerAssetsCell]  {
            if ((CGRectGetMaxY(cell.frame) > point.y && CGRectGetMaxY(cell.frame) - point.y <= cell.frame.height) == true &&
                (CGRectGetMaxX(cell.frame) > point.x && CGRectGetMaxX(cell.frame) - point.x <= cell.frame.width)
                ) == true {
                    let indexPath = self.collectionView?.indexPathForCell(cell)
                    if (self.checkBeyondMaxSelectPickerCount() == false){
                        return
                    }
                    cell.selectButtonSelected = true
                    self.imagePickerSelectAssetsCellWithSelected(indexPath!, selected: true)
            }
        }
    }
    
}
