//
//  MaskView.m
//  DrawDemo
//
//  Created by sunhaosheng on 4/7/16.
//  Copyright © 2016 hs sun. All rights reserved.
//

#import "MaskView.h"

@interface MaskView()

@property (nonatomic,weak) TouchView *touchView;

@property (nonatomic,strong) PathModel *currentDrawingPath;

@property (nonatomic,strong) UIImage *mainImage;

@end

@implementation MaskView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _currentBlendMode = BlendModeClear;
        _currentStrokeType = StrokeTypeGradient;
        _lineWidth = 10;
        _gradientRate = 0.5;
    };
    return self;
}

- (void)didMoveToSuperview {
    if (self.superview) {
        self.superview.userInteractionEnabled = YES;
        if (!self.touchView) {
            TouchView *touchView = [[TouchView alloc] initWithFrame:self.bounds andMovedHandle:^(NSMutableArray *paths) {
                _paths = paths;
                _currentDrawingPath = [paths lastObject];
                [self setNeedsDisplay];
            } MovedCompletion:^{
                [self drawPathCompletion];
            }];
            touchView.backgroundColor = [UIColor clearColor];
            self.touchView = touchView;
            [self.superview addSubview:touchView];
        }
    } else {
        [self.touchView removeFromSuperview];
    }
}

- (void)drawPathCompletion {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    
    CGContextFlush(context);
    self.mainImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.layer.contents = (id)self.mainImage.CGImage;
}


- (void)setCurrentBlendMode:(BlendMode)currentBlendMode {
    _currentBlendMode = currentBlendMode;
    self.touchView.currentBlendMode = currentBlendMode;
}

- (void)setCurrentStrokeType:(StrokeType)currentStrokeType {
    _currentStrokeType = currentStrokeType;
    self.touchView.currentStrokeType = currentStrokeType;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.touchView.lineWidth = lineWidth;
}

- (void)setGradientRate:(CGFloat)gradientRate {
    _gradientRate = gradientRate;
    self.touchView.gradientRate = gradientRate;
}

- (void)clearPath {
    [self.paths removeAllObjects];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, self.bounds);
    self.layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    self.mainImage = nil;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    if (!self.mainImage) {
        CGContextFillRect(context, self.bounds);
    }
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, 0.0f, -self.frame.size.height);
    CGContextDrawImage(context, rect, self.mainImage.CGImage);
    CGContextRestoreGState(context);
    
    if (self.currentDrawingPath.strokeType == StrokeTypeNormal) {
        [self strokeNormalPathInContext:context WithPathModel:self.currentDrawingPath];
    } else if(self.currentDrawingPath.strokeType == StrokeTypeGradient) {
        [self strokeGradientPathInContext:context WithPathModel:self.currentDrawingPath drawing:YES];
    }
}

- (void)strokeNormalPathInContext:(CGContextRef)context WithPathModel:(PathModel *)model {
    CGContextSetLineWidth(context, model.lineWidth);
    if (model.blendMode == BlendModeStroke) {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextSetRGBStrokeColor(context, 1, 0, 0,1);
    } else {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetRGBStrokeColor(context, 1, 0, 0,0);
    }
    [model.points enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj CGPointValue];
        if (idx == 0) {
            CGContextMoveToPoint(context, point.x, point.y);
        } else {
//            CGPoint currentPoint = CGContextGetPathCurrentPoint(context);
//            CGPoint midPoint = CGPointMake((point.x + currentPoint.x)/2, (point.y + currentPoint.y)/2);
//            CGPoint controlPoint = midPoint;
//            CGFloat k = (point.y - currentPoint.y)/(point.x - currentPoint.x);
//            CGFloat b = midPoint.y + 1/k*midPoint.x;
//            if (currentPoint.y > point.y) {
//                if (currentPoint.x - point.x > 0) {
//                    CGFloat x = midPoint.x - 1;
//                    CGFloat y = -1/k*x+b;
//                    controlPoint = CGPointMake(x, y);
//                } else {
//                    CGFloat x = midPoint.x - 1;
//                    CGFloat y = -1/k*x+b;
//                    controlPoint = CGPointMake(x, y);
//                }
//            } else if(currentPoint.y < point.y) {
//                if (currentPoint.x - point.x > 0) {
//                    CGFloat x = midPoint.x + 1;
//                    CGFloat y = -1/k*x+b;
//                    controlPoint = CGPointMake(x, y);
//                } else {
//                    CGFloat x = midPoint.x + 1;
//                    CGFloat y = -1/k*x+b;
//                    controlPoint = CGPointMake(x, y);
//                }
//            }
//            CGContextAddQuadCurveToPoint(context, controlPoint.x,controlPoint.y, point.x, point.y);
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }];
    CGContextStrokePath(context);
}

