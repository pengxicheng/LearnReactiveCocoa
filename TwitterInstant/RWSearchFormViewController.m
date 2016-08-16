//
//  RWSearchFormViewController.m
//  TwitterInstant
//
//  Created by Colin Eberhardt on 02/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWSearchFormViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "RWTweet.h"


typedef NS_ENUM(NSInteger,RWTwitterInstantError)
{
    RWTwitterInstantErrorAccessDenid,
    RWTwitterInstantErrorNoTitterAcconts,
    RWTwitterInstantErrorInvalidResponse
};
static NSString * const RWTwitterInstantDomain = @"TwitterInstant";
@interface RWSearchFormViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchText;

@property (strong,nonatomic)ACAccountStore *accountStore;
@property (strong,nonatomic)ACAccountType *twitterAccountType;
//ACAccountStore 类能让你访问你的设备能连接到的多个社交媒体账号，ACAccountType类代表账户的类型。

@end

@implementation RWSearchFormViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Twitter Instant Peng";
    
//    [[self.searchText.rac_textSignal map:^id(NSString *text) {
//        return [self isValidSearchText:text]?[UIColor whiteColor] : [UIColor yellowColor];
//    }] subscribeNext:^(UIColor *color) {
//        self.searchText.backgroundColor = color;
//    }];
    /**
     内存管理：
     在以上代码中，你是否好奇创建的这些管道是如何持有的呢？显然，它并没有分配给某个变量或是属性，所以他也不会有引用计数的增加，那它是怎么销毁的呢？
     ReactiveCocoa设计的一个目标就是支持匿名生成管道这种编程风格。到目前为止，在你所写的所有响应式代码中，这应该是很直观的。
     为了支持这种模型，ReactiveCocoa自己持有的全局的所有信号，如果一个signal有一个或多个订阅者，那这个signal就是活跃的，如果所有的订阅者被移除，那这个信号就能被销毁了
     */
    
    //RACSignal的订阅方法都会返回一个RACDisposable实例，它能让你通过dispose方法移除订阅
    
//    RACSignal *backgroundColorSignal = [self.searchText.rac_textSignal map:^id(NSString *text) {
//        return [self isValidSearchText:text]?[UIColor whiteColor] : [UIColor yellowColor];
//    }];
//    
//    RACDisposable *subscription = [backgroundColorSignal subscribeNext:^(UIColor *color) {
//        self.searchText.backgroundColor = color;
//    }];
//    
//    [subscription dispose];
    
    //注意：根据上面所说的，如果你创建了一个管道，但是没有订阅他，这个管道就不会执行，包括如doNext:block 的附加操作
    
    //避免循环应用
    //ReactiveCocoa 已经在幕后做了很多事情，这也就意味着你并不需要太多关注signal的内存管理，但是还有一个很重要的内存相关问题你需要注意。
//    [[self.searchText.rac_textSignal map:^id(NSString *text) {
//        return [self isValidSearchText:text]?[UIColor whiteColor] : [UIColor yellowColor];
//    }] subscribeNext:^(UIColor *color) {
//        self.searchText.backgroundColor = color;
//    }];
    //subscribeNext:block 中使用的self来获取texefield的引用.block会捕获并持有器作用域内的值，因此，如果self和这个信号之间存在一个强应用的话，就会造成循环引用。循环引用是否会造成问题，取决于self对象的生命周期，如果self的生命周期是整个应用时，比如说本例，那也无伤大雅，但是在更复杂一些应用中，就不是这么回事了。
    //为了避免循环应用，Apple 建议获取一个self的若引用。__weak 来修饰一个弱引用，这种方法不是很优雅
    
    //下面ReactiveCocoa框架包含了一个语法糖来替换上面的代码，在文件顶部添加下面的代码
    //#import <ReactiveCocoa/RACEXTScope.h>
    
//    @weakify(self)
//    [[self.searchText.rac_textSignal map:^id(NSString * text) {
//        return [self isValidSearchText:text]? [UIColor whiteColor] : [UIColor yellowColor];
//    }] subscribeNext:^(UIColor *color) {
//        @strongify(self)
//        self.searchText.backgroundColor = color;
//    }];
    //上面的@weakfiy和@strongify语句是在Extended Objective-C库中定义的宏，也包括ReaciveCocoa中，@weakify宏让你创建一个弱引用的影子对象（如果你需要多个弱引用，你可以传入多个变量），
    //@strongify让你创建一个对之前传入的@weakify对象的强引用
    
