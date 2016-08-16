//
//  PViewController.m
//  TwitterInstant
//
//  Created by hengfu on 16/8/12.
//  Copyright © 2016年 hengfu. All rights reserved.
//

#import "PViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "RWTweet.h"
#import "NSArray+LinqExtensions.h"
#import "RWSearchResultsViewController.h"
typedef NS_ENUM(NSInteger,RWTwitterInstantError)
{
    RWTwitterInstantErrorAccessDenid,
    RWTwitterInstantErrorNoTitterAcconts,
    RWTwitterInstantErrorInvalidResponse
};
static NSString * const RWTwitterInstantDomain = @"TwitterInstant";
@interface PViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) RWSearchResultsViewController *resultsViewController;
@end

@implementation PViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultsViewController = self.splitViewController.viewControllers[1];
    // Do any additional setup after loading the view.
        @weakify(self)
        [[self.searchText.rac_textSignal map:^id(NSString * text) {
            return [self isValidSearchText:text]? [UIColor whiteColor] : [UIColor yellowColor];
        }] subscribeNext:^(UIColor *color) {
            @strongify(self)
            self.searchText.backgroundColor = color;
        }];
    
        [[[[[[[self requestAccessToPengSignal]
            then:^RACSignal *{
                @strongify(self)
                return self.searchText.rac_textSignal;
            }]
             filter:^BOOL(NSString *text) {
                 @strongify(self)
                 return [self isValidSearchText:text];
             }]
            throttle:0.5]
             flattenMap:^RACStream *(NSString *text) {
                 @strongify(self);
                 return [self signalForSearchWithText:text];
             }]
              deliverOn:[RACScheduler mainThreadScheduler]]
              subscribeNext:^(NSDictionary *jsonSearchResult) {
                  //@strongify(self);
                  NSLog(@"subscribeNext:%@",jsonSearchResult);
                  NSArray *array = jsonSearchResult[@"result"][@"items"];
                  NSArray *tweets = [array linq_select:^id(id tweet) {
                      return [RWTweet tweetWithStatus:tweet];
                  }];
                  NSLog(@"tweets:%@",tweets);
                  
                  [self.resultsViewController displayTweets:tweets];
              } error:^(NSError *error) {
                  NSLog(@"An error occurred: %@",error);
              }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)isValidSearchText:(NSString *)text
{
    return text.length > 2;
    
}
//这个方法做了下面几件事：
/**
 1、定义了一个error,当用户拒绝访问时发送。
 2、和第一部分医院，类方法createSignal返回一个RACSignal实例
 3、通过account store 请求访问Twitter此时用户会看到一个弹框询问是否容许访问twitter账号。
 4、在用户允许或者拒绝之后，会发送signal事件。如果用户允许访问，会发送一个next事件，紧跟着在发送一个completed事件，如果用户拒绝访问，会发送一个error事件。
 //signal能发送3种不同类型的事件
 */


- (RACSignal *)requestAccessToPengSignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
    
}
//创建请求
- (NSURLRequest *)requestForJHSearchWithText:(NSString *)text
{
    
    //避免中文问题
    //NSString  *str = @"http://op.juhe.cn/onebox/weather/query?key=e96af18384e1f2fee180203e49ba165b&cityname=长沙";
    NSString  *str = [NSString stringWithFormat:@"http://junlenet.com/app/news/list.php?typeid=13&page=1&size=%lu",(unsigned long)text.length];
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:str];
    
    //创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    
    //SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
    return request;
    
}

//基于这个请求创建

- (RACSignal *)signalForSearchWithText:(NSString *)text
{
    NSError *acccessError = [NSError errorWithDomain:RWTwitterInstantDomain code:RWTwitterInstantErrorAccessDenid userInfo:nil];
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        //3-create the request
        NSURLRequest *request = [self requestForJHSearchWithText:@"长沙"];
        //4-perform the request
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError) {
                [subscriber sendError:acccessError];
            }
            else
            {
                NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                //NSLog(@"timelineData :%@",timelineData);
                [subscriber sendNext:timelineData];
                [subscriber sendCompleted];
            }
            
            
        }];
        return nil;
    }];
}
@end
