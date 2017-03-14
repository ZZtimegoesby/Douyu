//
//  STTModel.h
//  danmu
//
//  Created by 王博 on 16/4/22.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTModel : NSObject

@property (nonatomic) NSString * cid; //弹幕唯一ID
@property (nonatomic) NSString * ct; //客户端类型
@property (nonatomic) NSString * ic; //头像地址
@property (nonatomic) NSString * level; //用户等级
@property (nonatomic) NSString * nn; //发送者昵称
@property (nonatomic) NSString * rid; //所登录的房间号
@property (nonatomic) NSString * txt; //弹幕文本内容
@property (nonatomic) NSString * type; //消息类型
@property (nonatomic) NSString * uid; //发送者id
@property (nonatomic) NSString * gt; //礼物头衔
@property (nonatomic) NSString * col; //颜色
@property (nonatomic) NSString * str; //用户战斗力
@property (nonatomic) NSString * gfid; //礼物 id
@property (nonatomic) NSString * gs; //礼物显示样式
@property (nonatomic) NSString * dw; //主播体重
@property (nonatomic) NSString * gfcnt; //礼物个数
@property (nonatomic) NSString * hits; //礼物连击次数
@property (nonatomic) NSString * dlv; //酬勤等级
@property (nonatomic) NSString * dc; //酬勤数量
@property (nonatomic) NSString * bdlv; //最高酬勤等级
@property (nonatomic) NSString * rg; //房间权限组
@property (nonatomic) NSString * pg; //平台权限组
@property (nonatomic) NSString * rpid; //红包 id
@property (nonatomic) NSString * gid; //分组号
@property (nonatomic) NSString * slt; //红包开启剩余时间
@property (nonatomic) NSString * elt; //红包销毁剩余时间
@property (nonatomic) NSString * cnt; //赠送数量
@property (nonatomic) NSString * lev; //赠送酬勤等级
@property (nonatomic) NSString * sui; //用户信息序列化字符串
@property (nonatomic) NSString * roomid; //房间号
@property (nonatomic) NSString * tick; //当前 unix 时间戳
@property (nonatomic) NSString * ts; //排行榜更新时间戳
@property (nonatomic) NSString * list_all; //总榜
@property (nonatomic) NSString * list; //周榜
@property (nonatomic) NSString * list_day; //日榜
@property (nonatomic) NSString * crk; //当前排名
@property (nonatomic) NSString * lrk; //上次排名
@property (nonatomic) NSString * rs; //排名变化
@property (nonatomic) NSString * gold_cost; //当前贡献值

@end
