// Generated by Apple Swift version 1.2 (swiftlang-602.0.53.1 clang-602.0.53)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if defined(__has_include) && __has_include(<uchar.h>)
# include <uchar.h>
#elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
#endif

typedef struct _NSZone NSZone;

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted) 
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
#endif
#if __has_feature(nullability)
#  define SWIFT_NULLABILITY(X) X
#else
# if !defined(__nonnull)
#  define __nonnull
# endif
# if !defined(__nullable)
#  define __nullable
# endif
# if !defined(__null_unspecified)
#  define __null_unspecified
# endif
#  define SWIFT_NULLABILITY(X)
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import CoreData;
@import WebKit;
@import CoreGraphics;
#endif

#import "/Users/shimmennobuyoshi/Desktop/MailReader/MailReader/MailReader-Bridging-Header.h"

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIWindow;
@class NSManagedObjectContext;
@class UIApplication;
@class NSObject;

SWIFT_CLASS("_TtC10MailReader11AppDelegate")
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic) UIWindow * __nullable window;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (BOOL)application:(UIApplication * __nonnull)application didFinishLaunchingWithOptions:(NSDictionary * __nullable)launchOptions;
- (void)applicationWillResignActive:(UIApplication * __nonnull)application;
- (void)applicationDidEnterBackground:(UIApplication * __nonnull)application;
- (void)applicationWillEnterForeground:(UIApplication * __nonnull)application;
- (void)applicationDidBecomeActive:(UIApplication * __nonnull)application;
- (void)applicationWillTerminate:(UIApplication * __nonnull)application;
- (SWIFT_NULLABILITY(nonnull) instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSDate;
@class NSEntityDescription;

SWIFT_CLASS("Bookmark")
@interface Bookmark : NSManagedObject
@property (nonatomic, copy) NSString * __nonnull content;
@property (nonatomic) NSDate * __nonnull date;
@property (nonatomic, copy) NSString * __nonnull title;
@property (nonatomic, copy) NSString * __nonnull id;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithEntity:(NSEntityDescription * __nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * __nullable)context OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithDict:(NSDictionary * __nonnull)dict context:(NSManagedObjectContext * __nonnull)context OBJC_DESIGNATED_INITIALIZER;
@end

@class MBProgressHUD;
@class UITableView;
@class NSIndexPath;
@class UITableViewCell;
@class MGSwipeTableCell;
@class MGSwipeSettings;
@class MGSwipeExpansionSettings;
@class UIStoryboardSegue;
@class UIScrollView;
@class UIImage;
@class NSAttributedString;
@class NSBundle;
@class NSCoder;

SWIFT_CLASS("_TtC10MailReader27BookmarkTableViewController")
@interface BookmarkTableViewController : UITableViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MGSwipeTableCellDelegate>
@property (nonatomic) MBProgressHUD * __null_unspecified hud;
@property (nonatomic) Bookmark * __nullable selectedBookmark;
@property (nonatomic, copy) NSArray * __nonnull bookmarks;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (NSArray * __nonnull)fetchAllBookmarks;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)setupHUD;
- (NSInteger)tableView:(UITableView * __nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell * __nonnull)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
- (BOOL)swipeTableCell:(MGSwipeTableCell * __null_unspecified)cell canSwipe:(MGSwipeDirection)direction;
- (NSArray * __null_unspecified)swipeTableCell:(MGSwipeTableCell * __null_unspecified)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings * __null_unspecified)swipeSettings expansionSettings:(MGSwipeExpansionSettings * __null_unspecified)expansionSettings;
- (void)tableView:(UITableView * __nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
- (void)prepareForSegue:(UIStoryboardSegue * __nonnull)segue sender:(id __nullable)sender;
- (UIImage * __null_unspecified)imageForEmptyDataSet:(UIScrollView * __null_unspecified)scrollView;
- (NSAttributedString * __null_unspecified)titleForEmptyDataSet:(UIScrollView * __null_unspecified)scrollView;
- (NSAttributedString * __null_unspecified)descriptionForEmptyDataSet:(UIScrollView * __null_unspecified)scrollView;
- (void)showAlert:(NSString * __nonnull)title message:(NSString * __nonnull)message;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithStyle:(UITableViewStyle)style OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(null_unspecified) instancetype)initWithNibName:(NSString * __null_unspecified)nibNameOrNil bundle:(NSBundle * __null_unspecified)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(null_unspecified) instancetype)initWithCoder:(NSCoder * __null_unspecified)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class WKWebView;
@class UIProgressView;
@class UIBarButtonItem;
@class WKNavigation;
@class WKWebViewConfiguration;
@class WKNavigationAction;
@class WKWindowFeatures;

