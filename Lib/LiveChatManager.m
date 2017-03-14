//
//  LiveChatManager.m
//  DanMuTest
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "LiveChatManager.h"
#import "GCDAsyncSocket.h"

#define BUFFER_SIZE 1024
#define DANMU_PORT  8601
#define DANMU_IP @"openbarrage.douyutv.com"
#define USERNAME    @"Visitor"
#define PASSWORD    @"1234567890123456"

typedef struct MsgInfo {
    int len;
    int code;
    int magic;
    char content[BUFFER_SIZE];
} MsgInfo;

@interface LiveChatManager ()
{
    BOOL _keepConnect;
    NSTimer * _keepAliveTimer;
    NSString * _roomId;
    NSString * _groupId;
    void (^_messageReceiveBlock)(STTModel *);
    void (^_infoCallbackBlock)(STTModel *);
}

@property (nonatomic) GCDAsyncSocket * socket;

@end

@implementation LiveChatManager

- (instancetype)init {
    if (self = [super init]) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)connectWithRoomID:(NSString *)roomId groupId:(NSString *)groupId {
    _roomId = roomId;
    _groupId = groupId;
    NSError * error = nil;
    [_socket connectToHost:DANMU_IP onPort:DANMU_PORT error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    _keepConnect = YES;
}

- (void)setMessageReceiveBlock:(void (^)(STTModel *))block {
    _messageReceiveBlock = block;
}

- (void)setInfoCallbackBlock:(void(^)(STTModel * model))block {
    _infoCallbackBlock = block;
}

- (void)stop {
    _keepConnect = NO;
    [self keepAliveloop:NO];
    [self logoutWithSocket:_socket];
    [_socket disconnectAfterWriting];
}

- (void)sysInfoCallback:(NSString *)content {
    if (_infoCallbackBlock) {
        STTModel * model = [[STTModel alloc] init];
        model.type = @"sysInfo";
        model.txt = content;
        dispatch_async(dispatch_get_main_queue(), ^{
            _infoCallbackBlock(model);
        });
    }
}

- (NSData *)msgToServerDataWithContent:(NSString *)content {
    MsgInfo msg;
    int ct_len = snprintf(msg.content, sizeof(msg.content), "%s", content.UTF8String);
    msg.len = ct_len + 1 + sizeof(msg.code) + sizeof(msg.magic);
    msg.code = msg.len;
    msg.magic = 0x2b1;
    NSData * data = [NSData dataWithBytes:&msg length:msg.len+sizeof(msg.len)];
    return data;
}

- (void)loginToServerWithSocket:(GCDAsyncSocket *)sock {
    NSData * data = [self msgToServerDataWithContent:[NSString stringWithFormat:@"type@=loginreq/username@=%@/password@=%@/roomid@=%d/", USERNAME, PASSWORD, [_roomId intValue]]];
    [sock writeData:data withTimeout:10 tag:0];
}

- (void)joinGroupWithSocket:(GCDAsyncSocket *)sock {
    NSData * data = [self msgToServerDataWithContent:[NSString stringWithFormat:@"type@=joingroup/rid@=%@/gid@=%@/", _roomId, _groupId]];
    [sock writeData:data withTimeout:10 tag:1];
}

- (void)logoutWithSocket:(GCDAsyncSocket *)sock {
    NSData * data = [self msgToServerDataWithContent:@"type@=logout/"];
    [sock writeData:data withTimeout:10 tag:99];
}

- (void)keepAlive {
    NSData * data = [self msgToServerDataWithContent:[NSString stringWithFormat:@"type@=keeplive/tick@=%ld/",  (long)[[NSDate date] timeIntervalSince1970]]];
    [_socket writeData:data withTimeout:10 tag:1];
}

- (void)keepAliveloop:(BOOL)keep {
    [_keepAliveTimer invalidate];
    _keepAliveTimer = nil;
    if (keep) {
        _keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES];
    }
}

- (void)sendChatMessage:(NSString *)message {
//    NSData * data = [self msgToServerDataWithContent:[NSString stringWithFormat:@"type@=chatmessage/receiver@=0/content@=%@/scope@=/col@=0/", message]];
//    [_socket writeData:data withTimeout:10 tag:1];
}

- (void)queryRankListWithRoomId:(NSString *)roomId {
    NSData * data = [self msgToServerDataWithContent:[NSString stringWithFormat:@"type@=qrl/rid@=%@/et@=0/", roomId]];
    [_socket writeData:data withTimeout:10 tag:2];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
//    NSLog(@"didConnect");
    [self loginToServerWithSocket:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteData:%ld", tag);
    [sock readDataWithTimeout:10 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    MsgInfo msg;
    [data getBytes:&msg length:sizeof(msg)];
    NSString * STTString = [NSString stringWithUTF8String:msg.content];
    //NSLog(@"%@", STTString);
    STTModel * model = [STTSerialization STTModelFromSTTString:STTString];
    
    //NSLog(@"didReadData:%ld", tag);
    if (tag == 0) {
        [self sysInfoCallback:@"弹幕连接中..."];
        [self joinGroupWithSocket:sock];
        [self keepAliveloop:YES];
    } else if (tag == 1) {
        //[self queryRankListWithRoomId:_roomId];
    }
    //NSLog(@"%@", data);
    
    if (_messageReceiveBlock && [model.type isEqualToString:@"chatmsg"] && model.nn.length > 0 && model.txt.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _messageReceiveBlock(model);
        });
    }
    if ([model.type isEqualToString:@"uenter"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _infoCallbackBlock(model);
        });
        
    }
    
    if ([model.type isEqualToString:@"dgb"]) {
        NSLog(@"%@赠送%@", model.nn, model.gfid);
    }
    if ([model.type isEqualToString:@"ranklist"]) {
        NSLog(@"排行%@,%@", model.list_all, model.list);
    }
    [sock readDataWithTimeout:46 tag:2];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    if (tag == 0) {
        NSLog(@"登录超时");
    } else if (tag == 1) {
        NSLog(@"加入房间超时");
    }
    [sock readDataWithTimeout:10 tag:tag];
    return 0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"DidDisconnect:%@", err);
    if (err && _keepConnect) {
        [self sysInfoCallback:@"服务器连接中断，正在重新连接..."];
        [self connectWithRoomID:_roomId groupId:_groupId];
    }
}

@end
