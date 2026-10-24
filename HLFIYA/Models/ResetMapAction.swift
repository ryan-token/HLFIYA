//
//  ResetMapAction.swift
//  HLFIYA
//

import MapKit
import SwiftUI

/// Recenters a map on the person's current location at the default search radius.
struct ResetMapAction {
    @Binding var position: MapCameraPosition

    func callAsFunction(location: CLLocation?) {
        guard let location else { return }
        let degrees = MapView.degrees(forRadius: FiltersState.defaultRadius)
        position = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: degrees, longitudeDelta: degrees)
            )
        )
    }
}
