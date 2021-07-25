//
//  ScannerViewController.swift
//  Image Machine
//
//  Created by Ridoan Wibisono on 25/07/21.
//

import AVFoundation
import UIKit
import CoreData

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!
	
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	private var mData : [MachineEntity] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.black
		captureSession = AVCaptureSession()
		
		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput
		
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}
		
		if (captureSession.canAddInput(videoInput)) {
			captureSession.addInput(videoInput)
		} else {
			failed()
			return
		}
		
		let metadataOutput = AVCaptureMetadataOutput()
		
		if (captureSession.canAddOutput(metadataOutput)) {
			captureSession.addOutput(metadataOutput)
			
			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = [.qr]
		} else {
			failed()
			return
		}
		
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)
		
		captureSession.startRunning()
	}
	
	func failed() {
		let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
		captureSession = nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if (captureSession?.isRunning == false) {
			captureSession.startRunning()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (captureSession?.isRunning == true) {
			captureSession.stopRunning()
		}
	}
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		captureSession.stopRunning()
		
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			found(code: stringValue)
		}
		
		dismiss(animated: true)
	}
	
	func found(code: String) {
		print(code)
		
		let fetchRequest: NSFetchRequest<MachineEntity>
		fetchRequest = MachineEntity.fetchRequest()
		
		fetchRequest.predicate = NSPredicate(
			format: "qrcode == %@", code
		)
		
		do{
			self.mData = try context.fetch(fetchRequest)
			performSegue(withIdentifier: "goDetail", sender: self)
		}
		catch{
			print(error.localizedDescription)
		}
		
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goDetail" {
			let viewController = segue.destination as! MachineDetailViewController
			
			viewController.passedValue = mData[0].id.uuidString
		}
		
	}
}
