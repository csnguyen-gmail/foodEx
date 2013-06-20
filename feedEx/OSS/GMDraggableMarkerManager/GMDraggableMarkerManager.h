//
//  GMDraggableMarkerManager.h
//  GoogleMapsDragAndDrop
//
//  Created by Stephen Trainor on 5/30/13.
//
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "GMDraggableMarkerManagerDelegate.h"

@interface GMDraggableMarkerManager : NSObject

- (id) initWithMapView:(GMSMapView *)mapView delegate:(id<GMDraggableMarkerManagerDelegate>)delegate;

- (void) addDraggableMarker:(GMSMarker *)marker;
- (void) removeDraggableMarker:(GMSMarker *)marker;
- (void) removeAllDraggableMarkers;

- (NSArray *) draggableMarkers;

@property (nonatomic, readonly, weak) GMSMapView *mapView;

@end
