//
//  OEXFrontCourseViewController.m
//  edXVideoLocker
//
//  Created by Nirbhay Agarwal on 16/05/14.
//  Copyright (c) 2014 edX. All rights reserved.
//
#import "edX-Swift.h"

#import "OEXFrontCourseViewController.h"

#import "NSArray+OEXSafeAccess.h"
#import "NSString+OEXFormatting.h"

#import "OEXAnalytics.h"
#import "OEXAppDelegate.h"
#import "OEXCourse.h"
#import "OEXCustomTabBarViewViewController.h"
#import "OEXDateFormatting.h"
#import "OEXDownloadViewController.h"
#import "OEXNetworkConstants.h"
#import "OEXConfig.h"
#import "OEXFindCourseTableViewCell.h"
#import "OEXFrontTableViewCell.h"
#import "OEXLatestUpdates.h"
#import "OEXRegistrationViewController.h"
#import "OEXRouter.h"
#import "OEXUserCourseEnrollment.h"
#import "Reachability.h"
#import "SWRevealViewController.h"
#import "OEXFindCoursesViewController.h"
#import "OEXStatusMessageViewController.h"
#import "OEXEnrollmentMessage.h"
#import "OEXRouter.h"
#import "OEXStyles.h"

@interface OEXFrontCourseViewController () <OEXStatusMessageControlling>
{
    UIImage* placeHolderImage;
}
@property (nonatomic, strong) OEXInterface* dataInterface;
@property (nonatomic, strong) NSMutableArray* arr_CourseData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* ConstraintOfflineErrorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* constraintErrorY;
@property (strong, nonatomic) UIRefreshControl* refreshTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@property (weak, nonatomic) IBOutlet UIView* view_EULA;
@property (weak, nonatomic) IBOutlet UIWebView* webview_Message;
@property (weak, nonatomic) IBOutlet UIButton* btn_Close;
@property (weak, nonatomic) IBOutlet UIImageView* separator;
@property (weak, nonatomic) IBOutlet UIView* view_Offline;
@property (weak, nonatomic) IBOutlet UIButton* btn_Downloads;
@property (weak, nonatomic) IBOutlet UILabel* lbl_Offline;
@property (weak, nonatomic) IBOutlet UITableView* table_Courses;
@property (weak, nonatomic) IBOutlet UIButton* btn_LeftNavigation;
@property (weak, nonatomic) IBOutlet DACircularProgressView* customProgressBar;
@property (weak, nonatomic) IBOutlet UILabel* lbl_NavTitle;
@property (weak, nonatomic) IBOutlet UIView* backgroundForTopBar;

@end

@implementation OEXFrontCourseViewController

- (void)dealloc {
    placeHolderImage = nil;
    [self removeObservers];
}

#pragma mark Controller delegate

- (IBAction)downloadButtonPressed:(id)sender {
    [[OEXRouter sharedRouter] showDownloadsFromViewController:self fromFrontViews:YES fromGenericView:NO];
}


#pragma mark Status Messages

- (CGFloat)verticalOffsetForStatusController:(OEXStatusMessageViewController*)controller {
    return CGRectGetMaxY(self.backgroundForTopBar.bounds);
}

- (NSArray*)overlayViewsForStatusController:(OEXStatusMessageViewController*)controller {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [result oex_safeAddObjectOrNil:self.backgroundForTopBar];
    [result oex_safeAddObjectOrNil:self.lbl_NavTitle];
    [result oex_safeAddObjectOrNil:self.customProgressBar];
    [result oex_safeAddObjectOrNil:self.btn_Downloads];
    [result oex_safeAddObjectOrNil:self.btn_LeftNavigation];
    return result;
}

#pragma mark - Refresh Control

