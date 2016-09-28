//
//  OwlCell.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/23/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import UIKit

class OwlCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var heightLabel:UILabel!
    @IBOutlet weak var owlImageView:UIImageView!
    
    
    func setOwl(owl:Owl) {
        self.nameLabel.text = owl.name
        self.heightLabel.text = String(format:"%@", owl.height!)
        self.owlImageView.tintColor = UIColor(hexString: owl.color!)
    }
}
