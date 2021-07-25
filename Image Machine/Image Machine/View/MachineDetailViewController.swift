//
//  MachineDetailViewController.swift
//  Image Machine
//
//  Created by Ridoan Wibisono on 24/07/21.
//

import UIKit
import CoreData

class MachineDetailViewController: UIViewController {
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	
	@IBOutlet weak var tf_id: UITextField!
	@IBOutlet weak var tf_name: UITextField!
	@IBOutlet weak var tf_type: UITextField!
	@IBOutlet weak var tf_qrcode: UITextField!
	@IBOutlet weak var btn_add_photo: UIButton!
	@IBOutlet weak var btn_save: UIButton!
	@IBOutlet weak var tf_maintain: UITextField!
	@IBOutlet weak var collView: UICollectionView!
	
	@IBOutlet weak var toggle_edit: UIBarButtonItem!
	var editMode = true
	var mode = false
	var passedValue = ""
	var datePicker: UIDatePicker!
	var lastMaintenance : Date?
	var callBack : ((Bool)->())?
	
	private var mData : [MachineEntity] = []
	private var mPhoto : [ImagesEntity] = []
	private var selectedImg : [ImagesEntity] = []
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		setupDatePicker()
		
		collView.dataSource = self
		collView.delegate = self
		
		tf_id.isEnabled = false
		
		if(passedValue != ""){editMode = true}
		else{editMode = false
			passedValue = UUID().uuidString
		}
		