- (void)InitializeTableCourseData {
    // Initialize array

    self.activityIndicator.hidden = NO;

    self.arr_CourseData = [[NSMutableArray alloc] init];

    placeHolderImage = [UIImage imageNamed:@"Splash_map.png"];

    // Initialize the interface for API calling
    self.dataInterface = [OEXInterface sharedInterface];
    if(!_dataInterface.courses) {
        [_dataInterface downloadWithRequestString:URL_COURSE_ENROLLMENTS forceUpdate:YES];
    }
    else {
        for(OEXUserCourseEnrollment* courseEnrollment in _dataInterface.courses) {
            OEXCourse* course = courseEnrollment.course;
            [self.arr_CourseData addObject:course];
        }

        self.activityIndicator.hidden = YES;
    }
}

- (void)addRefreshControl {
    self.refreshTable = [[UIRefreshControl alloc] init];
    self.refreshTable.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [self.refreshTable addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.table_Courses addSubview:self.refreshTable];
}

- (void)refreshView {
    ELog(@"refreshView");
    self.refreshTable.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    self.table_Courses.contentInset = UIEdgeInsetsMake(60, 0, 8, 0);
    [_dataInterface downloadWithRequestString:URL_COURSE_ENROLLMENTS forceUpdate:YES];
}

- (void)endRefreshingData {
    ELog(@"endRefreshingData");
    [self.refreshTable endRefreshing];
}

- (void)removeRefreshControl {
    ELog(@"removeRefreshControl");
    [self.refreshTable removeFromSuperview];
    [self.table_Courses reloadData];
}

#pragma mark - FIND A COURSE

- (void)findCourses:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[OEXConfig sharedConfig].courseSearchURL]];

    OEXFindCoursesViewController* findCoursesViewController = [[OEXFindCoursesViewController alloc] init];
    [self.navigationController pushViewController:findCoursesViewController animated:YES];

    [[OEXAnalytics sharedAnalytics] trackUserFindsCourses];
}

- (void)hideWebview:(BOOL)hide {
    [self.webview_Message.scrollView setContentOffset:CGPointMake(0, 0)];
    self.view_EULA.hidden = hide;
    self.webview_Message.hidden = hide;
    self.btn_Close.hidden = hide;
    self.separator.hidden = hide;
}

- (void)loadWebView {
    [self.webview_Message loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"COURSE_NOT_LISTED" ofType:@"htm"] isDirectory:NO]]];
}

- (void)dontSeeCourses:(id)sender {
    [[OEXRouter sharedRouter] showFullScreenMessageViewControllerFromViewController:self message:OEXLocalizedString(@"COURSE_NOT_LISTED", nil) bottomButtonTitle:OEXLocalizedString(@"CLOSE", nil)];
    
}

- (IBAction)closeClicked:(id)sender {
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self hideWebview:YES];
}

#pragma mark view delegate methods

- (void)leftNavigationBtnClicked {
    self.view.userInteractionEnabled = NO;
    self.overlayButton.hidden = NO;
    // End the refreshing
    [self endRefreshingData];
    [UIView animateWithDuration:0.9 delay:0 options:0 animations:^{
        self.overlayButton.alpha = 0.5f;
    } completion:nil];
    [self performSelector:@selector(call) withObject:nil afterDelay:0.2];
}

