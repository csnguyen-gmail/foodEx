//
//  Common.h
//  feedEx
//
//  Created by csnguyen on 7/1/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#ifndef feedEx_Common_h
#define feedEx_Common_h

#define SEPARATED_SORT_STR  @"-"
#define SEPARATED_TAG_STR  @", "
#define DIRECTION_STRING_LIST @[@"Ascending", @"Descending"]
#define PLACE_SORT_TYPE_STRING_DICT @{@"Name":@"name", @"Rating":@"rating", @"Most visited":@"timesCheckin", @"Created date":@"createdDate", @"Last checkin":@"lastTimeCheckin"}
#define FOOD_SORT_TYPE_STRING_DICT @{@"Name":@"name", @"Cost":@"cost", @"Is best":@"isBest", @"Created date":@"createdDate"}

#define THUMBNAIL_WIDTH 64
#define THUMBNAIL_HEIGHT 64
#define THUMBNAIL_SIZE CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)
#define NORMAL_WIDTH 240
#define NORMAL_HEIGHT 240
#define NORMAL_SIZE CGSizeMake(NORMAL_WIDTH, NORMAL_HEIGHT)

#define GMAP_LOCATION_OBSERVE_KEY @"myLocation"
#define GMAP_DEFAULT_ZOOM 15
#define HCM_LONGTITUDE  106.698333
#define HCM_LATITUDE    10.7730556
// Search tab
#define SEARCH_DISPLAY_TYPE_KEY @"SearchDispType"
#define SEARCH_DISPLAY_PLACE_TYPE 0
#define SEARCH_DISPLAY_FOOD_TYPE 1
// Mail
#define ATTACHED_FILENAME_FORMAT @"places_%@.fex"
#define ATTACHED_FILENAME_DATE_FORMAT @"yyyyMMddHHmmss"
#define ATTACHED_FILETYPE @"application/fex"
#define MAIL_SUBJECT @"Share Places in FoodEx application by CSNGuyen."
#define MAIL_BODY @"Share places:\n"
// Center notification
#define CORE_DATA_UPDATED @"CoreDataUpdated"
#define LOCATION_UPDATED @"LocationUpdated"


#endif
