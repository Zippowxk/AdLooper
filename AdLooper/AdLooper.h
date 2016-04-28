//
//  AdLooper.h
//  AdLooper
//
//  Created by wang xinkai on 16/4/27.
//  Copyright © 2016年 wxk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdLooper : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

/*tableview 横直 或者使用collectionview 都是可取的*/

@property (nonatomic,strong) UIPageControl *pageControl;


-(instancetype)initWithFrame:(CGRect)frame data:(NSArray *)data;
@end


@interface ADCollectionViewCell : UICollectionViewCell
{
    
    UIScrollView *_scrollView;
    UIImageView *_imageView;
}

@property (nonatomic,strong) NSString* urlString;
@property (nonatomic,strong) UIImage *image;

@end