- (void)strokeGradientPathInContext:(CGContextRef)ctx WithPathModel:(PathModel *)model drawing:(BOOL)isDrawing {
    NSInteger startIndex = 0;
    NSInteger endIndex = 0;
    NSInteger count = model.points.count;
    if (isDrawing) {
        if (count < 4) {
            return;
        }
        startIndex = count - 4;
        endIndex = count - 2;
    } else {
        startIndex = 0;
        endIndex = count - 1;
    }
    for (NSInteger i = startIndex; i < endIndex; i++) {
        CGPoint fromPoint = [model.points[i] CGPointValue];
        CGPoint toPoint = [model.points[i + 1] CGPointValue];
        CGFloat dx = toPoint.x - fromPoint.x;
        CGFloat dy = toPoint.y - fromPoint.y;
        CGFloat len = sqrtf((dx*dx)+(dy*dy));
        CGFloat ix = dx/len;
        CGFloat iy = dy/len;
        CGPoint point = fromPoint;
        int ilen = (int)len;
        for (int i = 0; i < ilen; i++) {
            CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
            size_t num_locations = 2;
            CGFloat* comp = (CGFloat *)CGColorGetComponents([UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor);
            CGFloat locations[2] = {1.0f,0.0f};
            CGFloat fc = sinf(((model.gradientRate/5.0f)*M_PI)/2.0f);
            CGFloat colors[8] = { comp[0], comp[1], comp[2], 0.0f, comp[0], comp[1], comp[2], model.gradientRate};
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
            if (model.blendMode == BlendModeClear) {
                CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
            } else {
                CGContextSetBlendMode(ctx, kCGBlendModeNormal);
            }
            CGContextDrawRadialGradient(ctx, gradient, point, 0.0f, point, model.lineWidth, 0);
            CFRelease(gradient);
            CFRelease(colorspace);  
            point.x += ix;
            point.y += iy;
        }
    }
    if (isDrawing) {
        [self drawPathCompletion];
    }
}
/**
 *  性能差
 *
 */
//- (void)strokeGradientPathInContext:(CGContextRef)context WithPathModel:(PathModel *)model {
//    for (int i = 0; i < model.points.count - 1;i++) {
//        CGPoint fromPoint = [model.points[i] CGPointValue];
//        CGPoint toPoint = [model.points[i + 1] CGPointValue];
//        CGFloat dx = toPoint.x - fromPoint.x;
//        CGFloat dy = toPoint.y - fromPoint.y;
//        CGFloat len = sqrtf((dx*dx)+(dy*dy));
//        CGFloat ix = dx/len;
//        CGFloat iy = dy/len;
//        CGPoint point = fromPoint;
//        int ilen = (int)len;
//        
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        for (int i = 0; i < ilen; i++) {
//            if (!model.gradientImage) {
//                model.gradientImage = self.gradientImage;
//            }
//            CGRect rect = CGRectMake(point.x - (model.gradientImage.size.width / 2.0f),
//                                     point.y - (model.gradientImage.size.height / 2.0f),
//                                     model.gradientImage.size.width, model.gradientImage.size.height);
//            if (model.blendMode == BlendModeClear) {
//                CGContextSetBlendMode(ctx, kCGBlendModeDestinationOut);
//            } else {
//                CGContextSetBlendMode(ctx, kCGBlendModeNormal);
//            }
//            CGContextFlush(ctx);
//            CGContextDrawImage(ctx, rect, model.gradientImage.CGImage);
//
//            point.x += ix;
//            point.y += iy;
//        }
//    }
//}

- (void)drawMaskWithMaskView:(MaskView *)maskView {
    if (self == maskView) {
        return;
    }
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextFillRect(context, self.bounds);
    CGFloat ratio = CGRectGetWidth(self.bounds)/CGRectGetWidth(maskView.bounds);
    for (PathModel *model in maskView.paths) {
        PathModel *newModel = [[PathModel alloc] init];
        [model.points enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = [obj CGPointValue];
            point = CGPointMake(point.x * ratio, point.y * ratio);
            NSValue *pointValue = [NSValue valueWithCGPoint:point];
            [newModel.points addObject:pointValue];
        }];
        newModel.blendMode = model.blendMode;
        newModel.strokeType = model.strokeType;
        newModel.lineWidth = model.lineWidth * ratio;
        newModel.gradientRate = model.gradientRate - model.gradientRate*ratio*0.2;
        if (newModel.strokeType == StrokeTypeNormal) {
            [self strokeNormalPathInContext:context WithPathModel:newModel];
        } else {
            [self strokeGradientPathInContext:context WithPathModel:newModel drawing:NO];
        }
    }
    self.mainImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end
