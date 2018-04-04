//
//  TouchView.m
//  DrawDemo
//
//  Created by sunhaosheng on 4/20/16.
//  Copyright © 2016 hs sun. All rights reserved.
//

#import "TouchView.h"

@interface TouchView ()

@property (nonatomic,copy) void(^MovedHandle)(NSMutableArray *paths);

@property (nonatomic,copy) void(^MoveCompletion)();

@property (nonatomic,strong) NSMutableArray<PathModel *> *paths;

@end

@implementation TouchView

- (instancetype)initWithFrame:(CGRect)frame andMovedHandle:(void (^)(NSMutableArray *))movedHandle MovedCompletion:(void (^)())completion {
    self = [super initWithFrame:frame];
    if (self) {
        _MovedHandle = movedHandle;
        _MoveCompletion = completion;
        _paths = [NSMutableArray array];
        _currentBlendMode = BlendModeClear;
        _currentStrokeType = StrokeTypeGradient;
        _gradientRate = 0.5;
        _lineWidth = 10.0f;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    UIBezierPath *path = [UIBezierPath bezierPath];
    PathModel *model = [[PathModel alloc] init];
    NSValue *point = [NSValue valueWithCGPoint:[self convertPoint:[touch locationInView:self] fromView:self.superview]];
    [model.points addObject:point];
    model.lineWidth = self.lineWidth;
    model.blendMode = self.currentBlendMode;
    model.strokeType = self.currentStrokeType;
    model.gradientRate = self.gradientRate;
    [self.paths addObject:model];
    CGPoint startPoint = [self convertPoint:[touch locationInView:self] fromView:self.superview];
    [path moveToPoint:startPoint];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [self convertPoint:[touch locationInView:self] fromView:self.superview];
    NSValue *point = [NSValue valueWithCGPoint:currentPoint];
    [[[self.paths lastObject] points] addObject:point];
    if (self.MovedHandle) {
        self.MovedHandle(self.paths);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.MoveCompletion) {
        self.MoveCompletion();
    }
}

@end

@implementation PathModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _points = [NSMutableArray array];
    }
    return self;
}

@end
