//
//  STTSerialization.h
//  danmu
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTModel.h"

@interface STTSerialization : NSObject

+ (NSDictionary *)STTDictFromSTTString:(NSString *)STTString;

+ (STTModel *)STTModelFromSTTString:(NSString *)STTString;

@end