- (void)call {
    [self.revealViewController revealToggle:self.btn_LeftNavigation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @" " style: UIBarButtonItemStylePlain target: nil action: nil];
    
    //self.lbl_NavTitle.accessibilityLabel=@"txtHeader";
    self.lbl_NavTitle.text = OEXLocalizedString(@"MY_COURSES", nil);

    //Hide back button
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setTranslucent:NO];

    //set navigation title font
    self.lbl_NavTitle.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    
    //Mock NavBar style
    [[OEXStyles sharedStyles] applyMockNavigationBarStyleToView:self.backgroundForTopBar label:self.lbl_NavTitle leftIconButton:self.btn_LeftNavigation];
    
    //Add custom button for drawer
    self.overlayButton.alpha = 0.0f;
    [self.btn_LeftNavigation addTarget:self action:@selector(leftNavigationBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    [self.table_Courses setExclusiveTouch:YES];
    [self.btn_LeftNavigation setExclusiveTouch:YES];
    self.overlayButton.exclusiveTouch = YES;
    self.view.exclusiveTouch = YES;

    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];

    //set custom progress bar properties

    [self.customProgressBar setProgressTintColor:PROGRESSBAR_PROGRESS_TINT_COLOR];

    [self.customProgressBar setTrackTintColor:PROGRESSBAR_TRACK_TINT_COLOR];

    [self.customProgressBar setProgress:_dataInterface.totalProgress animated:YES];

    //Fix for 20px issue for the table view
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.table_Courses setContentInset:UIEdgeInsetsMake(0, 0, 8, 0)];

    self.customProgressBar.progress = 0.0f;

    // Add observers
    [self addObservers];

    // Course Data to show up on the TableView
    [self InitializeTableCourseData];

    //Analytics Screen record
    [[OEXAnalytics sharedAnalytics] trackScreenWithName:@"My Courses"];

    [[self.dataInterface progressViews] addObject:self.customProgressBar];
    [[self.dataInterface progressViews] addObject:self.btn_Downloads];
    [self.customProgressBar setHidden:YES];
    [self.btn_Downloads setHidden:YES];

    if(_dataInterface.reachable) {
        [self addRefreshControl];
    }
}

- (void)addObservers {
    //Listen to notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showCourseEnrollSuccessMessage:) name:NOTIFICATION_COURSE_ENROLLMENT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:NOTIFICATION_URL_RESPONSE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalDownloadProgress:) name:OEXDownloadProgressChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showExternalRegistrationWithExistingLoginMessage:) name:OEXExternalRegistrationWithExistingAccountNotification object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_COURSE_ENROLLMENT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_URL_RESPONSE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OEXDownloadProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OEXExternalRegistrationWithExistingAccountNotification object:nil];
}

- (void)showExternalRegistrationWithExistingLoginMessage:(NSNotification*)notification {
    NSString* message = [NSString oex_stringWithFormat:OEXLocalizedString(@"EXTERNAL_REGISTRATION_BECAME_LOGIN", nil) parameters:@{@"service" : notification.object}];
    [[OEXStatusMessageViewController sharedInstance] showMessage:message onViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.table_Courses deselectRowAtIndexPath:[self.table_Courses indexPathForSelectedRow] animated:NO];

    // Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];

    // Check Reachability for OFFLINE
    if(_dataInterface.reachable) {
        [self HideOfflineLabel:YES];
    }
    else {
        [self HideOfflineLabel:NO];
    }

    [self hideWebview:YES];
    [self loadWebView];

    // set navigation bar hidden
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.userInteractionEnabled = YES;
    [self showHideOfflineModeView];
}

- (void)showHideOfflineModeView {
    if(_dataInterface.shownOfflineView) {
        [UIView animateWithDuration:1 animations:^{
            _constraintErrorY.constant = 42;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hideOfflineHeaderView) withObject:nil afterDelay:2];
            _dataInterface.shownOfflineView = NO;
        }];
    }
}

- (void)hideOfflineHeaderView {
    [UIView animateWithDuration:1 animations:^{
        _constraintErrorY.constant = -48;

        [self.view layoutIfNeeded];
    }];
}
#pragma mark internalClassMethods

- (void)reloadTable {
    [self.table_Courses reloadData];
}

- (void)HideOfflineLabel:(BOOL)isOnline {
    //Minor Hack for matching the Spec right now.
    //TODO: Remove once refactoring with a navigation bar.
    self.lbl_Offline.hidden = true;
    self.view_Offline.hidden = isOnline;

    if(!self.lbl_Offline.hidden) {
        self.customProgressBar.hidden = YES;
        self.btn_Downloads.hidden = YES;
    }
}

