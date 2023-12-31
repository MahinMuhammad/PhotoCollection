//
//  PhotosViewController.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 8/17/23.
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
import CoreData

class PhotosViewController: UIViewController {
    
    var photos = [Photo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        
        collectionView.addGestureRecognizer(gesture)
        
        loadPhotos()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //context menu
        let saveToPhotosLibrary = UIAction(title: "Save To Photos", image: UIImage(systemName: "square.and.arrow.down.on.square")) { _ in
            if let indexPath =  self.collectionView.indexPathsForSelectedItems?.last{
//                let photo = self.photos[indexPath.row]
                guard let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell else{return}
                guard let image = cell.imageView.image else{return}
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in
            if let indexPath =  self.collectionView.indexPathsForSelectedItems?.last{
                let photo = self.photos[indexPath.row]
                self.deletePhoto(of: photo)
            }
        }
        let deleteAll = UIAction(title: "Delete All", image: UIImage(systemName: "trash.fill"), attributes: .destructive) { _ in
            self.deleteAllPhotos()
        }
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [saveToPhotosLibrary, delete, deleteAll])
        
        //setting up the top canvas image as same as the selected image
        setTopImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    //this function gets called after saving image to the photos app is done
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to Photos App", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK: - Setting Top Image
    func setTopImage(at index:Int=0){
        if photos.count != 0{
            let photo = photos[index]
            if #available(iOS 16.0, *) {
                let path = getDocumentsDirectory().appending(component: photo.id!)
                canvasImageView.image = UIImage(contentsOfFile: (path.path()))
            } else {
                let path = getDocumentsDirectory().appendingPathComponent(photo.id!)
                canvasImageView.image = UIImage(contentsOfFile: (path.path))
            }
        }else{
            canvasImageView.image = nil
        }
    }
    
    //MARK: - Drag and Drop feature
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer){
        switch gesture.state{
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else{return}
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let photo = photos.remove(at: sourceIndexPath.item)
        photos.insert(photo, at: destinationIndexPath.item)
        updateIndex()
        savePhotos()
    }
    
    func updateIndex(){
        for i in 0..<photos.count{
            photos[i].index = Int32(i)
        }
    }
    
    //MARK: - Document Directory
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: - Data Manipulation Methods
    func savePhotos(){
        do{
            try context.save()
            collectionView.reloadData()
        }catch{
            print(error)
        }
    }
    
    func loadPhotos(){
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: K.indexTitle, ascending: true)]
        do{
            photos = try context.fetch(request)
        }catch{
            print("Error while loading photos")
        }
    }
    
    func deletePhoto(of photo:Photo){
        if let id = photo.id{
            do{
                try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent(id))
            }catch{
                print("Error deleting photo: \(error)")
            }
        }
        context.delete(photo)
        photos.removeAll { item in
            item == photo
        }
        savePhotos()
        setTopImage()
        collectionView.reloadData()
    }
    
    func deleteAllPhotos(){
        for photo in photos {
            if let id = photo.id{
                do{
                    try FileManager.default.removeItem(at: getDocumentsDirectory().appendingPathComponent(id))
                }catch{
                    print("Error deleting photo: \(error)")
                }
            }
            context.delete(photo)
        }
        photos.removeAll()
        savePhotos()
        setTopImage()
        collectionView.reloadData()
    }
    
    //MARK: - Add button function
    @IBAction func addButtonPressed(_ sender: UIButton) {
        addNewPhoto()
    }
    
    // MARK: - Navigation
    @IBAction func editButtonPressed(_ sender: UIButton) {
        if collectionView.indexPathsForSelectedItems?.count != 0{
            performSegue(withIdentifier: K.editSegueIdentifier, sender: self)
        }else{
            let alert = UIAlertController(title: "Warning", message: "Select a photo first", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = collectionView.indexPathsForSelectedItems?.last
        let destinationVC = segue.destination as! PhotoEditViewController
        destinationVC.photo = photos[indexPath!.row]
    }
}

//MARK: - Data source Method
extension PhotosViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.photoCellIdentifier, for: indexPath) as? PhotoCell else{
            fatalError("Unable to dequeue a Photo Cell")
        }
        
        let photo = photos[indexPath.item]
        if #available(iOS 16.0, *) {
            let path = getDocumentsDirectory().appending(component: photo.id!)
            cell.imageView.image = UIImage(contentsOfFile: (path.path()))
        } else {
            let path = getDocumentsDirectory().appendingPathComponent(photo.id!)
            cell.imageView.image = UIImage(contentsOfFile: (path.path))
        }
        
        return cell
    }
}

//MARK: - Picker Funtionalities
extension PhotosViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @objc func addNewPhoto(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true //let you crop the picture before adding
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else{
            return
        }
        let id = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(id)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let photo = Photo(context: context)
        photo.id = id
        photo.index = Int32(photos.count)
        photos.append(photo)
        savePhotos()
        
        if canvasImageView.image == nil{
            setTopImage()
        }
        
        dismiss(animated: true)
    }
}

//MARK: - Delegate Method
extension PhotosViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setTopImage(at: indexPath.item)
//        selectedPhoto = photos[indexPath.item]
    }
}