//    self.accountStore = [[ACAccountStore alloc] init];
//    self.twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //上面的代码创建了一个account store 和Twitter的账号标识符
    
//    [[self requestAccessToTwitterSignal] subscribeNext:^(id x) {
//        NSLog(@"Access granted");
//    } error:^(NSError *error) {
//        NSLog(@"An error occurred:%@",error);
//    }];
    //换成下面的
//    [[[self requestAccessToTwitterSignal]
//       then:^RACSignal *{
//           @strongify(self)
//           return self.searchText.rac_textSignal;
//       }]
//        subscribeNext:^(id x) {
//            NSLog(@"%@",x);
//        } error:^(NSError *error) {
//            NSLog(@"An errro occurred:%@",error);
//        }
//     ];
    
    //增加过滤
//    [[[[self requestAccessToTwitterSignal]
//       then:^RACSignal *{
//           @strongify(self)
//           return self.searchText.rac_textSignal;
//       }]
//        filter:^BOOL(NSString *text) {
//            @strongify(self)
//            return [self isValidSearchText:text];
//        }]
//         subscribeNext:^(id x) {
//             NSLog(@"%@",x);
//         } error:^(NSError *error) {
//             NSLog(@"An error occured: %@",error);
//         }];
    //加入网络请求
//    [[[[[self requestAccessToPengSignal]
//        then:^RACSignal *{
//            @strongify(self)
//            return self.searchText.rac_textSignal;
//        }]
//         filter:^BOOL(NSString *text) {
//             @strongify(self)
//             return [self isValidSearchText:text];
//         }]
//         flattenMap:^RACStream *(NSString *text) {
//             @strongify(self);
//             return [self signalForSearchWithText:text];
//         }]
//          subscribeNext:^(id x) {
//              NSLog(@"subscribeNext:%@",x);
//          } error:^(NSError *error) {
//              NSLog(@"An error occurred: %@",error);
//          }];
//    
  
}

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

//线程
/**
 我相信你已经想把搜索Twitter返回的JSON值和UI 连接起来了，但是在这之前还有最后一个需要做的事情，现在需要稍微做一些探索，来看一下这倒是是什么！
 通常的做法是使用操作队列，但是ReactiveCocoa有更简单的解决方法
 在flattenMap 之后添加一个deliverOn:
 [[[[[[self requestAccessToTwitterSignal]
     then:^RACSignal *{
     @strongify(self)
     return self.searchText.rac_textSignal;
     }]
     filter:^BOOL(NSString *text) {
     @strongify(self)
     return [self isValidSearchText:text];
     }]
     flattenMap:^RACStream *(NSString *text) {
     @strongify(self)
     return [self signalForSearchWithText:text];
     }]
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
     NSLog(@"%@", x);
     } error:^(NSError *error) {
     NSLog(@"An error occurred: %@", error);
     }];
 
 */

//图片后台下载

//节流
/**
 你可能注意到了，每次输入一个字，搜索Twitter都会马上执行，如果你输入很快（或者只是一个按着删除键），这可能造成应用在一秒内执行好几次搜索，这很不理想，原因如下：首先，多次调用Twitter搜索API，但大部分返回结果都没有用
 更好的解决方法是，当搜索文本在短时间内，比如500毫秒，不在变化时，再执行搜索
 在filter之后添加一个throttle步骤
 [[[[[[[self requestAccessToTwitterSignal]
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
 @strongify(self)
 return [self signalForSearchWithText:text];
 }]
 deliverOn:[RACScheduler mainThreadScheduler]]
 subscribeNext:^(NSDictionary *jsonSearchResult) {
 NSArray *statuses = jsonSearchResult[@"statuses"];
 NSArray *tweets = [statuses linq_select:^id(id tweet) {
 return [RWTweet tweetWithStatus:tweet];
 }];
 [self.resultsViewController displayTweets:tweets];
 } error:^(NSError *error) {
 NSLog(@"An error occurred: %@", error);
 }]
 只是当前一个next 事件在指定的时间段内没有被接收到后，throttle:节流阀操作才会发送next事件，就是这么简单
 */
@end
