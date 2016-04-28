//
//  AdLooper.m
//  AdLooper
//
//  Created by wang xinkai on 16/4/27.
//  Copyright © 2016年 wxk. All rights reserved.
//

#import "AdLooper.h"

#define kSleepTime 2

@interface AdLooper ()
{
    
//    UI
    UICollectionView *_collectionView;
//    Data
    NSMutableArray *_data;
//    循环
    int  _index;
    
    
//  休眠监听器
    
    NSTimer *_timer;
    
    CFRunLoopObserverRef observer;
@public
    BOOL _goToSleep;
    
    

}
@end

@implementation AdLooper




-(instancetype)initWithFrame:(CGRect)frame data:(NSArray *)data{

    if (self = [super initWithFrame:frame]) {
        
        
//        整理收尾数据 分别添加一个收尾数据
        _data = [[NSMutableArray alloc] initWithArray:data];
        [_data addObject:data.firstObject];
        [_data insertObject:data.lastObject atIndex:0];

    }
    return self;
}


-(void)didMoveToSuperview{
    [self loadCollectionView];
    [self loadPageControl];
    [self beginObserve];
}

-(void)loadCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:layout];
    [_collectionView registerClass:[ADCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCellIdent"];

    
    _collectionView.delegate =self;
    _collectionView.dataSource = self;
    _collectionView.hidden = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];

    _collectionView.contentOffset = CGPointMake(self.frame.size.width, 0);
    
    

        


    
}



-(void)loadPageControl{
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, (_data.count-2)*40, 40)];
    
    _pageControl.currentPage = 0;
    
    _pageControl.numberOfPages = _data.count-2;
    
    _pageControl.tintColor = [UIColor greenColor];
    
    
    _pageControl.center = CGPointMake(self.center.x, self.bounds.size.height-40);

    [self addSubview:_pageControl];
    
}

-(int)index{
    return _index;
}

-(void)setIndex:(int) index{
    

    _index = index;
    if (_index>=_data.count-2) {
        _index = 0;
    }
    _pageControl.currentPage = _index;
}

#pragma mark - Collection View Delegate & DataSource


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.index = scrollView.contentOffset.x/scrollView.frame.size.width -1;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x == 0) {
        scrollView.contentOffset = CGPointMake((_data.count-2)*self.frame.size.width, 0);
//        self.index = (int)_data.count-1;
    }else if (scrollView.contentOffset.x == (_data.count-1)*self.frame.size.width){
        scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
//        self.index = 0;
    }
    
}


#pragma mark - CollectionView Delegate && dataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _data.count;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = @"CollectionViewCellIdent";
    
    ADCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [cell setImage:_data[indexPath.row]];
    
    return cell;
    
}



#pragma mark - Runloop 休眠监听


//回调函数
void  myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    
    //    NSLog(@"====== activity：%ld",activity);
    
    
    AdLooper * slf = (__bridge AdLooper *)info;
    
    //    进入休眠
    if (activity == 1UL << 5) {
        
        //        NSLog(@".....call back before waiting activity：%ld",activity);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kSleepTime-0.1) * NSEC_PER_SEC)), dispatch_get_global_queue(1, 1), ^{
            slf->_goToSleep = YES;
            
            
        });
        [slf performSelector:@selector(beginLooper) withObject:nil afterDelay:kSleepTime inModes:@[NSDefaultRunLoopMode]];
        
        
        
    }else if (activity == 1UL << 6){
        //    退出休眠


        
        if (!slf->_goToSleep) {
            
            //            NSLog(@".....call back after waiting activity：%ld",activity);
            [NSObject cancelPreviousPerformRequestsWithTarget:slf selector:@selector(beginLooper) object:nil];
            [NSObject cancelPreviousPerformRequestsWithTarget:slf selector:@selector(play) object:nil];

                    }
        slf->_goToSleep = NO;
    }
    
    
}




-(void)beginObserve{
    
    
    [self addRunLoopObserver];
    
    
}


//进入计时播放

-(void)beginLooper{
    
    
    [self play];

//    进入下一次5秒等待
    [self removeRunLoopObserver];
    [self addRunLoopObserver];
}

-(void)play{
    
     self.index = self.index+1;
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_index+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self layoutIfNeeded];
    
}





-(void)addRunLoopObserver{
    
    // The application uses garbage collection, so noautorelease pool is needed.
    NSRunLoop*myRunLoop = [NSRunLoop currentRunLoop];
    _goToSleep = NO;
    // Create a run loop observer and attach it to the runloop.
    CFRunLoopObserverContext  context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    observer =CFRunLoopObserverCreate(kCFAllocatorDefault,
                                      kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
    
    if (observer)
    {
        CFRunLoopRef    cfLoop = [myRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopCommonModes);
    }
    
    
}
-(void)removeRunLoopObserver{
    //    移除runloop监听
    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
    CFRunLoopRef    cfLoop = [myRunLoop getCFRunLoop];
    if (observer) {
        CFRunLoopRemoveObserver(cfLoop, observer, kCFRunLoopCommonModes);
    }

    
    //移除可能的事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self removeRunLoopObserver];
    
    //    写入数据
    //    [self writeData];
    
    //    移除notification 监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end


@implementation ADCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:_imageView];
        
        
    }
    return self;
}

-(void)setImage:(UIImage *)image{
    
    _imageView.image = image;
}

@end
