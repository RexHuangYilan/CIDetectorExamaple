//
//  ViewController.m
//  CIDetectorExamaple
//
//  Created by Rex on 2017/2/23.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+HTWDetector.h"
#import "CIFeature+HTWTransform.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (copy, nonatomic) NSArray<UIImage *> *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - 設定相關

-(void)setImages:(NSArray *)images
{
    _images = images;
    if (!images) {
        for (UIView *view in self.imageScrollView.subviews) {
            [view removeFromSuperview];
        }
        for (UIView *view in self.mainImageView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+105*idx, 5, 100, 100)];
        [imageView setImage:image];
        [self.imageScrollView addSubview:imageView];
        self.imageScrollView.contentSize = CGSizeMake(imageView.frame.origin.x+imageView.frame.size.width, self.imageScrollView.frame.size.height);
    }];
}

#pragma mark - 按鈕功能

//人臉辨識
- (IBAction)doFaceButton:(id)sender {
    self.images = nil;
    UIImage *temp = [UIImage imageNamed:@"star4"];
    self.mainImageView.image = temp;
    
    __weak typeof(self) _self = self;
    //還可以辨識閉眼跟笑容喔
    [temp featureOfType:HTWFeatureTypeFace block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (CIFaceFeature *faceFeature in features) {
            CGRect faceBounds = [faceFeature rightBoundsWithSourceImage:ciimage superView:self.mainImageView];
            UIView *faceView = [[UIView alloc] initWithFrame:faceBounds];
            faceView.layer.borderColor = [UIColor redColor].CGColor;
            faceView.layer.borderWidth = 1;
            [self.mainImageView addSubview:faceView];
            
            
            if (faceFeature.hasLeftEyePosition) {
                UIView * leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
                [leftEyeView setCenter:[faceFeature rightPointWithPoint:faceFeature.leftEyePosition sourceImage:ciimage superView:self.mainImageView]];
                leftEyeView.layer.borderWidth = 1;
                leftEyeView.layer.borderColor = [UIColor redColor].CGColor;
                [self.mainImageView addSubview:leftEyeView];
            }
            
            if (faceFeature.hasRightEyePosition) {
                UIView * rightEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
                [rightEyeView setCenter:[faceFeature rightPointWithPoint:faceFeature.rightEyePosition sourceImage:ciimage superView:self.mainImageView]];
                rightEyeView.layer.borderWidth = 1;
                rightEyeView.layer.borderColor = [UIColor redColor].CGColor;
                [self.mainImageView addSubview:rightEyeView];
            }
            
            if (faceFeature.hasMouthPosition) {
                UIView * mouthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
                [mouthView setCenter:[faceFeature rightPointWithPoint:faceFeature.mouthPosition sourceImage:ciimage superView:self.mainImageView]];
                mouthView.layer.borderWidth = 1;
                mouthView.layer.borderColor = [UIColor redColor].CGColor;
                [self.mainImageView addSubview:mouthView];
            }
            
            CIImage * faceImage = [ciimage imageByCroppingToRect:faceFeature.bounds];
            [tempArray addObject:[UIImage imageWithCIImage:faceImage]];

        }
        _self.images = [NSArray arrayWithArray:tempArray];
    }];
}

- (IBAction)doRectangleButton:(id)sender {
    self.images = nil;
    UIImage *temp = [UIImage imageNamed:@"rectangle"];
    self.mainImageView.image = temp;
    __weak typeof(self) _self = self;
    [temp featureOfType:HTWFeatureTypeRectangle block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (CIRectangleFeature *feature in features) {
            
            UIImage *rectangle = [feature imageWithSourceImage:ciimage superView:self.mainImageView];
            UIImageView *drawRectangle = [[UIImageView alloc] initWithImage:rectangle];
            drawRectangle.frame = self.mainImageView.bounds;
            [self.mainImageView addSubview:drawRectangle];
            
            CIImage * faceImage = [ciimage imageByCroppingToRect:feature.bounds];
            [tempArray addObject:[UIImage imageWithCIImage:faceImage]];
        }
        _self.images = [NSArray arrayWithArray:tempArray];
    }];
}

- (IBAction)doQRCodeButton:(id)sender {
    self.images = nil;
    UIImage *temp = [UIImage imageNamed:@"qrcode"];
    self.mainImageView.image = temp;
    __weak typeof(self) _self = self;
    [temp featureOfType:HTWFeatureTypeQRCode block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (CIQRCodeFeature *feature in features) {
            
            CGRect bounds = [feature rightBoundsWithSourceImage:ciimage superView:self.mainImageView];
            UIView *view = [[UIView alloc] initWithFrame:bounds];
            view.layer.borderColor = [UIColor redColor].CGColor;
            view.layer.borderWidth = 1;
            [self.mainImageView addSubview:view];
            
            NSLog(@"%@", feature.messageString);
            [tempArray addObject:[UIImage createImageWithQRCode:feature.messageString length:100]];
        }
        _self.images = [NSArray arrayWithArray:tempArray];
    }];
}

- (IBAction)doTextButton:(id)sender {
    self.images = nil;
    UIImage *temp = [UIImage imageNamed:@"text"];
    self.mainImageView.image = temp;
    __weak typeof(self) _self = self;
    [temp featureOfType:HTWFeatureTypeText block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (CITextFeature *feature in features) {
            
            CGRect bounds = [feature rightBoundsWithSourceImage:ciimage superView:self.mainImageView];
            UIView *view = [[UIView alloc] initWithFrame:bounds];
            view.layer.borderColor = [UIColor redColor].CGColor;
            view.layer.borderWidth = 1;
            [self.mainImageView addSubview:view];
            
            CIImage * faceImage = [ciimage imageByCroppingToRect:feature.bounds];
            [tempArray addObject:[UIImage imageWithCIImage:faceImage]];
        }
        _self.images = [NSArray arrayWithArray:tempArray];
    }];
}


@end
