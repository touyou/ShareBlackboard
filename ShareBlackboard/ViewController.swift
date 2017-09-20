//
//  ViewController.swift
//  ShareBlackboard
//
//  Created by 藤井陽介 on 2016/08/07.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import NXDrawKit
import MultipeerConnectivity

final class ViewController: UIViewController {
    // MARK: NXDrawKit
    weak var canvasView: Canvas?
    var currentImage: UIImage?

    // MARK: Multipeer Connectivity
    let serviceType = "ShareBlackboard"
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // MultipeerConnectivity
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        assistant.start()
        let imageView: UIImageView = UIImageView()
        imageView.frame
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // NXDrawKit
        let canvasView = Canvas(canvasId: "blackboard", backgroundImage: UIImage.colorImage(UIColor(red: 60/255, green: 100/255, blue: 80/255, alpha: 1.0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height)))
        canvasView.delegate = self
        //        canvasView.layer.backgroundColor = UIColor(red: 60/255, green: 100/255, blue: 80/255, alpha: 1.0).CGColor
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
        self.canvasView?.snp_makeConstraints(closure: { (make) in
            make.top.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.left.equalTo(self.view).offset(0)
            make.height.equalTo(CGRectGetHeight(self.view.frame) - 40)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func undoBtn() {
        self.canvasView?.undo()
    }

    @IBAction func redoBtn() {
        self.canvasView?.redo()
    }

    @IBAction func saveBtn() {
        self.canvasView?.save()
    }

    @IBAction func connectBtn() {
        presentViewController(browser, animated: true, completion: nil)
    }
}

// MARK: - CanvasDelegate
extension ViewController: CanvasDelegate {
    func brush() -> Brush? {
        let defaultBrush = Brush()
        defaultBrush.alpha = 1.0
        defaultBrush.color = UIColor.whiteColor()
        defaultBrush.width = 10.0
        return defaultBrush
    }

    func canvas(canvas: Canvas, didSavePaper paper: Paper, mergedImage image: UIImage?) {
//        if let pngImage = image {
//            UIImageWriteToSavedPhotosAlbum(pngImage, self, nil, nil)
//        }
        if let sendImage = image {
            let sendData = UIImagePNGRepresentation(sendImage) ?? NSData()
            do {
                try session.sendData(sendData, toPeers: session.connectedPeers, withMode: .Unreliable)
            } catch let error as NSError {
                print("Error sending data: \(error.localizedDescription)")
            }
        }
    }

    func canvas(canvas: Canvas, didUpdatePaper paper: Paper, mergedImage image: UIImage?) {

    }
}

// MARK: - MCBrowserViewControllerDelegate
extension ViewController: MCBrowserViewControllerDelegate {
    // MARK: 完了が押された時
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: キャンセルが押された時
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - MCSessionDelegate
extension ViewController: MCSessionDelegate {
    // MARK: データを受信した時
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        dispatch_sync(dispatch_get_main_queue()) {
            let image = UIImage(data: data)
            self.canvasView?.update(image)
        }
    }

    // MARK: データを受信し始めた時
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }

    // MARK: データを受信し終わった時
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
    }

    // MARK: ストリームが確立ci された時
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    // MARK: 他のpeerの状態が変化した時
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
}
