//
//  PhotoCollectionViewCell.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 8/15/23.
//

/*
 Copyright 2023 Md. Mahinur Rahman
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
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
