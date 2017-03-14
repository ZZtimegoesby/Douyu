//
//  STTSerialization.m
//  danmu
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "STTSerialization.h"

@implementation STTSerialization

+ (STTModel *)STTModelFromSTTString:(NSString *)STTString {
    NSDictionary * dic = [STTSerialization STTDictFromSTTString:STTString];
    STTModel * m = [[STTModel alloc] init];
    [m setValuesForKeysWithDictionary:dic];
    return m;
}

+ (NSDictionary *)STTDictFromSTTString:(NSString *)STTString {
    NSArray * array = [STTSerialization STTListFromSTTString:STTString];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for (NSString * str in array) {
        NSArray * arr = [str componentsSeparatedByString:@"@="];
        if (arr.count == 2) {
            [dic setObject:arr[1] forKey:arr[0]];
        }
    }
    return dic;
}

+ (NSArray *)STTListFromSTTString:(NSString *)STTString {
    NSArray * arr = [STTString componentsSeparatedByString:@"/"];
    return arr;
}

@end
