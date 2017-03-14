//
//  LiveChatManager.h
//  DanMuTest
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTSerialization.h"

@interface LiveChatManager : NSObject

//收到消息的回调
- (void)setMessageReceiveBlock:(void(^)(STTModel * model))block;

//系统消息回调
- (void)setInfoCallbackBlock:(void(^)(STTModel * model))block;


- (void)connectWithRoomID:(NSString *)roomId groupId:(NSString *)groupId;

- (void)stop;

- (void)sysInfoCallback:(NSString *)content;

- (void)sendChatMessage:(NSString *)message;

@end
