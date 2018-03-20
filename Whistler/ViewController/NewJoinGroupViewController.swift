//
//  NewJoinGroupViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import Alamofire

class NewJoinGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let emoji = ["batman", "cat", "clown", "cool", "crazy", "devil", "hypnotized", "minion", "ninja", "pirate_cat", "shocked", "wink"]
    
    var selectedEmoji = 0;
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var groupName: UITextField!
    
    @IBAction func createGroupClicked(_ sender: UIButton) {
        
        if groupName.text?.isEmpty ?? true {
            let alertController = Utils.simpleAlertController(title: "Group name", message: "Please enter the group name and click on create group")
            self.present(alertController, animated: true, completion: nil)
            return;
        } else {
            print(emoji[selectedEmoji]);
            print(groupName.text!);
            
            let request: APIRequest<CreateGroup, ServerError> = TronService.sharedInstance.createRequest(path: "/group/create_group/\(groupName.text!)/\(emoji[selectedEmoji])");

            request.perform(withSuccess: { (response) in
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                print("Error ", error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self;
        collectionView.dataSource = self;
        selectedImage.image = UIImage(named: emoji[selectedEmoji])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupIconCell", for: indexPath) as! GroupIconCollectionViewCell
        if(selectedEmoji == indexPath.row) {
            cell.contentView.backgroundColor = UIColor.gray
        }
        cell.image.image = UIImage(named: emoji[indexPath.row]);
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        return cell;
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        unselectAllEmojiSelection()
        if let index = indexPath {
            let cell = self.collectionView.cellForItem(at: index) as! GroupIconCollectionViewCell
            selectedEmoji = index.row;
            cell.contentView.backgroundColor = UIColor.gray
            selectedImage.image = UIImage(named: emoji[selectedEmoji])
        }
    }
    
    func unselectAllEmojiSelection() {
        
        for cell in self.collectionView.visibleCells as! [GroupIconCollectionViewCell] {
            cell.contentView.backgroundColor = UIColor.clear
        }
    }

}
