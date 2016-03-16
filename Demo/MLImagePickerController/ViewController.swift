//
//  ViewController.swift
//  MLImagePickerController
//
//  Created by zhanglei on 16/3/14.
//  Copyright © 2016年 zhanglei. All rights reserved.
//
//  issue: https://github.com/MakeZL/MLImagePickerController/issues/new

import UIKit

class ViewController: UIViewController,
                      MLImagePickerControllerDelegate,
                      UITableViewDataSource,
                      UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var assets:NSArray? = []
    var assetIdentifiers:NSArray? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func selectPhoto() {
        let pickerVc = MLImagePickerController()
        // 回调
        pickerVc.delegate = self
        // 最大图片个数
        pickerVc.selectPickerMaxCount = 5
        // 默认记录选择的图片
        pickerVc.selectIndentifiers = self.assetIdentifiers?.mutableCopy() as! NSMutableArray
        pickerVc.show(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assets != nil ? self.assets!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.imageView!.image = self.assets![indexPath.item] as? UIImage
        return cell!
    }
    
    func imagePickerDidSelectedAssets(assets: NSArray, assetIdentifiers: NSArray) {
        self.assets = assets
        self.assetIdentifiers = assetIdentifiers
        self.tableView.reloadData()
    }

}
