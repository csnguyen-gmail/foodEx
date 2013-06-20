//
//  GMDraggableMarkerManager.m
//  GoogleMapsDragAndDrop
//
//  Created by Stephen Trainor on 5/30/13.
//
//

#import "GMDraggableMarkerManager.h"

// Determines the distance between touch point and position of the marker.
#define MARKER_TOUCH_DISTANCE 60.0f

// Determines distance the marker jumps at the end of the drag gesture.
#define MARKER_DROP_JUMP_DISTANCE 25.0f

@interface GMDraggableMarkerManager()

@property (nonatomic, weak) id<GMDraggableMarkerManagerDelegate> delegate;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) UIImageView *markerImageView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (assign, nonatomic, readwrite) CLLocationCoordinate2D initialMarkerPosition;
@property (assign, nonatomic, readwrite) BOOL didDragMarker;
@property (assign, nonatomic, readwrite) BOOL didTapMarker;

@property (nonatomic, strong) NSMutableSet *markers;

- (GMSMarker *) determineClosestMarkerForTouchPoint:(CGPoint)touchPoint;
- (void) reset;
- (UIImageView *) imageViewForMarker:(GMSMarker *)marker;

@end

@implementation GMDraggableMarkerManager {
    
    CGRect _markerHitRect;
}

- (id) initWithMapView:(GMSMapView *)mapView delegate:(id<GMDraggableMarkerManagerDelegate>)delegate {
    
    self = [super init];
    if (self) {
        _delegate = delegate;
        _mapView = mapView;
        
        // Add a custom long press gesture recognizer to the map.
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _longPressGesture.minimumPressDuration = 0.4f;
        [_mapView addGestureRecognizer:_longPressGesture];
        
        _markers = [NSMutableSet setWithCapacity:5];
    }
    
    return self;
}


- (void) addDraggableMarker:(GMSMarker *)marker {
    
    [self.markers addObject:marker];
}


- (void) removeDraggableMarker:(GMSMarker *)marker {
    
    [self.markers removeObject:marker];
}

- (void) removeAllDraggableMarkers {
 
    [self.markers removeAllObjects];
}

- (NSArray *) draggableMarkers {
    
    return [self.markers allObjects];
}

#pragma mark - Public properties

- (void) setMapView:(GMSMapView *)mapView {
    
    if (mapView != _mapView) {
        // remove the current gesture recognizer
        [_mapView removeGestureRecognizer:_longPressGesture];
        
        // different map view, so clear existing draggable markers
        [self removeAllDraggableMarkers];
        
        _mapView = mapView;
        
        // Add the gesture recognizer to the new map view
        [_mapView addGestureRecognizer:_longPressGesture];
    }
}

#pragma mark - Gesture Reconizer.
- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)recognizer {
    
    // Extract the touch point on the GoogleMaps view.
    CGPoint touchPoint = [recognizer locationInView:self.mapView];
    
    // Before the rect can be created the closest marker to the touch point must be determined.
    if (UIGestureRecognizerStateBegan == recognizer.state)
    {
        // CUSTOMIZE
        if (self.markers.count == 0) {
            [self.delegate onMarkerEmptyDragStartAt:[self.mapView.projection coordinateForPoint:touchPoint]];
            return;
        }
        self.marker = [self determineClosestMarkerForTouchPoint:touchPoint];
        
        self.markerImageView = [self imageViewForMarker:self.marker];
        // rect used to determine if user actually touched the closest marker
        _markerHitRect = self.markerImageView.frame;
        
        // Deselect the marker if it is not the selected one.
        if (self.mapView.selectedMarker != self.marker) {
            
            self.mapView.selectedMarker = nil;
        }
    }
    
    // Check if a marker could be determined
    if (nil != self.marker)
    {

        CGPoint markerPoint = [self.mapView.projection pointForCoordinate:self.marker.position];
         
        // In the UIGestureRecognizerStateBegan there must be a check if there was a long press on the marker.
        if (UIGestureRecognizerStateBegan == recognizer.state)
        {
            // Check if touch point is in the rect.
            if (CGRectContainsPoint(_markerHitRect, touchPoint))
            {
                // Disable the gestures of the GoogleMaps view for UIX.
                [self enableGoogleMapViewSettings:NO];
                
                // Reset the control properties.
                self.didTapMarker = YES;
                self.didDragMarker = NO;
                
                // Save the initial marker position.
                self.initialMarkerPosition = self.marker.position;
                
                [self.mapView addSubview:self.markerImageView];
                self.marker.map = nil;
                
                __block GMSMarker *myMarker = self.marker;
                
                CGRect newFrame = self.markerImageView.frame;
                newFrame.origin.y -= (markerPoint.y - touchPoint.y) + MARKER_TOUCH_DISTANCE;
                [UIView animateWithDuration:0.5 animations:^{
                    self.markerImageView.frame = newFrame;
                } completion:^(BOOL finished) {
                    
                    // Notify delegate of drag event at end of initial animation
                    if ([self.delegate respondsToSelector:@selector(onMarkerDragStart:)])
                        [self.delegate onMarkerDragStart:myMarker];
                    
                }];

            } else {
                // No marker was hit so deselect the current marker and restore the default state.
                self.mapView.selectedMarker = nil;
                [self reset];
            }
        }
        else if (UIGestureRecognizerStateChanged == recognizer.state) {
            
            // Check if the marker was long pressed before.
            if (self.didTapMarker)
            {
                // The user started to drag the marker, so there is no longer any intention to restore the old state.
                if (!CGRectContainsPoint(self.markerImageView.frame, touchPoint) && NO == self.didDragMarker) {
                    // The marker was dragged.
                    self.didDragMarker = YES;
                }
                
                // Move the image view to the correct position for the updated touch point
                CGSize imgSize = self.markerImageView.image.size;
                self.markerImageView.frame = CGRectMake(touchPoint.x - (self.marker.groundAnchor.x * imgSize.width), touchPoint.y - (self.marker.groundAnchor.y * imgSize.height) - MARKER_TOUCH_DISTANCE, imgSize.width, imgSize.height);
                
                // Notify delegate of drag event
                if ([self.delegate respondsToSelector:@selector(onMarkerDrag:)])
                    [self.delegate onMarkerDrag:self.marker];

            }
        }
        else if (UIGestureRecognizerStateEnded == recognizer.state)
        {
            // Only store the new position of the marker if there was a drag action.
            if (!self.didDragMarker) {
                // Restore the old position.
                self.marker.position = self.initialMarkerPosition;
            }
            
            __block GMSMarker *myMarker = self.marker;            
            
            __block CGRect newFrame = self.markerImageView.frame;
            newFrame.origin.y -= MARKER_DROP_JUMP_DISTANCE;
            [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                // Make the jump up...
                self.markerImageView.frame = newFrame;
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.10 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    newFrame.origin.y += MARKER_DROP_JUMP_DISTANCE;
                    // ...and land again
                    self.markerImageView.frame = newFrame;
                } completion:^(BOOL finished) {
                    
                    // Finally, update the position of the marker we are dragging
                    CGSize imgSize = self.markerImageView.image.size;
                    CGPoint newMarkerOrigin = CGPointMake(newFrame.origin.x + (self.marker.groundAnchor.x * imgSize.width), newFrame.origin.y + (self.marker.groundAnchor.y * imgSize.height));
                    CLLocationCoordinate2D newMarkerCoordinate = [self.mapView.projection coordinateForPoint:newMarkerOrigin];
                    myMarker.position = newMarkerCoordinate;

                    // And add it back on the map
                    myMarker.map = self.mapView;
                    
                    // remove the imageview
                    [self.markerImageView removeFromSuperview];
                    
                    // notify delegate before we reset
                    if ([self.delegate respondsToSelector:@selector(onMarkerDragEnd:)])
                        [self.delegate onMarkerDragEnd:self.marker];
                    
                    [self reset];
                }];
            }];
            
        } else {
            [self reset];
        }
    }
}

