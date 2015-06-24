//
//  DownloadProgressViewTests.swift
//  edX
//
//  Created by Akiva Leffert on 6/3/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import edX
import Foundation

class CourseOutlineHeaderViewTests : SnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        recordMode = true
    }
    
    func testProgressView() {
        let progressView = CourseOutlineHeaderView(frame: CGRectZero, styles: OEXStyles(), titleText: OEXLocalizedString("VIDEO_DOWNLOADS_IN_PROGRESS", nil), shouldShowSpinner: true)
        
        CourseOutlineHeaderView(frame : CGRectZero, styles : OEXStyles(), shouldShowSpinner : true)
        
        let size = progressView.systemLayoutSizeFittingSize(self.screenSize)
        progressView.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        progressView.layoutIfNeeded()
        assertSnapshotValidWithContent(progressView)
    }
    
    func testLastAccessedView() {
        let lastAccessedView = CourseOutlineHeaderView(frame: CGRectZero, styles: OEXStyles(), titleText: OEXLocalizedString("LAST_ACCESSED", nil), subtitleText : "This is a very long subtitle which should not overlap the button")
        
        CourseOutlineHeaderView(frame : CGRectZero, styles : OEXStyles(), shouldShowSpinner : true)
        
        let size = lastAccessedView.systemLayoutSizeFittingSize(self.screenSize)
        // Using 380 to make sure that the subtitle truncates
        lastAccessedView.bounds = CGRect(x: 0, y: 0, width: 380, height: size.height)
        
        lastAccessedView.layoutIfNeeded()
        assertSnapshotValidWithContent(lastAccessedView)

    }
}