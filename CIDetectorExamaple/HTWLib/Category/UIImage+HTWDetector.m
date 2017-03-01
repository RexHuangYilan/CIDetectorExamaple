//
//  UIImage+HTWDetector.m
//  CIDetectorExamaple
//
//  Created by Rex on 2017/2/23.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIImage+HTWDetector.h"

@implementation UIImage(HTWDetector)

-(void)featureOfType:(HTWFeatureType)type block:(void(^ _Nullable)(NSArray<CIFeature *> * _Nonnull features,CIImage * _Nonnull cimage))block
{
    //建立辨識元件
    CIDetector *detector = [CIDetector detectorOfType:[self featureWithType:type] context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //轉換為CIImage
    CIImage *image = [[CIImage alloc] initWithImage:self];
    //使用副線程，不會主線程會塞住
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *features;
        if (type == HTWFeatureTypeFace) {
            /*
             CIDetectorImageOrientation  圖片方向
             CIDetectorEyeBlink          辨識閉眼
             CIDetectorSmile             辨識笑容
             CIDetectorFocalLength       焦距
             CIDetectorAspectRatio       矩形寬高比
             CIDetectorReturnSubFeatures 是否辨識子特徵
             */
            features = [detector featuresInImage:image options:@{
                                                                 CIDetectorEyeBlink:@(YES),
                                                                 CIDetectorSmile:@(YES),
                                                                 }];
        }else{
            features = [detector featuresInImage:image];
        }
        //回到主線程，使畫面更新
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(features,image);
            }
        });
    });
}

-(NSString *)featureWithType:(HTWFeatureType)type
{
    NSString *typeString;
    switch (type) {
        case HTWFeatureTypeRectangle:
            typeString = CIDetectorTypeRectangle;
            break;
        case HTWFeatureTypeQRCode:
            typeString = CIDetectorTypeQRCode;
            break;
        case HTWFeatureTypeText:
            typeString = CIDetectorTypeText;
            break;
        case HTWFeatureTypeFace:
        default:
            typeString = CIDetectorTypeFace;
            break;
    }
    return typeString;
}

+(UIImage * _Nullable)createImageWithQRCode:(NSString * _Nonnull)qrcode length:(CGFloat)length
{
    if (length == 0) {
        return nil;
    }
    
    NSData *data = [qrcode dataUsingEncoding:NSISOLatin1StringEncoding]; //NSISOLatin1StringEncoding編碼
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = filter.outputImage;
    CGFloat scale = length / outputImage.extent.size.width;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale); //放大到適合大小
    outputImage = [outputImage imageByApplyingTransform:transform];
    
    //產生圖片
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *qrCodeImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return qrCodeImage;
}

@end

@implementation CIImage(HTWDetector)

-(CGAffineTransform)toImageTransform
{
    //取得圖片大小
    CGSize ciImageSize = self.extent.size;
    //上下相反
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    //對y軸作延伸，長度為原圖高度
    transform = CGAffineTransformTranslate(transform, 0, -ciImageSize.height);
    return transform;
}

@end