#pragma mark TableViewDataSourceDelegate

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return [self.arr_CourseData count] + 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
//    ELog(@"%d",indexPath.section);
    if(indexPath.section < [self.arr_CourseData count]) {
        static NSString* cellIndentifier = @"PlayerCell";

        OEXFrontTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        
        if ([self isRTL]) {
            cell.img_Starting.image = [UIImage imageNamed:@"ic_starting_RTL"];
        }
        
        OEXCourse* obj_course = [self.arr_CourseData objectAtIndex:indexPath.section];
        cell.course = obj_course;
        cell.img_Course.image = placeHolderImage;
        cell.lbl_Title.text = obj_course.name;

        cell.lbl_Subtitle.text = [NSString stringWithFormat:@"%@ | %@", obj_course.org, obj_course.number];     // Show course ced

        //set course image
        [cell setCourseImage];

        cell.lbl_Starting.hidden = NO;
        cell.img_Starting.hidden = NO;

        // If no new course content is available
        if([obj_course.latest_updates.video length] == 0) {
            cell.img_NewCourse.hidden = YES;
            cell.btn_NewCourseContent.hidden = YES;

            // If both start and end dates are blank then show nothing.
            if(obj_course.start == nil && obj_course.end == nil) {
                cell.img_Starting.hidden = YES;
                cell.lbl_Starting.hidden = YES;
            }
            else {
                // If start date is older than current date
                if(obj_course.isStartDateOld) {
                    NSString* formattedEndDate = [OEXDateFormatting formatAsMonthDayString: obj_course.end];

                    // If Old date is older than current date
                    if(obj_course.isEndDateOld) {
                        cell.lbl_Starting.text = [NSString stringWithFormat:@"%@ - %@", OEXLocalizedString(@"ENDED", nil), formattedEndDate];
                    }
                    else {      // End date is newer than current date
                        if(obj_course.end == nil) {
                            cell.img_Starting.hidden = YES;
                            cell.img_NewCourse.hidden = YES;
                            cell.btn_NewCourseContent.hidden = YES;
                            cell.lbl_Starting.hidden = YES;
                        }
                        else {
                            cell.lbl_Starting.text = [NSString stringWithFormat:@"%@ - %@", [OEXLocalizedString(@"ENDING", nil) oex_uppercaseStringInCurrentLocale], formattedEndDate];
                        }
                    }
                }
                else {  // Start date is newer than current date
                    if(obj_course.start == nil) {
                        cell.img_Starting.hidden = YES;
                        cell.img_NewCourse.hidden = YES;
                        cell.btn_NewCourseContent.hidden = YES;
                        cell.lbl_Starting.hidden = YES;
                    }
                    else {
                        NSString* formattedStartDate = [OEXDateFormatting formatAsMonthDayString:obj_course.start];
                        cell.lbl_Starting.text = [NSString stringWithFormat:@"%@ - %@", [OEXLocalizedString(@"STARTING", nil) oex_uppercaseStringInCurrentLocale], formattedStartDate];
                    }
                }
            }
        }
        else {
            cell.img_Starting.hidden = YES;
            cell.lbl_Starting.hidden = YES;
            cell.img_NewCourse.hidden = NO;
            cell.btn_NewCourseContent.hidden = NO;
        }

        cell.exclusiveTouch = YES;

        
        
        return cell;
    }
    else {
        static NSString* cellIndentifier = @"FindCell";

        OEXFindCourseTableViewCell* cellFind = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        cellFind.btn_FindACourse.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:cellFind.btn_FindACourse.titleLabel.font.pointSize];
        [cellFind.btn_FindACourse addTarget:self action:@selector(findCourses:) forControlEvents:UIControlEventTouchUpInside];

        cellFind.btn_DontSeeCourse.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:cellFind.btn_DontSeeCourse.titleLabel.font.pointSize];
        [cellFind.btn_DontSeeCourse addTarget:self action:@selector(dontSeeCourses:) forControlEvents:UIControlEventTouchUpInside];

        return cellFind;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.section < [self.arr_CourseData count]) {
        return 187;
    }
    else {
        return 125;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    headerview.backgroundColor = [UIColor clearColor];
    return headerview;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    OEXCourse* course = [self.arr_CourseData oex_safeObjectAtIndex:indexPath.section];
    [self showCourse:course];

    // End the refreshing
    [self endRefreshingData];
}

#pragma mark Notifications Received

