# 圖形辨識小程式



## 圖形辨識

`UIImage+HTWDetector.h`
辨識圖片的擴充

將可以用的辨識集合成enum
```objectivec
typedef NS_ENUM(NSUInteger, HTWFeatureType) {
    HTWFeatureTypeFace,         //人臉
    HTWFeatureTypeRectangle,    //矩型
    HTWFeatureTypeQRCode,       //QRCode
    HTWFeatureTypeText,         //文字
};
```
圖形辨識步驟:

* 建立原生辨識元件
```objectivec
	CIDetector *detector = [CIDetector detectorOfType:[self featureWithType:type] context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
```
* 將UIImage轉換為CIImage
```objectivec
	CIImage *image = [[CIImage alloc] initWithImage:self];
```
* 其實就是這一行指令在作圖形辨識(這會很花時間喔)
```objectivec
	NSArray *features = [detector featuresInImage:image];
```
這個小範例就是將這3個步驟封裝成一個`category`

提供的method如下
```objectivec
/*
辨識圖片
 type:辦識的種類
 block:辨識完成後回傳
 */
-(void)featureOfType:(HTWFeatureType)type block:(void(^ _Nullable)(NSArray<CIFeature *> * _Nonnull features,CIImage * _Nonnull cimage))block;
```

***
### 範例
首先當然是先載入`cateogry`，並建立使用的圖片
```objectivec
#import "UIImage+HTWDetector.h"
…
UIImage *temp = [UIImage imageNamed:@"star4"];	//載入圖片
```

* CIDetectorTypeFace			人臉辨識
```objectivec
[temp featureOfType:HTWFeatureTypeFace block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
	//辨識後要處理的事情
    …
}];
```
* CIDetectorTypeRectangle		矩形辨識
```objectivec
[temp featureOfType:HTWFeatureTypeRectangle block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
	//辨識後要處理的事情
    …
}];
```
* CIDetectorTypeQRCode		QRCode辨識與產生
```objectivec
[temp featureOfType:HTWFeatureTypeQRCode block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
	//辨識後要處理的事情
    …
}];
```
* CIDetectorTypeText			文字辨識
```objectivec
[temp featureOfType:HTWFeatureTypeText block:^(NSArray<CIFeature *> * _Nonnull features,CIImage *ciimage) {
	//辨識後要處理的事情
    …
}];
```
</br>
</br>
## 座標轉換
`UIImage+HTWDetector.h`
CIImage 座標轉換為 UIImageView 的對應座標
由於CIImage的座標與UIImageView的座標是上下相反，需要轉換，所以對`CIImage`擴充了一個`category`，新增`property`
```objectivec
//CIImage座標轉換UIImage
@property(nonatomic,readonly) CGAffineTransform toImageTransform;
```
實作方法為:
```objectivec
//取得圖片大小
CGSize ciImageSize = self.extent.size;
//上下相反
CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
//對y軸作延伸，長度為原圖高度
transform = CGAffineTransformTranslate(transform, 0, -ciImageSize.height);
return transform;
```
只有這樣還不夠，還需要實際呈現的view才行
`CIFeature+HTWTransform.h`
新增兩個方法:
```objectivec
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
```
實作方法為:
```objectivec
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
```
***
### 範例 - QRCode
首先當然是先載入`cateogry`，再辨識完QRCode後使用
```objectivec
#import "CIFeature+HTWTransform.h"
…
for (CIQRCodeFeature *feature in features) {
	//取得正確座標
    CGRect bounds = [feature rightBoundsWithSourceImage:ciimage superView:self.mainImageView];
    //依座標建立一個有紅框的view
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.borderWidth = 1;
    [self.mainImageView addSubview:view];

    //建立QRCode
    [tempArray addObject:[UIImage createImageWithQRCode:feature.messageString length:100]];
        }
```