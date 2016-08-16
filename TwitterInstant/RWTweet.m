//
//  RWTweet.m
//  TwitterInstant
//
//  Created by Colin Eberhardt on 05/01/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import "RWTweet.h"

@implementation RWTweet

+ (instancetype)tweetWithStatus:(NSDictionary *)status {
  RWTweet *tweet = [RWTweet new];
//  tweet.status = status[@"text"];
//  
//  NSDictionary *user = status[@"user"];
//  tweet.profileImageUrl = user[@"profile_image_url"];
//  tweet.username = user[@"screen_name"];
    NSLog(@"status:%@",status);
    tweet.status = status[@"pubdate"];
    tweet.profileImageUrl = status[@"litpic"];
    tweet.username = status[@"writer"];
  return tweet;
}

//result =     {
//    items =         (
//                     {
//                         click = 145;
//                         description = "\U51e4\U51f0\U5a31\U4e50\U8baf \U636e\U53f0\U6e7e\U5a92\U4f53\U62a5\U9053\Uff0c\U6a21\U7279\U6797\U82e5\U4e9a\U4eca\U5e741\U6708\U548c\U7537\U53cb\U5b59\U5fd7\U6d69\U5206\U624b\Uff0c\U6700\U8fd1\U706b\U901f\U590d\U5408\U3002\U5916\U4f20\U5f53\U521d\U5206\U624b\Uff0c\U9664\U5a5a\U4e8b\U8c08\U4e0d\U62e2\Uff0c28\U65e5\U53c8\U7206\U5979\U662f\U56e0\U4e3a\U88ab\U7537\U65b9\U6253\Uff0c\U4e24\U4eba\U624d\U5206\U624b\Uff1b\U6797\U82e5\U4e9a\U6628\U633a\U8eab\U62a4\U7231\Uff0c\U8ba4\U4e3a";
//                         id = 110;
//                         litpic = "http://www.junlenet.com/uploads/allimg/150429/1-1504291U0040-L.jpg";
//                         pubdate = "2015-04-29 18:52:04";
//                         scores = 0;
//                         shorttitle = "";
//                         source = "\U672a\U77e5";
//                         title = "\U8d3e\U9759\U96ef\U524d\U592b\U6253\U6a21\U7279\U5973\U53cb\U81f4\U5206\U624b\Uff1f \U5973\U65b9\Uff1a\U88ab\U6253\U4e0d\U4f1a";
//                         typeid = 13;
//                         writer = admin;
//                     },

@end
