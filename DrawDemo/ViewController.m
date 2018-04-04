//
//  ViewController.m
//  DrawDemo
//
//  Created by sunhaosheng on 4/6/16.
//  Copyright © 2016 hs sun. All rights reserved.
//

#import "ViewController.h"
#import "MaskView.h"
#import "TouchView.h"


#pragma mark - Private

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@interface ViewController ()
{
    UInt32 *originInputPixels;
}

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,weak) MaskView *maskView;

@property (nonatomic,strong) NSMutableArray *paths;

@property (nonatomic,weak) TouchView *touchView;

@property (nonatomic,assign) BOOL isClear;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib
    self.view.backgroundColor = [UIColor yellowColor];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"example2"]];
    self.imageView.center = self.view.center;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.imageView];
    MaskView *view = [[MaskView alloc] initWithFrame:CGRectMake(0, 0,self.imageView.frame.size.width, self.imageView.frame.size.height)];
    self.maskView = view;
    self.imageView.maskView = view;
//    [self.view addSubview:view];
    
    
}


- (NSMutableArray *)paths {
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
- (IBAction)saveBtnClick:(id)sender {
    UIGraphicsBeginImageContext(CGSizeMake(CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2)];
    view.backgroundColor = [UIColor yellowColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.imageView.bounds) * 2, CGRectGetHeight(self.imageView.bounds) * 2)];
    imageView.image = [UIImage imageNamed:@"example2"];
    imageView.center = CGPointMake(self.imageView.center.x * 2, self.imageView.center.y * 2);
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    MaskView *maskView = [[MaskView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame))];
    [maskView drawMaskWithMaskView:self.maskView];
    imageView.maskView = maskView;
    
    
    [view addSubview:imageView];
    
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmep.png"];
    NSLog(@"%@",path);
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"%@",image);
    
}
- (IBAction)clearBtnClick:(id)sender {
    self.maskView.currentBlendMode = BlendModeClear;
}
- (IBAction)fillBtnClick:(id)sender {
    self.maskView.currentBlendMode = BlendModeStroke;
}
- (IBAction)nomalStrokeBtnClick:(id)sender {
    self.maskView.currentStrokeType = StrokeTypeNormal;
}
- (IBAction)gradientStrokeBtnClick:(id)sender {
    self.maskView.currentStrokeType = StrokeTypeGradient;
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.maskView.lineWidth = slider.value + 10;
}
- (IBAction)gradientRateValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    self.maskView.gradientRate = slider.value;
}
- (IBAction)resetBtnClick:(id)sender {
    [self.maskView clearPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
