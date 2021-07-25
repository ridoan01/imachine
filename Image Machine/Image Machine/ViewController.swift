//
//  ViewController.swift
//  Image Machine
//
//  Created by Ridoan Wibisono on 24/07/21.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var trailing: NSLayoutConstraint!
	@IBOutlet weak var leading: NSLayoutConstraint!
	
	var menuOut = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		//		for i in machines{
		//			print(i.id)
		//		}
	}
	@IBAction func menuTapped(_ sender: Any) {
		print("tapped menu")
		
		menuVisibility(vis: menuOut)
	}
	
	private func menuVisibility(vis: Bool){
		if menuOut == false{
			leading.constant = 150
			trailing.constant = -150
			menuOut = true
		}else{
			leading.constant = 0
			trailing.constant = 0
			menuOut = false
		}
		UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: self.view.layoutIfNeeded) { Bool in
			print("")
		}
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		menuOut = true
		menuVisibility(vis: menuOut)
		
	}
}

