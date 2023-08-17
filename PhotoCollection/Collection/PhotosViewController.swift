//
//  PhotosViewController.swift
//  PhotoCollection
//
//  Created by Md. Mahinur Rahman on 8/17/23.
//

import UIKit
import CoreData

class PhotosViewController: UIViewController {
    
    var photos = [Photo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhoto))
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        
        collectionView.addGestureRecognizer(gesture)
        
        loadPhotos()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setTopImage()
    }
    
    //MARK: - Setting Top Image
    func setTopImage(at index:Int=0){
        if photos.count != 0{
            let photo = photos[index]
            if #available(iOS 16.0, *) {
                let path = getDocumentsDirectory().appending(component: photo.id!)
                imageView.image = UIImage(contentsOfFile: (path.path()))
            } else {
                let path = getDocumentsDirectory().appendingPathComponent(photo.id!)
                imageView.image = UIImage(contentsOfFile: (path.path))
            }
        }
    }
    
    //MARK: - Drag and Drop feature
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer){
        switch gesture.state{
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else{
                return
            }
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
            self.collectionView.reloadData()
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
        
        cell.layer.cornerRadius = 20
        
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
        
        dismiss(animated: true)
    }
}

//MARK: - Delegate Method
extension PhotosViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setTopImage(at: indexPath.item)
    }
}
