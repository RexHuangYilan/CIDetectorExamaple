//
//  UIImage+HTWDetector.h
//  CIDetectorExamaple
//
//  Created by Rex on 2017/2/23.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HTWFeatureType) {
    HTWFeatureTypeFace,         //人臉
    HTWFeatureTypeRectangle,    //矩型
    HTWFeatureTypeQRCode,       //QRCode
    HTWFeatureTypeText,         //文字
};

@interface UIImage(HTWDetector)


/*
 辦識圖片
 type:辦識的種類
 block:辦識完成後回傳
 */
-(void)featureOfType:(HTWFeatureType)type block:(void(^ _Nullable)(NSArray<CIFeature *> * _Nonnull features,CIImage * _Nonnull cimage))block;

/*
 產生一張QRCode
 qrcode:QRCode的內容
 length:圖形的寬高長度
 */
+(UIImage * _Nullable)createImageWithQRCode:(NSString * _Nonnull)qrcode length:(CGFloat)length;

@end

@interface CIImage(HTWDetector)

//CIImage座標轉換UIImage
@property(nonatomic,readonly) CGAffineTransform toImageTransform;

@end
