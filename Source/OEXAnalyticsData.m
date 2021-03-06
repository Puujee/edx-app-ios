//
//  OEXAnalyticsData.m
//  edXVideoLocker
//
//  Created by Akiva Leffert on 3/16/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

#import "OEXAnalyticsData.h"

NSString* const OEXAnalyticsKeyProvider = @"provider";

NSString* const OEXAnalyticsEventCourseEnrollment = @"edx.bi.app.course.enroll.clicked";
NSString* const OEXAnalyticsEventRegistration = @"edx.bi.app.user.register.clicked";
NSString* const OEXAnalyticsEventAnnouncementNotificationReceived = @"edx.bi.app.notification.course.update.received";
NSString* const OEXAnalyticsEventAnnouncementNotificationTapped = @"edx.bi.app.notification.course.update.tapped";

NSString* const OEXAnalyticsCategoryUserEngagement = @"user-engagement";
NSString* const OEXAnalyticsCategoryConversion = @"conversion";
NSString* const OEXAnalyticsCategoryNotifications = @"notifications";