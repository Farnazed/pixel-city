//
//  MapVc.swift
//  pixel-city
//
//  Created by farnaz on 2019-10-15.
//  Copyright © 2019 farnaz. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage


class MapVc: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pullUpViewHightConstrant: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var locationManager = CLLocationManager()
    var progressLable : UILabel?
    var screenSize = UIScreen.main.bounds
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?

    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 0.04
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationService()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addProgressLable(){
        progressLable = UILabel()
        progressLable?.frame = CGRect(x: (screenSize.width)/2-120, y: 175, width: 240, height: 40)
        progressLable?.font = UIFont(name: "Avenir Next", size: 17)
        progressLable?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLable?.textAlignment = .center
        pullUpView.addSubview(progressLable!)
    }
    
    func removeProgressLable(){
        if progressLable != nil{
            progressLable?.removeFromSuperview()
        }
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
   
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe(){
        cancellAllSessions()
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullUpViewHightConstrant.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
   @objc func animateViewDown(){
        pullUpViewHightConstrant.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func retriveUrls(forAnnotation annotation : DroppablePin, handler : @escaping(_ status : Bool)->()){
           
           Alamofire.request(flickUrl(forapiKey: apiKey, withAnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
               guard let json = response.result.value as? Dictionary<String, AnyObject> else{return}
               let photosDic = json["photos"] as! Dictionary<String, AnyObject>
               let photoDicArray = photosDic["photo"] as! [Dictionary<String, AnyObject>]
               for photo in photoDicArray{
                 //  let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                   let postUrl = "https://live.staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                   self.imageUrlArray.append(postUrl)
               }//https://live.staticflickr.com/3943/15764107365_66f7dba563_c_d.jpg
               handler(true)
           }
           
       }
    
    func retrieveImages(handler: @escaping (_ status: Bool)->()){
       
        for url in imageUrlArray{
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLable?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
              //  print("\(self.imageArray.count)/40 IMAGES DOWNLOADED")
                if self.imageArray.count == self.imageUrlArray.count{
                    handler(true)
                }
            }
        }
    }
    
    func cancellAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask , uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
}

extension MapVc : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pin.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        pin.animatesDrop = true
        
        return pin
    }
    
    func centerMapOnUserLocation(){
        guard let cordinate = locationManager.location?.coordinate else{return}
        let cordinateRegion = MKCoordinateRegion(center: cordinate, span: MKCoordinateSpan(latitudeDelta: regionRadius, longitudeDelta: regionRadius))
        mapView.setRegion(cordinateRegion, animated: true)
    }
    @objc func dropPin(sender : UITapGestureRecognizer){
        removePin()
        removeProgressLable()
        cancellAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addProgressLable()
        spinner.isHidden = false
        spinner.startAnimating()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
      //  print(flickUrl(forapiKey: apiKey, withAnotation: annotation, andNumberOfPhotos: 40))
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, span: MKCoordinateSpan(latitudeDelta: regionRadius, longitudeDelta: regionRadius))
        mapView.setRegion(coordinateRegion, animated: true)
        
        retriveUrls(forAnnotation: annotation) { (finished) in
            if finished{
                self.retrieveImages { (finished) in
                    if finished{
                       
                        self.spinner.stopAnimating()
                        self.removeProgressLable()
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
        
    }
}

extension MapVc : CLLocationManagerDelegate{
    func configureLocationService(){
        if authorizationStatus == .notDetermined{
            locationManager.requestLocation()
        }else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
    
}






extension MapVc : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell()}
        let imageAtIndex = imageArray[indexPath.row]
        let imageview = UIImageView(image: imageAtIndex)
        cell.addSubview(imageview)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{return}
        
        popVc.initData(forImage: imageArray[indexPath.row])
        present(popVc, animated: true, completion: nil)
        
    }
    
    
}


