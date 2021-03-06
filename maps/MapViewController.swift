//
//  MapViewController.swift
//  maps
//
//  Created by Mihir Thanekar on 7/9/17.
//  Copyright © 2017 Mihir Thanekar. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func logout(_ sender: Any) {
        NetworkRequests.deleteSession()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard StudentInformation.shouldReloadData else {   // Only reload map pins when we need to
            return
        }
        
        NetworkRequests.reloadData(err: {errorString in
            self.displayError(title: "Pin loading error", message: errorString)
        }, completion: {
            for pinInfo in model.allStudentsInfo {
                //print(pinInfo.name, pinInfo.link)
                let annot = MKPointAnnotation()
                
                annot.title = pinInfo.name
                annot.subtitle = pinInfo.link
                annot.coordinate = pinInfo.location
                
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annot)
                }
                
            }
            StudentInformation.shouldReloadData = false
        
        })
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.rightCalloutAccessoryView = UIButton(type: .infoLight)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let linkString = view.annotation?.subtitle as? String, !linkString.isEmpty else {
            self.secondaryError(message: "Empty URL")
            return
        }
        let link = URL(string: linkString)!
        guard UIApplication.shared.canOpenURL(link) else {
            self.secondaryError(message: "Invalid URL format")
            return
        }
        UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
}
