//
//  CourseProblemTableViewCell.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 14/05/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

class CourseProblemTableViewCell: UITableViewCell {

    static let identifier = "CourseProblemTableViewCellIdentifier"
    
    var fontStyle = OEXTextStyle(font: OEXTextFont.ThemeSans, size: 15.0)
    var leftImageButton = UIButton()
    var titleLabel = UILabel()
    var block : CourseBlock? = nil {
        didSet {
            titleLabel.text = block?.name ?? ""
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setStyles()
        setConstraints()
    }
    
    //MARK: Helper Methods
    
    private func addSubviews() {
        addSubview(leftImageButton)
        addSubview(titleLabel)
    }
    
    private func setStyles() {
        fontStyle.applyToLabel(titleLabel)
        
        leftImageButton.titleLabel?.font = UIFont.fontAwesomeOfSize(13)
        leftImageButton.setTitle(String.fontAwesomeIconWithName(.ThList), forState: .Normal)
        leftImageButton.setTitleColor(OEXStyles.sharedStyles()?.primaryBaseColor(), forState: .Normal)
    }
    
    private func setConstraints() {
        leftImageButton.snp_makeConstraints { (make) -> Void in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSizeMake(25, 25))
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self).offset(-5)
            make.leading.equalTo(leftImageButton).offset(40)
            make.trailing.equalTo(self.snp_trailing).offset(10)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}