- (void)updateTotalDownloadProgress:(NSNotification* )notification {
    [self.customProgressBar setProgress:_dataInterface.totalProgress animated:YES];
}

#pragma mark - Reachability

- (void)reachabilityDidChange:(NSNotification*)notification {
    id <Reachability> reachability = [notification object];

    if([reachability isReachable]) {
        _dataInterface.reachable = YES;

        [self HideOfflineLabel:YES];

        [self removeRefreshControl];
        [self addRefreshControl];
    }
    else {
        self.activityIndicator.hidden = YES;

        _dataInterface.reachable = NO;

        [self HideOfflineLabel:NO];

        [self removeRefreshControl];
    }

    if([self.navigationController topViewController] == self) {
        [self showHideOfflineModeView];
    }
}

#pragma mark data edxInterfaceDelegate

- (void)dataAvailable:(NSNotification*)notification {
    NSDictionary* userDetailsDict = (NSDictionary*)notification.userInfo;

    NSString* successString = [userDetailsDict objectForKey:NOTIFICATION_KEY_STATUS];
    NSString* URLString = [userDetailsDict objectForKey:NOTIFICATION_KEY_URL];

    if([successString isEqualToString:NOTIFICATION_VALUE_URL_STATUS_SUCCESS]) {
        if([URLString isEqualToString:[_dataInterface URLStringForType:URL_COURSE_ENROLLMENTS]]) {
            // Change is_registered state to false first for all the entries.
            // Then check the Courseid and update the is_registered to True for
            // only the Courseid we receive in response.
            //
            // The locally saved files for the entries with is_registered False should be removed.
            // Then remvoe the entries from the DB.

            // Unregister All entries
            [_dataInterface setAllEntriesUnregister];
            [self.arr_CourseData removeAllObjects];
            NSMutableArray* courses = [[NSMutableArray alloc] init];
            NSMutableSet* seenCourseIds = [[NSMutableSet alloc] init];
            for(OEXUserCourseEnrollment* courseEnrollment in _dataInterface.courses) {
                OEXCourse* course = courseEnrollment.course;
                // is_Register to YES for course.
                if(course.course_id && ![seenCourseIds containsObject:course.course_id]) {
                    [courses addObject:course];
                    [seenCourseIds addObject:course.course_id];
                }
                [self.arr_CourseData addObject:course];
            }
            // Delete all the saved file for unregistered.
            [self.dataInterface setRegisteredCourses:courses];
            [_dataInterface deleteUnregisteredItems];
            // When we get new data . stop the refresh loading.
            [self endRefreshingData];
            [self.table_Courses reloadData];
            self.activityIndicator.hidden = YES;
            ELog(@"Course data available");
        }
    }
}

#pragma mark  action event

- (void)showCourse:(OEXCourse*)course {
    if(course) {
        [[OEXRouter sharedRouter] showCourse:course fromController:self];
    }
}

- (IBAction)newCourseContentClicked:(UIButton*)sender {
    UIView* view = sender;
    while(![view isKindOfClass:[OEXFrontTableViewCell class]])  {
        view = view.superview;
    }
    OEXCourse* course = ((OEXFrontTableViewCell*)view).course;
    [self showCourse:course];
}

#pragma mark SWRevealViewController

- (void)revealController:(SWRevealViewController*)revealController didMoveToPosition:(FrontViewPosition)position {
    self.view.userInteractionEnabled = YES;
    [super revealController:revealController didMoveToPosition:position];
}

- (void)showCourseEnrollSuccessMessage:(NSNotification*)notification {
    if(notification.object && [notification.object isKindOfClass:[OEXEnrollmentMessage class]]) {
        OEXEnrollmentMessage* message = (OEXEnrollmentMessage*)notification.object;
        [[OEXStatusMessageViewController sharedInstance]
         showMessage:message.messageBody onViewController:self];
        if(message.shouldReloadTable) {
            self.activityIndicator.hidden = NO;
            [_dataInterface downloadWithRequestString:URL_COURSE_ENROLLMENTS forceUpdate:YES];
        }
    }
}


- (BOOL) isRTL {
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

@end
