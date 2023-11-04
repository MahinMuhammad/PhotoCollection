//
//  PhotoEditViewController.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 11/4/23.
//

import UIKit

class PhotoEditViewController: UIViewController {
    
    var photo:Photo?
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
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
