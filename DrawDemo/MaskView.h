//
//  MaskView.h
//  DrawDemo
//
//  Created by sunhaosheng on 4/7/16.
//  Copyright © 2016 hs sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchView.h"

@interface MaskView : UIView
/**
 *  路径数组
 */
@property (nonatomic,strong) NSMutableArray<PathModel *> *paths;
/**
 *  当前的渲染方式 clear or stroke
 */
@property (nonatomic,assign) BlendMode currentBlendMode;
/**
 *  绘制路径的宽度 default 10
 */
@property (nonatomic,assign) CGFloat lineWidth;
/**
 *  当前绘制的画笔类型
 */
@property (nonatomic,assign) StrokeType currentStrokeType;

/**
 *  渐变的程度
 */
@property (nonatomic,assign) CGFloat gradientRate;

/**
 *  重置mask
 */
- (void)clearPath;
/**
 *  根据指定mask的路径 绘制当前mask的路径（大图保存时使用）
 *
 *  @param maskView 指定的mask
 */
- (void)drawMaskWithMaskView:(MaskView *)maskView ;

@end
