//
//  OwlDel.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/23/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import UIKit

class OwlDel: OwlCVDelegate {
    var vc: ViewController!
    
    class func delegateForCV(grid:UICollectionView,
                             withVC vc:ViewController,
                             datasource:OwlCVDataSource) -> OwlDel {
        let delegate = OwlDel()
        
        delegate.vc = vc
        delegate.collectionView = grid
        
        grid.delegate = delegate
        grid.dataSource = delegate
        
        delegate.dataSource = datasource
        
        return delegate
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //VALIDATE DATA OBJECT
        let obj = self.dataObjectFor(item: nil, at: indexPath) as! Owl
        
        let cellIdentifier = "OwlCell"
        let cellClassName = "OwlCell"
        
        let item = self.dequeueCell(withIdentifier: cellIdentifier, cellClass: cellClassName, collectionView: collectionView, indexPath: indexPath) as! OwlCell
        
        item.setOwl(owl: obj)
        item.layer.shouldRasterize = true
        item.layer.rasterizationScale = UIScreen.main.scale
        
        return item
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width:CGFloat = 100
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsPortrait(interfaceOrientation) {
            let screenBounds = UIScreen.main.bounds
            width = screenBounds.size.width
        } else {
            let screenBounds = UIScreen.main.bounds
            width = screenBounds.size.height
        }
        
        return CGSize(width: width, height: 50)
    }
}