#pragma mark - Map Control

// Enables or disables all GoogleMap View Settings.
- (void)enableGoogleMapViewSettings:(BOOL)enable {

    if (enable) {
        self.mapView.settings.scrollGestures = YES;
        self.mapView.settings.zoomGestures = YES;
        self.mapView.settings.tiltGestures = YES;
        self.mapView.settings.rotateGestures = YES;
    } else {
        self.mapView.settings.scrollGestures = NO;
        self.mapView.settings.zoomGestures = NO;
        self.mapView.settings.tiltGestures = NO;
        self.mapView.settings.rotateGestures = NO;
    }
}

#pragma mark - Helper methods
// Determines the closest marker
- (GMSMarker *)determineClosestMarkerForTouchPoint:(CGPoint)touchPoint {
    
    // Initialize the return value.
    GMSMarker *resultMarker = nil;
    
    // Initialize the initial distance as the maximum of CGFloat.
    CGFloat smallestDistance = CGFLOAT_MAX;
    CGFloat distance = CGFLOAT_MAX;
    
    // Determine the closest draggable marker to the current touch point
    for (GMSMarker *marker in self.markers)
    {
        CGPoint markerPoint = [self.mapView.projection pointForCoordinate:marker.position];
        CGFloat xDist = (touchPoint.x - markerPoint.x);
        CGFloat yDist = (touchPoint.y - markerPoint.y);
        distance = sqrt((xDist * xDist) + (yDist * yDist));
        
        // Check if a closer marker was found.
        if (distance <= smallestDistance){
            
            resultMarker = marker;
            smallestDistance = distance;
        }
    }
    return resultMarker;
}

// Reset state
- (void)reset {
    
//    NSLog(@"GMDraggableMarkerManager reset");
    
    if (self.markerImageView)
        [self.markerImageView removeFromSuperview];
    
    self.markerImageView = nil;
    
    // Reset the control properties.
    self.didTapMarker = NO;
    self.didDragMarker = NO;
    
    // Enable the gestures of the GoogleMaps view for UIX.
    [self enableGoogleMapViewSettings:YES];
    
    // Marker is no longer selected.
    self.marker = nil;
}

- (UIImageView *) imageViewForMarker:(GMSMarker *)marker {
    
    CGPoint markerPoint = [self.mapView.projection pointForCoordinate:marker.position];
    
    // get the image used by the marker
    UIImage *img;
    if (self.marker.icon)
        img = self.marker.icon;
    else // if icon property is null, marker is using the default marker image supplied in the Google Maps bundle
        img = [UIImage imageNamed:@"GoogleMaps.bundle/default_marker"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    imageView.frame = CGRectMake(markerPoint.x - (self.marker.groundAnchor.x * img.size.width), markerPoint.y - (self.marker.groundAnchor.y * img.size.height), img.size.width, img.size.height);

    return imageView;
}
@end
