//
//  TokenListViewController.swift
//  Authenticator
//
//  Copyright (c) 2013-2015 Authenticator authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import SVProgressHUD

class TokenListViewController: UITableViewController {
    private weak var actionHandler: TokenListActionHandler?
    private var viewModel: TokenListViewModel
    private var preventTableViewAnimations = false

    init(viewModel: TokenListViewModel, actionHandler: TokenListActionHandler) {
        self.viewModel = viewModel
        self.actionHandler = actionHandler
        super.init(style: .Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var displayLink: CADisplayLink?
    private let ring: OTPProgressRing = OTPProgressRing(frame: CGRectMake(0, 0, 22, 22))
    private lazy var noTokensLabel: UILabel = {
        let noTokenString = NSMutableAttributedString(string: "No Tokens\n",
            attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!])
        noTokenString.appendAttributedString(NSAttributedString(string: "Tap + to add a new token",
            attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 17)!]))
        noTokenString.addAttributes(
            [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 25)!],
            range: (noTokenString.string as NSString).rangeOfString("+"))

        let label = UILabel()
        label.numberOfLines = 2
        label.attributedText = noTokenString
        label.textAlignment = .Center
        label.textColor = UIColor.otpForegroundColor
        return label
    }()

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Authenticator"
        self.view.backgroundColor = UIColor.otpBackgroundColor

        // Configure table view
        self.tableView.separatorStyle = .None
        self.tableView.indicatorStyle = .White
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.tableView.allowsSelectionDuringEditing = true

        // Configure navigation bar
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.ring)

        // Configure toolbar
        self.toolbarItems = [
            self.editButtonItem(),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addToken"))
        ]
        self.navigationController?.toolbarHidden = false

        // Configure "no tokens" label
        self.noTokensLabel.frame = CGRectMake(0, 0,
            self.view.bounds.size.width,
            self.view.bounds.size.height * 0.6)
        self.view.addSubview(self.noTokensLabel)

        // Update with current viewModel
        self.updatePeripheralViews()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.displayLink = CADisplayLink(target: self, selector: Selector("tick"))
        self.displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.editing = false
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.displayLink?.invalidate()
        self.displayLink = nil
    }

    // MARK: Target Actions

    func tick() {
        // Update currently-visible cells
        actionHandler?.handleAction(.UpdateViewModel)

        if let period = viewModel.ringPeriod where period > 0 {
            self.ring.progress = fmod(NSDate().timeIntervalSince1970, period) / period
        } else {
            self.ring.progress = 0
        }
    }

    func addToken() {
        actionHandler?.handleAction(.BeginAddToken)
    }
}

// MARK: UITableViewDataSource
extension TokenListViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowModels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithClass(TokenRowCell.self)
        updateCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }

    private func updateCell(cell: TokenRowCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let rowModel = viewModel.rowModels[indexPath.row]
        cell.updateWithRowModel(rowModel)
        cell.delegate = self
    }

    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            actionHandler?.handleAction(.DeleteTokenAtIndex(indexPath.row))
        }
    }

    override func tableView(tableView: UITableView,
        moveRowAtIndexPath sourceIndexPath: NSIndexPath,
        toIndexPath destinationIndexPath: NSIndexPath)
    {
        preventTableViewAnimations = true
        actionHandler?.handleAction(.MoveToken(fromIndex: sourceIndexPath.row,
            toIndex: destinationIndexPath.row))
        preventTableViewAnimations = false
    }

}

// MARK: UITableViewDelegate
extension TokenListViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat
    {
        return 85
    }
}

// MARK: TokenRowDelegate
extension TokenListViewController: TokenRowDelegate {
    func handleAction(action: TokenRowModel.Action) {
        switch action {
        case .UpdatePersistentToken(let persistentToken):
            actionHandler?.handleAction(.UpdatePersistentToken(persistentToken))
        case .CopyPassword(let password):
            actionHandler?.handleAction(.CopyPassword(password))
        case .EditPersistentToken(let persistentToken):
            actionHandler?.handleAction(.BeginEditPersistentToken(persistentToken))
        }
    }
}

// MARK: TokenListPresenter
extension TokenListViewController: TokenListPresenter {
    func updateWithViewModel(viewModel: TokenListViewModel, ephemeralMessage: EphemeralMessage?) {
        let changes = changesFrom(self.viewModel.rowModels, to: viewModel.rowModels)
        self.viewModel = viewModel
        updateTableViewWithChanges(changes)
        updatePeripheralViews()
        // Show ephemeral message
        if let ephemeralMessage = ephemeralMessage {
            switch ephemeralMessage {
            case .Success(let message):
                SVProgressHUD.showSuccessWithStatus(message)
            case .Error(let message):
                SVProgressHUD.showErrorWithStatus(message)
            }
        }
    }

    private func updateTableViewWithChanges(changes: [Change]) {
        if preventTableViewAnimations {
            return
        }

        tableView.beginUpdates()
        let sectionIndex = 0
        for change in changes {
            switch change {
            case .Insert(let rowIndex):
                let indexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case let .Update(rowIndex, _):
                let indexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TokenRowCell {
                    updateCell(cell, forRowAtIndexPath: indexPath)
                } else {
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            case .Delete(let rowIndex):
                let indexPath = NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case let .Move(fromRowIndex, toRowIndex):
                let origin = NSIndexPath(forRow: fromRowIndex, inSection: sectionIndex)
                let destination = NSIndexPath(forRow: toRowIndex, inSection: sectionIndex)
                tableView.moveRowAtIndexPath(origin, toIndexPath: destination)
            }
        }
        tableView.endUpdates()
    }

    private func updatePeripheralViews() {
        // Show the countdown ring only if a time-based token is active
        self.ring.hidden = (viewModel.ringPeriod == nil)

        let hasTokens = !viewModel.rowModels.isEmpty
        editButtonItem().enabled = hasTokens
        noTokensLabel.hidden = hasTokens

        // Exit editing mode if no tokens remain
        if self.editing && viewModel.rowModels.isEmpty {
            self.setEditing(false, animated: true)
        }
    }
}