//
//  ImageShowViewController.swift
//  Image Machine
//
//  Created by Ridoan Wibisono on 25/07/21.
//

import UIKit

class ImageShowViewController: UIViewController {

	@IBOutlet weak var img_view: UIImageView!
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	var img : [ImagesEntity] = []
	
	var callBack : ((Bool)->())?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		img_view.image = UIImage(data: img[0].image)
    }
    
	@IBAction func close(_ sender : Any) {
		
		closeNow()
	}
	
	@IBAction func deleteImg(_ sender: Any) {
		let imgToDelete = self.img[0]
		self.context.delete(imgToDelete)
		do{
			try self.context.save()
			callBack?(true)
			closeNow()
		}
		catch{
			print(error.localizedDescription)
		}
	}
	

	func closeNow(){
		if let nav = self.navigationController {
			nav.popViewController(animated: true)
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
}
