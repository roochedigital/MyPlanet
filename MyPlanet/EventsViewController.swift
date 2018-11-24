//  Created by rjcristy on 2018/8/29.

import UIKit
import RxSwift

class EventsViewController : UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var daysLabel: UILabel!
    
    let events = Variable<[EOEvent]>([])
    let days = Variable<Int>(360)
    let filteredEvents = Variable<[EOEvent]>([])
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        events.asObservable().subscribe(onNext: {
            [weak self] _ in self?.tableView.reloadData()
        }).disposed(by: disposedBag)
        
        Observable.combineLatest(days.asObservable(), events.asObservable()) {
            (days, events) -> [EOEvent] in
            let maxInterval = TimeInterval(days * 24 * 3600)
            
            return events.filter { event in
                if let date = event.closeDate {
                    return abs(date.timeIntervalSinceNow) < maxInterval
                }
                
                return true
            }
        }.bind(to: filteredEvents)
        .disposed(by: disposedBag)
        
        filteredEvents.asObservable().subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposedBag)
        
        days.asObservable().distinctUntilChanged().subscribe(onNext: { [weak self] days in
            self?.daysLabel.text = "Last \(days) days"
        }).disposed(by: disposedBag)
    }
    
    @IBAction func sliderAction(slider: UISlider) {
        days.value = Int(slider.value)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        
        let event = filteredEvents.value[indexPath.row]
        
        cell.configure(event: event)
        
        return cell
    }
    
}