		if editMode {
			setEditable(edt: mode)
			fecthImage()
			edit()
		}else{
			toggle_edit.isEnabled = false
			toggle_edit.tintColor = #colorLiteral(red: 0.9685460925, green: 0.9686815143, blue: 0.9685031772, alpha: 1)
			tf_id.text = passedValue
			setEditable(edt: true)
		}
	}
	
	@IBAction func save(_ sender: Any) {
		if editMode {
			
			let mach = mData[0]
			
			if tf_name.text != mData[0].name{
				mach.name = tf_name.text!
			}
			if tf_type.text != mData[0].type{
				mach.type = tf_type.text!
			}
			if tf_qrcode.text != String(mData[0].qrcode){
				mach.qrcode = Int64(tf_qrcode.text!)!
			}
			if tf_maintain.text != dateFormater(d: mData[0].maintance_date){
				mach.maintance_date = lastMaintenance!
			}
			
			do{
				try self.context.save()
				callBack?(true)
				performSegueToReturnBack()
			}
			catch{
				print(error.localizedDescription)
			}
			
		} else {
			let newMachine = MachineEntity(context: self.context)
			
			newMachine.id = UUID(uuidString: tf_id.text!)!
			newMachine.name = tf_name.text!
			newMachine.type = tf_type.text!
			newMachine.qrcode = Int64(tf_qrcode.text!)!
			newMachine.maintance_date = lastMaintenance!
			
			do{
				try self.context.save()
				callBack?(true)
				performSegueToReturnBack()
			}
			catch{
				print(error.localizedDescription)
			}
		}
		
		
	}
	
	@IBAction func pickImage(_ sender: Any) {
		let vc = UIImagePickerController()
		vc.sourceType = .photoLibrary
		vc.delegate = self
		vc.allowsEditing = true
		present(vc,animated: true)
	}
	
	@IBAction func viewEdit(_ sender: Any) {
		setEditable(edt: mode)
	}
	
	func setEditable(edt : Bool){
		if !edt  {
			tf_name.isEnabled = false
			tf_type.isEnabled = false
			tf_qrcode.isEnabled = false
			btn_add_photo.isEnabled = false
			btn_save.isHidden = true
			mode = true
		} else {
			tf_name.isEnabled = true
			tf_type.isEnabled = true
			tf_qrcode.isEnabled = true
			btn_add_photo.isEnabled = true
			btn_save.isHidden = false
			mode = false
		}
	}
	
	func edit() {
		tf_id.text = passedValue
		getData()
		tf_name.text = mData[0].name
		tf_type.text = mData[0].type
		tf_qrcode.text = String(mData[0].qrcode)
		tf_maintain.text = dateFormater(d: mData[0].maintance_date)
	}
	
	private func getData(){
		// Create a fetch request with a string filter
		// for an entity’s name
		let fetchRequest: NSFetchRequest<MachineEntity>
		fetchRequest = MachineEntity.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(
			format: "id == %@", UUID.init(uuidString: passedValue)! as CVarArg
		)
		
		// Perform the fetch request to get the objects
		// matching the predicate
		
		do{
			self.mData = try context.fetch(fetchRequest)
		}
		catch{
			print(error.localizedDescription)
		}
	}
	
	private func fecthImage(){
		let fetchRequest: NSFetchRequest<ImagesEntity>
		fetchRequest = ImagesEntity.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(
			format: "machine_id == %@", UUID.init(uuidString: passedValue)! as CVarArg
		)
		
		// Perform the fetch request to get the objects
		// matching the predicate
		
		do{
			self.mPhoto = try context.fetch(fetchRequest)
			collView.reloadData()
		}
		catch{
			print(error.localizedDescription)
		}
	}
	
	func performSegueToReturnBack()  {
		if let nav = self.navigationController {
			nav.popViewController(animated: true)
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	func dateFormater(d: Date) -> String {
		// Create Date Formatter
		let dateFormatter = DateFormatter()
		
		// Set Date Format
		dateFormatter.dateFormat = "MMM d, y"
		
		// Convert Date to String
		return dateFormatter.string(from: d)
	}
	
	
	func setupDatePicker(){
		self.datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 200))
		datePicker.datePickerMode = .date
		datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)
		
		if #available(iOS 13.4, *){
			datePicker.preferredDatePickerStyle = .wheels
		}
		
		self.tf_maintain.inputView = datePicker
		
		let toolBar:UIToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
		let spaceButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
		let doneButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.tapOnDoneButton))
		
		toolBar.setItems([spaceButton, doneButton], animated: true)
		
		self.tf_maintain.inputAccessoryView = toolBar
		
	}
	
	@objc func dateChanged(){
		let dateFormat = DateFormatter()
		dateFormat.dateStyle = .medium
		self.tf_maintain.text = dateFormat.string(from: datePicker.date)
		lastMaintenance = datePicker.date
	}
	
	@objc func tapOnDoneButton(){
		tf_maintain.resignFirstResponder()
	}
	
	
	func saveImage(data: Data) {
		let imageInstance = ImagesEntity(context: context)
		imageInstance.image = data
		imageInstance.machine_id = UUID(uuidString: tf_id.text!)!
		do {
			try context.save()
			print("Image is saved")
			fecthImage()
		} catch {
			print(error.localizedDescription)
		}
	}
}


extension MachineDetailViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		
		guard let userPickedImage = info[.editedImage] as? UIImage else { return }
		
		saveImage(data: userPickedImage.pngData()!)
//		saveImageView.image = userPickedImage

		picker.dismiss(animated: true, completion: nil)
	}
	
	
	
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}


extension MachineDetailViewController : UICollectionViewDelegate,UICollectionViewDataSource{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return mPhoto.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgGal", for: indexPath) as! CollectionImage
		
		// img here...
		cell.img_view.image = UIImage(data: mPhoto[indexPath.row].image)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedImg = mPhoto
			performSegue(withIdentifier: "popImg", sender: nil)
		}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
			if segue.identifier == "popImg" {
				let viewController = segue.destination as! ImageShowViewController
				viewController.callBack = { result in
					if result == true{
						self.fecthImage()
					}
				}
				viewController.img = selectedImg
			}
		}
	
}

class CollectionImage: UICollectionViewCell {
	@IBOutlet weak var img_view: UIImageView!
	
}




