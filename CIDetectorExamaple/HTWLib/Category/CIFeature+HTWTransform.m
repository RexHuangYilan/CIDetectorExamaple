//
//  CIFeature+HTWTransform.m
//  CIDetectorExamaple
//
//  Created by Rex on 2017/2/24.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "CIFeature+HTWTransform.h"

@implementation CIFeature(HTWTransform)

-(CGRect)rightBoundsWithSourceImage:(CIImage *)image superView:(UIImageView *)view
{
    //CIImage座標與UIImage座標的轉換
    CGAffineTransform transform = image.toImageTransform;
    
    //CIImage辨識區塊的邊界
    CGRect bounds = self.bounds;
    
    //轉換為UIImage辨識區塊的邊界
    CGRect faceBounds = CGRectApplyAffineTransform(bounds,transform);
    
    //依父層imageView大小調整邊界的比例
    CGSize viewSize = view.bounds.size;
    CGSize ciImageSize = image.extent.size;
    //取得比例
    CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height);
    //取得x座標偏移
    CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
    //取得y座標偏移
    CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
    
    //調整比例
    faceBounds = CGRectApplyAffineTransform(faceBounds,CGAffineTransformMakeScale(scale, scale));
    //座標偏移
    faceBounds.origin.x += offsetX;
    faceBounds.origin.y += offsetY;
    
    return faceBounds;
}

-(CGPoint)rightPointWithPoint:(CGPoint)point sourceImage:(CIImage *)image superView:(UIImageView *)view
{
    //CIImage座標與UIImage座標的轉換
    CGAffineTransform transform = image.toImageTransform;
    
    //轉換為UIImage辨識區塊的點
    point = CGPointApplyAffineTransform(point,transform);
    
    //依父層imageView大小調整邊界的比例
    CGSize viewSize = view.bounds.size;
    CGSize ciImageSize = image.extent.size;
    //取得比例
    CGFloat scale = MIN(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height);
    //取得x座標偏移
    CGFloat offsetX = (viewSize.width - ciImageSize.width * scale) / 2;
    //取得y座標偏移
    CGFloat offsetY = (viewSize.height - ciImageSize.height * scale) / 2;
    
    //調整比例
    point = CGPointApplyAffineTransform(point,CGAffineTransformMakeScale(scale, scale));
    //座標偏移
    point.x += offsetX;
    point.y += offsetY;
    
    return point;
}

@end

@implementation CIRectangleFeature(HTWTransform)

-(UIImage *)imageWithSourceImage:(CIImage *)image superView:(UIImageView *)view
{
    CGPoint tempTopLeft = [self rightPointWithPoint:self.topLeft sourceImage:image superView:view];
    CGPoint tempTopRight = [self rightPointWithPoint:self.topRight sourceImage:image superView:view];
    CGPoint tempBottomLeft = [self rightPointWithPoint:self.bottomLeft sourceImage:image superView:view];
    CGPoint tempBottomRight = [self rightPointWithPoint:self.bottomRight sourceImage:image superView:view];
    
    //設定畫布大小
    UIGraphicsBeginImageContext(view.frame.size);
    //開始設定畫容
    CGContextRef context = UIGraphicsGetCurrentContext();
    //設定筆色
    CGContextSetRGBStrokeColor(context,0,0,1,1.0);
    //設定填滿色
    CGContextSetRGBFillColor(context,0,0,1,0.3);
    //設定線條粗細
    CGContextSetLineWidth(context, 3.0);
    //設定坐標
    CGPoint aPoints[4];
    aPoints[0] = tempTopLeft;
    aPoints[1] = tempTopRight;
    aPoints[2] = tempBottomRight;
    aPoints[3] = tempBottomLeft;
    //將座標加入直線
    CGContextAddLines(context, aPoints, 4);
    //依座標閉合內容
    CGContextClosePath(context);
    //依路徑畫線與填滿
    CGContextDrawPath(context, kCGPathFillStroke);
    //將畫布內容存為UIImage
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    //結束畫布
    UIGraphicsEndImageContext();
    
    return temp;
}

@end
