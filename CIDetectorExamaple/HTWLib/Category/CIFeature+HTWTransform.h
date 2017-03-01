//
//  CIFeature+HTWTransform.h
//  CIDetectorExamaple
//
//  Created by Rex on 2017/2/24.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIImage+HTWDetector.h"
#import <CoreImage/CoreImage.h>

@interface CIFeature(HTWTransform)

/*
 取得在UIImageView的相對區塊
 image:原始的圖片
 view:父層的UIImageView
 */
-(CGRect)rightBoundsWithSourceImage:(CIImage *)image superView:(UIImageView *)view;

/*
 取得在UIImageView的相對座標
 point:座標
 image:原始的圖片
 view:父層的UIImageView
 */
-(CGPoint)rightPointWithPoint:(CGPoint)point sourceImage:(CIImage *)image superView:(UIImageView *)view;
@end

@interface CIRectangleFeature(HTWTransform)

/*
 取得辦識區塊的圖片
 image:原始的圖片
 view:父層的UIImageView
 */
-(UIImage *)imageWithSourceImage:(CIImage *)image superView:(UIImageView *)view;

@end
