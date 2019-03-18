//
//  ImageViewController.swift
//  MapInterface
//
//  Created by linChunbin on 3/18/19.
//  Copyright © 2019 clpk8. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var runFlag = true;
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //send image signal to firebase
        let ref = Database.database().reference()
        ref.child("image").child("takeImage").setValue(1)
        print("1 is set")
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.startAnimating()
        sleep(2)
        //retrive image
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "image.jpg")
            pathReference.getData(maxSize: 1 * 720 * 578) { data, error in
                if let error = error {
                    print(error)
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    self.imageView.image = image
                    self.activityIndicator.stopAnimating()
                    pathReference.delete(completion: { (error) in
                        if let error = error{
                            print(error)
                        } else {
                            print("deleted")
                        }
                    })
                    self.runFlag = false
                }
            }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveImage(_ sender: Any) {
        
        if let image = imageView.image{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        let alert = UIAlertController(title: "Saving", message: "Image is saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
