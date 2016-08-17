//
//  CocoaVC.m
//  TwitterInstant
//
//  Created by hengfu on 16/8/17.
//  Copyright © 2016年 hengfu. All rights reserved.
//

#import "CocoaVC.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface CocoaVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

@implementation CocoaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //订阅信号
    [self.nameLabel.rac_textSignal subscribeNext:^(id x) {
        
    }];
    //增加信号过滤器
    [[self.nameLabel.rac_textSignal
     filter:^BOOL(NSString * text) {
         return text.length > 3;
     }]
     subscribeNext:^(id x) {
         NSLog(@"");
     }];
    //map属性,改变事件数据
    [[self.nameLabel.rac_textSignal
      map:^id(NSString *text) {
          return @(text.length);
      }]
      subscribeNext:^(id x) {
          NSLog(@"x:%@",x);
      }];
    //创建有效状态信号
    RACSignal *validNameLabelSignal = [self.nameLabel.rac_textSignal
                                       map:^id(NSString *text) {
                                           return @(text.length > 3);
                                       }];
    RACSignal *validPasswordLabelSignal = [self.passwordLabel.rac_textSignal
                                           map:^id(NSString *text) {
                                               return @(text.length > 3);
                                           }];
    
    [[validNameLabelSignal
     map:^id(NSNumber *nameValid) {
         return [nameValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
     }]
      subscribeNext:^(UIColor *color) {
          self.nameLabel.backgroundColor = color;
      }];
    
    [[validPasswordLabelSignal
      map:^id(NSNumber *passValid) {
          return [passValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
      }]
        subscribeNext:^(UIColor *color) {
            self.passwordLabel.backgroundColor = color;
        }];
    
    //采用RAC宏:RAC宏允许直接把信号的输出应用到对象的属性上
    RAC(self.passwordLabel,backgroundColor) = [validPasswordLabelSignal map:^id(NSNumber *passValid) {
        return [passValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];
    RAC(self.nameLabel,backgroundColor) = [validNameLabelSignal map:^id(NSNumber *nameValid) {
        return [nameValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];
    //聚合信号
//    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validNameLabelSignal,validPasswordLabelSignal] reduce:^id(NSNumber *usernameValid,NSNumber *passwordValid){
//        return @([usernameValid boolValue] &&[passwordValid boolValue]);
//    }];
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validNameLabelSignal,validPasswordLabelSignal] reduce:^id(NSNumber *usernameValid,NSNumber *passwordValid){
        return @([usernameValid boolValue] && [passwordValid boolValue]);
    }];
    
    //将聚合好的信号绑定btn
    [signUpActiveSignal subscribeNext:^(NSNumber *signupActive) {
        self.loginBtn.enabled = [signupActive boolValue];
    }];
    
    //响应式是登录
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
      subscribeNext:^(id x) {
          NSLog(@"button clicked");
      }];
    
    //创建信号
    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     map:^id(id value) {
         return [self signInsignal];
     }]
      subscribeNext:^(id x) {
          NSLog(@"Sign in result:%@",x);
      }];
    //（上面）注意信号中的信号flattenMap
    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     flattenMap:^RACStream *(id value) {
         return [self signInsignal];
     }]
       subscribeNext:^(id x) {
           NSLog(@"订阅信号的信号");
       }];
    
    //添加附加操作:doNext:是直接在跟按钮点击事件的后面，而且doNext:block并没有返回值，因为他是附加操作并不改变事件本身
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     doNext:^(id x) {
         self.loginBtn.enabled = NO;
         
     }]
    flattenMap:^RACStream *(id value) {
        return [self signInsignal];
    }]
    subscribeNext:^(NSNumber *singedIn) {
        self.loginBtn.enabled = YES;
        BOOL success = [singedIn boolValue];
        if (success) {
            NSLog(@"success");
        }
    }];
    
}


//创建信号
- (RACSignal *)signInsignal
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        return nil;
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

@end