SWIFT_CLASS("_TtC10MailReader20DetailViewController")
@interface DetailViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>
@property (nonatomic) WKWebView * __null_unspecified webView;
@property (nonatomic, copy) NSString * __nullable pageUrl;
@property (nonatomic) BOOL showUp;
@property (nonatomic) UIProgressView * __null_unspecified progressView;
@property (nonatomic) UIBarButtonItem * __null_unspecified refresh;
@property (nonatomic) UIBarButtonItem * __null_unspecified bookmarkButton;
@property (nonatomic) UIBarButtonItem * __null_unspecified backButton;
@property (nonatomic) UIBarButtonItem * __null_unspecified forwardButton;
@property (nonatomic) BOOL alreadyBookmarked;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (void)viewDidLoad;
- (void)getRidOfStuff;
- (void)setUpButtons;
- (void)closeTapped:(id __nonnull)sender;
- (void)backTapped:(id __nonnull)sender;
- (void)forwardTapped:(id __nonnull)sender;
- (void)bookmarked:(id __nonnull)sender;
- (NSArray * __nonnull)queryForBookmark:(NSString * __nonnull)id;
- (void)webView:(WKWebView * __nonnull)webView didFinishNavigation:(WKNavigation * __null_unspecified)navigation;
- (void)observeValueForKeyPath:(NSString * __nonnull)keyPath ofObject:(id __nonnull)object change:(NSDictionary * __nonnull)change context:(void * __null_unspecified)context;
- (void)scrollViewDidScroll:(UIScrollView * __nonnull)scrollView;
- (WKWebView * __nullable)webView:(WKWebView * __nonnull)webView createWebViewWithConfiguration:(WKWebViewConfiguration * __nonnull)configuration forNavigationAction:(WKNavigationAction * __nonnull)navigationAction windowFeatures:(WKWindowFeatures * __nonnull)windowFeatures;
- (void)bookmarkMessage:(NSString * __nonnull)title;
- (void)showAlert:(NSString * __nonnull)title message:(NSString * __nonnull)message;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithNibName:(NSString * __nullable)nibNameOrNil bundle:(NSBundle * __nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIPanGestureRecognizer;
@class OverlayView;
@class UITextView;
@class UILabel;
@class UIGestureRecognizer;

SWIFT_CLASS("_TtC10MailReader13DraggableView")
@interface DraggableView : WKWebView <UIGestureRecognizerDelegate>
@property (nonatomic) BOOL selected;
@property (nonatomic, copy) NSString * __nullable bookmarkedUrlString;
@property (nonatomic) BOOL topMail;
@property (nonatomic, copy) NSString * __null_unspecified messageId;
@property (nonatomic, copy) NSString * __null_unspecified labelId;
@property (nonatomic) UIPanGestureRecognizer * __null_unspecified panGesture;
@property (nonatomic) OverlayView * __null_unspecified overlayView;
@property (nonatomic) UITextView * __nullable plainTextView;
@property (nonatomic) UILabel * __nullable infoLabel;
@property (nonatomic) MBProgressHUD * __null_unspecified hud;
@property (nonatomic) BOOL userLeaving;
@property (nonatomic, copy) NSString * __nullable htmlString;
@property (nonatomic, copy) NSString * __nullable textString;
@property (nonatomic, copy) NSString * __nullable altMessageString;
@property (nonatomic) BOOL enlarged;
@property (nonatomic, copy) NSDictionary * __nonnull dict;
@property (nonatomic) BOOL showInfo;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration * __nonnull)configuration dict:(NSDictionary * __nullable)dict OBJC_DESIGNATED_INITIALIZER;
- (void)convertToPlainText:(NSString * __nonnull)text;
- (void)InfoCard:(NSString * __nonnull)from subject:(NSString * __nonnull)subject to:(NSString * __nonnull)to;
- (BOOL)gestureRecognizer:(UIGestureRecognizer * __nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * __nonnull)otherGestureRecognizer;
- (void)setup;
- (void)observeValueForKeyPath:(NSString * __nonnull)keyPath ofObject:(id __nonnull)object change:(NSDictionary * __nonnull)change context:(void * __null_unspecified)context;
- (void)dragged:(UIPanGestureRecognizer * __nonnull)gestureRecognizer;
- (void)cardAway:(CGFloat)x;
- (void)updateOverlay:(CGFloat)distance;
- (void)deleteMailFromCoreData;
- (void)addMailToBookmarks;
@end

