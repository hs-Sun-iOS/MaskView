//
//  TouchView.h
//  DrawDemo
//
//  Created by sunhaosheng on 4/20/16.
//  Copyright © 2016 hs sun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, StrokeType) {
    StrokeTypeNormal,
    StrokeTypeGradient,
};

typedef NS_ENUM(NSUInteger, BlendMode) {
    BlendModeStroke,
    BlendModeClear,
};

@interface TouchView : UIView

@property (nonatomic,assign) BlendMode currentBlendMode;

@property (nonatomic,assign) CGFloat lineWidth; //default 10

@property (nonatomic,assign) StrokeType currentStrokeType;

@property (nonatomic,assign) CGFloat gradientRate;

/**
 *  touchView的初始化方法
 *
 *  @param frame       frame
 *  @param movedHandle 移动事件的回调block
 *  @param completion  触摸结束事件的回调block
 *
 *  @return TouchView Instance
 */
- (instancetype)initWithFrame:(CGRect)frame andMovedHandle:(void (^)(NSMutableArray *))movedHandle MovedCompletion:(void(^)()) completion;

@end

@interface PathModel : NSObject

@property (nonatomic,strong) NSMutableArray *points;

@property (nonatomic,assign) BlendMode blendMode;

@property (nonatomic,assign) StrokeType strokeType;

@property (nonatomic,assign) CGFloat lineWidth;

@property (nonatomic,assign) CGFloat gradientRate;

@end
