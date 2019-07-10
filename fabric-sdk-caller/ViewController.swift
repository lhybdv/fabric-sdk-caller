//
//  ViewController.swift
//  fabric-sdk-caller
//
//  Created by liuhuiyu on 2019/6/5.
//  Copyright © 2019 liuhuiyu. All rights reserved.
//

import Cocoa
import SwiftGRPC
import AppKit

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    private var service: Grpc_SDKServiceClient?
    private var chainCodeInfos: [Grpc_ChainCodeInfo]?

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var queryAccount: NSTextField!
    @IBOutlet weak var createAccount: NSTextFieldCell!
    @IBOutlet weak var createAmount: NSTextField!
    @IBOutlet weak var txFrom: NSTextField!
    @IBOutlet weak var txTo: NSTextField!
    @IBOutlet weak var txAmount: NSTextField!
    @IBOutlet weak var transactionId: NSTextFieldCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func queryInstantiated(_ sender: NSButton) {
        run() {
            let req = Grpc_Empty()
            try service?.queryInstantiated(req) { resp, callRst in
                self.handleChainCodes(resp: resp)
            }
        }
    }

    @IBAction func queryInstalled(_ sender: NSButton) {
        run() {
            let req = Grpc_Empty()
            try service?.queryInstalled(req) { resp, callRst in
                self.handleChainCodes(resp: resp)
            }
        }
    }

    @IBAction func query(_ sender: NSButton) {
        run() {
            var req = Grpc_QueryRequest()
            req.account = queryAccount.stringValue
            try service?.query(req) { resp, callRst in
                self.showTestResult(stringVar: resp?.result)
            }
        }
    }

    @IBAction func create(_ sender: NSButton) {
        run() {
            var req = Grpc_CreateRequest()
            req.account = createAccount.stringValue
            req.amount = createAmount.stringValue
            try service?.create(req) { resp, callRst in
                self.showTestResult(stringVar: resp?.result)
            }
        }
    }

    @IBAction func transfer(_ sender: NSButton) {
        run() {
            var req = Grpc_TransferRequest()
            req.from = txFrom.stringValue
            req.to = txTo.stringValue
            req.amount = txAmount.stringValue
            try service?.transfer(req) { resp, callRst in
                self.showTestResult(stringVar: resp?.result)
            }
        }
    }

    @IBAction func queryById(_ sender: NSButton) {

    }

    @IBAction func upgradeOrg1234(_ sender: NSButton) {
        run() {
            try upgrade(nodes: "[[14311, '54.255.239.58'], [10665, '13.229.49.131'], [7988, '54.179.169.147'], [7281, '52.77.242.99']]")
        }
    }

    @IBAction func upgradeOrg123(_ sender: NSButton) {
        run() {
            try upgrade(nodes: "[[14311, '54.255.239.58'], [10665, '13.229.49.131'], [7988, '54.179.169.147']]")
        }
    }

    func prepareService() {
        if service != nil {
            return
        }

        service = Grpc_SDKServiceClient(address: "localhost:50051", secure: false)
        service?.host = "localhost"
    }

    func run(fn: () throws -> Void) {
        do {
            prepareService()
            try fn()
        } catch {
            let alert = NSAlert()
            alert.messageText = "\(error)"
            alert.beginSheetModal(for: self.view.window!)
        }
    }

    func handleChainCodes(resp: Grpc_QueryChainCodeResponse?) -> Void {
        DispatchQueue.main.async {
            if resp?.chainCodeInfos.count == 0 {
                let alert = NSAlert()
                alert.messageText = "found nothing"
                alert.beginSheetModal(for: self.view.window!)
            } else {
                self.chainCodeInfos = resp?.chainCodeInfos
                self.tableView.reloadData()
            }
        }
    }

    func showTestResult(stringVar: String?) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            if let rst = stringVar {
                alert.messageText = rst
            } else {
                alert.messageText = "found nothing"
            }
            alert.beginSheetModal(for: self.view.window!)
        }
    }

    func upgrade(nodes: String) throws -> Void {
        var req = Grpc_UpgradeChainCodeRequest()
        req.nodes = nodes
        try service?.upgrade(req) { resp, callRst in
            let alert = NSAlert()
            let messageText = """
                              version: \(resp?.version)
                              policy: \(resp?.policy)
                              """
            alert.messageText = messageText
            alert.beginSheetModal(for: self.view.window!)
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if let count = self.chainCodeInfos?.count {
            return count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let chainCodeInfo = self.chainCodeInfos?[row]
        if tableColumn?.title == "Org" {
            return chainCodeInfo?.org
        } else if tableColumn?.title == "Name" {
            return chainCodeInfo?.name
        } else {
            return chainCodeInfo?.version
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let textField = NSTextField()
        return textField
    }
}

