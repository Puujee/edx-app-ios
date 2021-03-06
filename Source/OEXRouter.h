//
//  OEXRouter.h
//  edXVideoLocker
//
//  Created by Akiva Leffert on 1/29/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DataManager;
@class OEXAnalytics;
@class OEXConfig;
@class OEXCourse;
@class OEXInterface;
@class OEXPushSettingsManager;
@class OEXSession;
@class OEXStyles;
@class OEXHelperVideoDownload;
@class OEXVideoPathEntry;
@class NetworkManager;



@interface OEXRouterEnvironment : NSObject

- (instancetype)initWithAnalytics:(OEXAnalytics*)analytics
                 config:(OEXConfig*)config
            dataManager:(DataManager*)dataManager
              interface:(OEXInterface*)interface
                session:(OEXSession*)session
                 styles:(OEXStyles*)styles
         networkManager:(NetworkManager*)networkManager;

@property (readonly, strong, nonatomic) OEXAnalytics* analytics;
@property (readonly, strong, nonatomic) OEXConfig* config;
@property (readonly, strong, nonatomic) DataManager* dataManager;
@property (readonly, strong, nonatomic) OEXInterface* interface;
@property (readonly, strong, nonatomic) OEXSession* session;
@property (readonly, strong, nonatomic) OEXStyles* styles;
@property (readonly, strong, nonatomic) NetworkManager* networkManager;

@end

/// Handles navigation and routing between screens
/// allowing view controllers to be discrete units not responsible for knowing what's around them
/// This makes it easier to change what classes are used for different screens and is a natural boundary for
/// controller testing.
///
/// If this gets long consider breaking it out into different subrouters e.g. login, course
@interface OEXRouter : NSObject

/// Note that this is not thread safe. The expectation is that this only happens
/// immediately when the app launches or synchronously at the start of a test.
+ (void)setSharedRouter:(OEXRouter*)router;
+ (instancetype)sharedRouter;

// Eventually the router should take all the dependencies of our view controllers and inject them during controller construction
- (id)initWithEnvironment:(OEXRouterEnvironment*)environment NS_DESIGNATED_INITIALIZER;

- (void)openInWindow:(UIWindow*)window;

#pragma mark Presentation
- (void)presentViewController:(UIViewController*)controller fromController:(UIViewController*)presenter completion:(void(^)(void))completion;

#pragma mark Logistration
- (void)showLoginScreenFromController:(UIViewController*)controller completion:(void(^)(void))completion;
- (void)showLoggedOutScreen;
- (void)showSignUpScreenFromController:(UIViewController*)controller;

#pragma mark Top Level
- (void)showMyVideos;
- (void)showMyCourses;

#pragma mark Course Structure
- (void)showAnnouncementsForCourseWithID:(NSString*)courseID;
- (void)showCourse:(OEXCourse*)course fromController:(UIViewController*)controller;
- (void)showDiscussionTopicsForCourse:(OEXCourse*)course fromController:(UIViewController*)controller;

#pragma mark Videos
- (void)showDownloadsFromViewController:(UIViewController*)controller fromFrontViews:(BOOL)isFromFrontViews fromGenericView:(BOOL)isFromGenericViews;
- (void)showCourseVideoDownloadsFromViewController:(UIViewController*)controller forCourse:(OEXCourse*)course lastAccessedVideo:(OEXHelperVideoDownload*)video downloadProgress:(NSArray*)downloadProgress selectedPath:(NSArray*)path;
- (void)showVideoSubSectionFromViewController:(UIViewController*) controller forCourse:(OEXCourse*) course withCourseData:(NSMutableArray*) courseData;
- (void)showGenericCoursesFromViewController:(UIViewController*) controller forCourse:(OEXCourse*) course withCourseData:(NSArray*) courseData selectedChapter:(OEXVideoPathEntry*) chapter;

@end

// Only for use by OEXRouter+Swift until we can consolidate this and that into a Swift file
@interface OEXRouter (Private)

@property (readonly, strong, nonatomic) OEXRouterEnvironment* environment;

@end

@interface OEXRouter (Testing)

// UIViewController list for the currently navigation hierarchy
- (NSArray*)t_navigationHierarchy;
- (BOOL)t_showingLogin;

@end