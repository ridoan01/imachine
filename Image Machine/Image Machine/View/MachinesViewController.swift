//
//  MachinesViewController.swift
//  Image Machine
//
//  Created by Ridoan Wibisono on 24/07/21.
//

import UIKit
import CoreData

class MachinesViewController: UIViewController {
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	
	@IBOutlet weak var machine_tbl: UITableView!
	@IBOutlet weak var sort: UIButton!
	
	private var mData : [MachineEntity] = []
	private var mPhoto : [ImagesEntity] = []
	
	private var mId = ""
	
	override func viewDidLoad() {
		super .viewDidLoad()
		
		
		machine_tbl.delegate = self
		machine_tbl.dataSource = self
		
		fetchMachines()
		
	}
	
	func fetchMachines() {
		do{
			self.mData = try context.fetch(MachineEntity.fetchRequest())
			
			DispatchQueue.main.async {
				self.machine_tbl.reloadData()
			}
			
		}
		catch{
			print("\(error.localizedDescription)")
		}
	}
	
	
	@IBAction func sortTapped(_ sender: Any) {
		
		let optionMenu = UIAlertController(title: nil, message: "Choose Sort Option", preferredStyle: .actionSheet)
		
		let nameAsc = UIAlertAction(title: "Name ASC", style: .default) { UIAlertAction in
			self.sort(int: 0)
		}
		let nameDsc = UIAlertAction(title: "Name DESC", style: .default){ UIAlertAction in
			self.sort(int: 1)
		}
		let typeAsc = UIAlertAction(title: "Type ASC", style: .default){ UIAlertAction in
			self.sort(int: 2)
		}
		let typeDsc = UIAlertAction(title: "Type DESC", style: .default){ UIAlertAction in
			self.sort(int: 3)
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel)
		
		optionMenu.addAction(nameAsc)
		optionMenu.addAction(nameDsc)
		optionMenu.addAction(typeAsc)
		optionMenu.addAction(typeDsc)
		optionMenu.addAction(cancel)
		self.present(optionMenu, animated: true, completion: nil)
		
	}
	
	@IBAction func addNew(_ sender: Any) {
		//		performSegue(withIdentifier: "addNew", sender: self)
	}
	
	
	private func sort(int: Int){
		
		switch int {
		case 0:
			mData = mData.sorted(by: {$0.name < $1.name})
			machine_tbl.reloadData()
			
		case 1:
			mData = mData.sorted(by: {$0.name > $1.name})
			machine_tbl.reloadData()
			
		case 2:
			mData = mData.sorted(by: {$0.type < $1.type})
			machine_tbl.reloadData()
			
		default:
			mData = mData.sorted(by: {$0.type > $1.type})
			machine_tbl.reloadData()
		}
		machine_tbl.reloadData()
	}
}


extension MachinesViewController : UITableViewDelegate, UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "machineCell", for: indexPath as IndexPath) as! MachinesTableViewCell
		
		cell.machine_name.text = mData[indexPath.row].name
		cell.machine_type.text = mData[indexPath.row].type
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		mId = mData[indexPath.row].id.uuidString
		
		performSegue(withIdentifier: "viewEdit", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "viewEdit" {
			let viewController = segue.destination as! MachineDetailViewController
			viewController.callBack = { result in
				if result == true{
					self.fetchMachines()
				}
			}
			viewController.passedValue = mId
		}
		if segue.identifier == "addNew" {
			let viewController = segue.destination as! MachineDetailViewController
			viewController.callBack = { result in
				if result == true{
					self.fetchMachines()
				}
			}
			viewController.editMode = false
		}
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction(style: .destructive, title: "Delete"){(action, view, completionHandler) in
			let machineId = self.mData[indexPath.row].id
			
			let machineToRemove = self.mData[indexPath.row]
			
			self.context.delete(machineToRemove)
			
			do{
				try self.context.save()
				self.fecthImage(msi: machineId)
			}
			catch{
				print(error.localizedDescription)
			}
			self.fetchMachines()
			
			
		}
		return UISwipeActionsConfiguration(actions: [action])
	}
	
	private func fecthImage(msi : UUID){
		let fetchRequest: NSFetchRequest<ImagesEntity>
		fetchRequest = ImagesEntity.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(
			format: "machine_id == %@", msi as CVarArg
		)
		
		do{
			self.mPhoto = try context.fetch(fetchRequest)
			delImage()
		}
		catch{
			print(error.localizedDescription)
		}
	}
	
	
	private func delImage(){
		let imgToDelete = mPhoto[0]
		self.context.delete(imgToDelete)
		do{
			try self.context.save()
			mPhoto = []
		}
		catch{
			print(error.localizedDescription)
		}
	}
}


class MachinesTableViewCell : UITableViewCell{
	@IBOutlet weak var machine_name: UILabel!
	@IBOutlet weak var machine_type: UILabel!
	
}