@class Mail;

SWIFT_CLASS("Label")
@interface Label : NSManagedObject
@property (nonatomic, copy) NSString * __nonnull id;
@property (nonatomic, copy) NSString * __nonnull labelId;
@property (nonatomic, copy) NSArray * __nonnull mails;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithEntity:(NSEntityDescription * __nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * __nullable)context OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithDict:(NSDictionary * __nonnull)dict context:(NSManagedObjectContext * __nonnull)context OBJC_DESIGNATED_INITIALIZER;
@end

@class GTMOAuth2ViewControllerTouch;

SWIFT_CLASS("_TtC10MailReader19LoginViewController")
@interface LoginViewController : UIViewController
@property (nonatomic) Label * __nullable label;
@property (nonatomic) BOOL mailReaderLabelExist;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (void)viewDidLoad;
- (void)viewDidAppear:(BOOL)animated;
@property (nonatomic, readonly) GTMOAuth2ViewControllerTouch * __nonnull createAuthController;
- (void)fetchUnreadAndTrash;
- (void)prepareForSegue:(UIStoryboardSegue * __nonnull)segue sender:(id __nullable)sender;
- (void)showAlert:(NSString * __nonnull)title message:(NSString * __nonnull)message;
- (void)creaLabelInGmail;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithNibName:(NSString * __nullable)nibNameOrNil bundle:(NSBundle * __nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class NSNumber;

SWIFT_CLASS("Mail")
@interface Mail : NSManagedObject
@property (nonatomic, copy) NSString * __nonnull id;
@property (nonatomic) NSNumber * __nonnull historyId;
@property (nonatomic, copy) NSString * __nonnull threadId;
@property (nonatomic, copy) NSString * __nonnull snippet;
@property (nonatomic, copy) NSString * __nonnull to;
@property (nonatomic, copy) NSString * __nonnull from;
@property (nonatomic, copy) NSString * __nonnull subject;
@property (nonatomic, copy) NSString * __nonnull mimeType;
@property (nonatomic, copy) NSString * __nonnull message;
@property (nonatomic, copy) NSString * __nullable altMessage;
@property (nonatomic) Label * __nonnull label;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithEntity:(NSEntityDescription * __nonnull)entity insertIntoManagedObjectContext:(NSManagedObjectContext * __nullable)context OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithDict:(NSDictionary * __nonnull)dict context:(NSManagedObjectContext * __nonnull)context OBJC_DESIGNATED_INITIALIZER;
@end

@class UIButton;
@class WKNavigationResponse;
@class UIImageView;

SWIFT_CLASS("_TtC10MailReader18MailViewController")
@interface MailViewController : UIViewController <WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>
@property (nonatomic) Mail * __nullable selectedMail;
@property (nonatomic) Bookmark * __nullable selectedBookmark;
@property (nonatomic) Label * __null_unspecified label;
@property (nonatomic, copy) NSString * __nullable labelId;
@property (nonatomic) MBProgressHUD * __null_unspecified hud;
@property (nonatomic) BOOL isHudAdded;
@property (nonatomic, copy) NSString * __nullable pageUrl;
@property (nonatomic, copy) NSString * __nullable pageTitle;
@property (nonatomic) NSInteger cardsToLoad;
@property (nonatomic) NSInteger counter;
@property (nonatomic) UIBarButtonItem * __nonnull readerButton;
@property (nonatomic) UIBarButtonItem * __nonnull infoButton;
@property (nonatomic) UIBarButtonItem * __nonnull flagButton;
@property (nonatomic) BOOL flagTapped;
@property (nonatomic) NSInteger numberOfCards;
@property (nonatomic, copy) NSArray * __nonnull cardsStack;
@property (nonatomic, weak) IBOutlet UIImageView * __null_unspecified smile;
@property (nonatomic, weak) IBOutlet UILabel * __null_unspecified nomoreMessage;
@property (nonatomic, weak) IBOutlet UIButton * __null_unspecified reloadButton;
- (IBAction)reloadTapped:(id __nonnull)sender;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)loadMails;
- (void)noUnreadMails;
- (void)setupHUD;
- (void)disableButton;
- (void)setUpButtons;
- (void)tapped:(UIButton * __nonnull)button;
- (void)prepareForSegue:(UIStoryboardSegue * __nonnull)segue sender:(id __nullable)sender;
- (void)cardLoadingCheck:(DraggableView * __nonnull)view completed:(BOOL)completed;
- (void)cardCounter:(DraggableView * __nonnull)view swiped:(BOOL)swiped;
- (void)webView:(WKWebView * __nonnull)webView decidePolicyForNavigationResponse:(WKNavigationResponse * __nonnull)navigationResponse decisionHandler:(void (^ __nonnull)(WKNavigationResponsePolicy))decisionHandler;
- (WKWebView * __nullable)webView:(WKWebView * __nonnull)webView createWebViewWithConfiguration:(WKWebViewConfiguration * __nonnull)configuration forNavigationAction:(WKNavigationAction * __nonnull)navigationAction windowFeatures:(WKWindowFeatures * __nonnull)windowFeatures;
- (void)createCard:(Mail * __nullable)mail bookmark:(Bookmark * __nullable)bookmark;
- (void)showAlert:(NSString * __nonnull)title message:(NSString * __nonnull)message;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithNibName:(NSString * __nullable)nibNameOrNil bundle:(NSBundle * __nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC10MailReader11OverlayView")
@interface OverlayView : UIView
@property (nonatomic) UIImageView * __nonnull imageView;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (void)setup;
@end


SWIFT_CLASS("_TtC10MailReader18TrashTableViewCell")
@interface TrashTableViewCell : MGSwipeTableCell
@property (nonatomic, weak) IBOutlet UILabel * __null_unspecified subject;
@property (nonatomic, weak) IBOutlet UILabel * __null_unspecified from;
@property (nonatomic, weak) IBOutlet UILabel * __null_unspecified snippet;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString * __nullable)reuseIdentifier OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithCoder:(NSCoder * __nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

@class UIRefreshControl;

SWIFT_CLASS("_TtC10MailReader24TrashTableViewController")
@interface TrashTableViewController : UITableViewController <MGSwipeTableCellDelegate>
@property (nonatomic) MBProgressHUD * __null_unspecified hud;
@property (nonatomic) Mail * __nullable selectedMail;
@property (nonatomic) NSInteger timesOfScrollingToBottom;
@property (nonatomic) NSInteger oldestMailHistoryId;
@property (nonatomic) NSInteger newestMailHistoryId;
@property (nonatomic) NSInteger newMailCounter;
@property (nonatomic) NSInteger mailsCounted;
@property (nonatomic, copy) NSArray * __nonnull newMails;
@property (nonatomic, copy) NSArray * __nonnull mailsInTrash;
@property (nonatomic) BOOL hudIsAdded;
@property (nonatomic) Label * __null_unspecified label;
@property (nonatomic) NSManagedObjectContext * __nonnull sharedContext;
- (IBAction)refresh:(UIRefreshControl * __nonnull)sender;
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)reloadData;
- (void)setupHUD;
- (NSInteger)tableView:(UITableView * __nonnull)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell * __nonnull)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
- (BOOL)swipeTableCell:(MGSwipeTableCell * __null_unspecified)cell canSwipe:(MGSwipeDirection)direction;
- (NSArray * __null_unspecified)swipeTableCell:(MGSwipeTableCell * __null_unspecified)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings * __null_unspecified)swipeSettings expansionSettings:(MGSwipeExpansionSettings * __null_unspecified)expansionSettings;
- (void)tableView:(UITableView * __nonnull)tableView didSelectRowAtIndexPath:(NSIndexPath * __nonnull)indexPath;
- (void)prepareForSegue:(UIStoryboardSegue * __nonnull)segue sender:(id __nullable)sender;
- (void)showAlert:(NSString * __nonnull)title message:(NSString * __nonnull)message;
- (SWIFT_NULLABILITY(nonnull) instancetype)initWithStyle:(UITableViewStyle)style OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(null_unspecified) instancetype)initWithNibName:(NSString * __null_unspecified)nibNameOrNil bundle:(NSBundle * __null_unspecified)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (SWIFT_NULLABILITY(null_unspecified) instancetype)initWithCoder:(NSCoder * __null_unspecified)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end


@interface UIColor (SWIFT_EXTENSION(MailReader))
@end

#pragma clang diagnostic pop
