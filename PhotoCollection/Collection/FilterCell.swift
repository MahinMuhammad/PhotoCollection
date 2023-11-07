//
//  FilterCell.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 11/5/23.
//

import UIKit

class FilterCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override var isSelected: Bool {
       didSet{
           if self.isSelected {
               self.layer.borderWidth = 3
               self.layer.borderColor = UIColor.yellow.cgColor
           }
           else {
               self.layer.borderWidth = 1
               self.layer.borderColor = UIColor.lightGray.cgColor
           }
       }
   }
}
