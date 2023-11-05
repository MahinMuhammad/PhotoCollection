//
//  PhotoEditViewController.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 11/4/23.
//

import UIKit
import CoreImage
import CoreImage.CIFilter

class PhotoEditViewController: UIViewController {
    
    let context = CIContext(options: nil) //Place to render the filtered image
    let filterList = CIFilter.filterNames(inCategory: nil)
    var photo:Photo?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let photo{
            if #available(iOS 16.0, *) {
                let path = getDocumentsDirectory().appending(component: photo.id!)
                imageView.image = UIImage(contentsOfFile: (path.path()))
            } else {
                let path = getDocumentsDirectory().appendingPathComponent(photo.id!)
                imageView.image = UIImage(contentsOfFile: (path.path))
            }
        }
    }
    
    //MARK: - Document Directory
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

//MARK: - UICollectionViewDataSource
extension PhotoEditViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.filterCellIdentifier, for: indexPath) as? FilterCell else{
            fatalError("Unable to dequeue a Photo Cell")
        }
        
        cell.imageView.image = UIImage(systemName: "square.and.arrow.up.fill")
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegate
extension PhotoEditViewController:UICollectionViewDelegate{
    
}
