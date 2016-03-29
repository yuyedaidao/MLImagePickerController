//
//  ViewController.swift
//  MLImagePickerController
//
//  Created by zhanglei on 16/3/14.
//  Copyright © 2016年 zhanglei. All rights reserved.
//
//  issue: https://github.com/MakeZL/MLImagePickerController/issues/new

import UIKit
import Photos
class ViewController: UIViewController,
                      MLImagePickerControllerDelegate,
                      UITableViewDataSource,
                      UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var dataArray: [AnyObject] = []
    var selectedAsset = [PHAsset]()
    var quickView:MLImagePickerQuickView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func selectPhoto() {
        let pickerVc = MLImagePickerController()
        // 回调
        pickerVc.delegate = self
        // 最大图片个数
        pickerVc.selectPickerMaxCount = 20
        pickerVc.selectAssets = self.selectedAsset
        pickerVc.show(self)
    }
    
    @IBAction func quick() {
        self.quickView?.removeFromSuperview()
        
        let quickView = MLImagePickerQuickView(frame: CGRectMake(0, self.view.frame.height - 250, self.view.frame.width, 250))
        quickView.delegate = self
        // 最大图片个数
        quickView.selectPickerMaxCount = 20
        // 默认记录选择的图片
//        quickView. = self.assetIdentifiers?.mutableCopy() as! NSMutableArray
        // 如果不传的话，预览不能打开相册
        quickView.viewControllerReponse = self
        // 准备工作
        quickView.prepareForInterfaceBuilderAndData()
        self.view.addSubview(quickView)
        self.quickView = quickView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.imageView!.image = self.dataArray[indexPath.item] as? UIImage
        return cell!
    }
    
    func imagePickerDidSelectedAssets(assets: [PHAsset], dataArray: [AnyObject]) {
        self.selectedAsset = assets
        self.dataArray = dataArray
        self.tableView.reloadData()
    }

}
