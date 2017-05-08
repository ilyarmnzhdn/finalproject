//
//  TimeframeViewController.swift
//
//  Created by Ilyar Mnazhdin on 08/05/2017.
//  Copyright © 2017 Ilyar Mnazhdin. All rights reserved.
//

import UIKit

protocol TimeFrameDelegate {
    func didSelectRange(range: GLCalendarDateRange)
}

class TimeframeViewController: UIViewController, GLCalendarViewDelegate {

    //@IBOutlet weak var calendarView: GLCalendarView!
    lazy var calendarView: GLCalendarView = {
        let view = GLCalendarView()
        view.backgroundColor = .purple
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = topBarBackgroundColor
        return view
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "done_button").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDonePressed), for: .touchUpInside)
        return button
    }()
    
    var timeFrame:GLCalendarDateRange? = nil
    
    var timeFrameDelegate: TimeFrameDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        calendarView.delegate = self
        
        GLCalendarView.appearance().rowHeight = 54
        GLCalendarView.appearance().padding = 6
    }
    
    fileprivate func setupViews() {
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        containerView.addSubview(topView)
        topView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
        topView.addSubview(doneButton)
        doneButton.anchor(top: topView.topAnchor, left: nil, bottom: nil, right: topView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 40)
        
        containerView.addSubview(calendarView)
        calendarView.anchor(top: topView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let today = Date()
        let beginDate = GLDateUtils.date(byAddingDays: 0, to: today as Date!)
        let endDate = GLDateUtils.date(byAddingDays: 7, to: today as Date!)
        
        let range = GLCalendarDateRange(begin: beginDate, end: endDate)
        range?.backgroundColor = UIColor.lightGray
        range?.editable = true
        calendarView.ranges = [range!]
        
        calendarView.reload()
        
        DispatchQueue.main.async { 
            self.calendarView.scroll(to: self.calendarView.lastDate, animated: false)
        }
    }
    
    func handleDonePressed() {
        if let selectedTimeFrame = timeFrame {
            if timeFrameDelegate != nil {
                timeFrameDelegate?.didSelectRange(range: selectedTimeFrame)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func calenderView(_ calendarView: GLCalendarView!, canAddRangeWithBegin beginDate: Date!) -> Bool {
            return true
    }
    
    func calenderView(_ calendarView: GLCalendarView!, rangeToAddWithBegin beginDate: Date!) -> GLCalendarDateRange! {
        let endDate = GLDateUtils.date(byAddingDays: 0, to: beginDate)
        let range = GLCalendarDateRange(begin: beginDate, end: endDate)
        range?.backgroundColor = UIColor.lightGray
        range?.editable = true
        
        return range
        
    }
    
    func calenderView(_ calendarView: GLCalendarView!, canUpdate range: GLCalendarDateRange!, toBegin beginDate: Date!, end endDate: Date!) -> Bool {
        return true
    }
    
    func calenderView(_ calendarView: GLCalendarView!, beginToEdit range: GLCalendarDateRange!) {
        
    }
    
    func calenderView(_ calendarView: GLCalendarView!, finishEdit range: GLCalendarDateRange!, continueEditing: Bool) {
        
    }
    
    func calenderView(_ calendarView: GLCalendarView!, didUpdate range: GLCalendarDateRange!, toBegin beginDate: Date!, end endDate: Date!) {
        timeFrame = range
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
