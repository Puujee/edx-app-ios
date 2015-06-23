//
//  OEXLoginViewControllerTests.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 23/06/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit
import XCTest

class OEXLoginViewControllerTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = true
    }
    
    func testSnapshot() {
        let controller = UIStoryboard(name: "OEXLoginViewController", bundle: nil).instantiateViewControllerWithIdentifier("LoginView") as! OEXLoginViewController
        inScreenDisplayContext(controller, action: { () -> () in
            assertSnapshotValidWithContent(controller)
        })
    }
}
