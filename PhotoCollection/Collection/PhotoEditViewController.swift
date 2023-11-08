//
//  PhotoEditViewController.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 11/4/23.
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
import CoreImage

class PhotoEditViewController: UIViewController {
    
    var photo:Photo?
    var fetchedImage:UIImage?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    var context: CIContext!
    var currentFilter: CIFilter?
    let filterList:[CIFilter?] = [
        nil,
        CIFilter(name: "CIBoxBlur"),
        CIFilter(name: "CISepiaTone"),
        CIFilter(name: "CIPhotoEffectMono"),
        CIFilter(name: "CIPhotoEffectProcess"),
        CIFilter(name: "CIPhotoEffectChrome"),
        CIFilter(name: "CIPhotoEffectFade"),
        CIFilter(name: "CIPhotoEffectTonal")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchedImage = fetchImageFromDocummentDirectory()
        imageView.image = fetchImageFromDocummentDirectory()
        
        context = CIContext() //Place to render the filtered image
        currentFilter = nil
    }
    
    func fetchImageFromDocummentDirectory()->UIImage?{
        if let photo{
            if #available(iOS 16.0, *) {
                let path = getDocumentsDirectory().appending(component: photo.id!)
                return UIImage(contentsOfFile: (path.path()))
            } else {
                let path = getDocumentsDirectory().appendingPathComponent(photo.id!)
                return UIImage(contentsOfFile: (path.path))
            }
        }
        return nil
    }
    
    func processImage(for index:IndexPath)->UIImage?{
        currentFilter = filterList[index.row]
        if let currentFilter{
            let inputImage = CIImage(image: fetchedImage!)
            currentFilter.setValue(inputImage, forKey: kCIInputImageKey)
            if let output = currentFilter.outputImage{
                if let cgimg = context.createCGImage(output, from: output.extent){
                    let processedImage = UIImage(cgImage: cgimg)
                    return processedImage
                }
            }
        }
        return fetchedImage //filter nil returns original image
    }
    
    @IBAction func savedPressed(_ sender: UIButton) {
        updateImageToDocumentDirectory()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Document Directory
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func updateImageToDocumentDirectory(){
        if let id = photo?.id{
            let imagePath = getDocumentsDirectory().appendingPathComponent(id)
            if let jpegData = imageView.image?.jpegData(compressionQuality: 0.8){
                try? jpegData.write(to: imagePath)
            }
        }
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
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.imageView.image = processImage(for: indexPath)
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegate
extension PhotoEditViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentFilter != filterList[indexPath.row]{ //same filter must be used once
            imageView.image = processImage(for: indexPath)
        }
    }
}
