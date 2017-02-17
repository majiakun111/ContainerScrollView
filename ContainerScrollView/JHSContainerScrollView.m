/*
 OLEContainerScrollView
 
 Copyright (c) 2014 Ole Begemann.
 https://github.com/ole/OLEContainerScrollView
 */

@import QuartzCore;

#import "JHSContainerScrollView.h"


@interface JHSContentView : UIView;

@end

@implementation JHSContentView

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if ([self.superview isKindOfClass:[JHSContainerScrollView class]]) {
        [(JHSContainerScrollView *)self.superview didAddSubviewToContainer:subview];
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if ([self.superview isKindOfClass:[JHSContainerScrollView class]]) {
        [(JHSContainerScrollView *)self.superview willRemoveSubviewFromContainer:subview];
    }
}

@end


@interface JHSContainerScrollView ()

@property (nonatomic, readonly) NSMutableArray *subviewsArray;

@end

@implementation JHSContainerScrollView

- (void)dealloc
{
    // Removing the subviews will unregister KVO observers
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[JHSContentView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
        
        _subviewsArray = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

#pragma mark - Adding and removing subviews

- (void)didAddSubviewToContainer:(UIView *)subview
{
    NSParameterAssert(subview != nil);

    subview.autoresizingMask = UIViewAutoresizingNone;

    [self.subviewsArray addObject:subview];

    if ([subview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)subview;
        scrollView.scrollEnabled = NO;
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld context:nil];
    } else {
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionOld context:nil];
        [subview addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionOld context:nil];
    }
    
    [self setNeedsLayout];
}

- (void)willRemoveSubviewFromContainer:(UIView *)subview
{
    NSParameterAssert(subview != nil);
    
    if ([subview isKindOfClass:[UIScrollView class]]) {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:nil];
    } else {
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) context:nil];
        [subview removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:nil];
    }
    
    [self.subviewsArray removeObject:subview];
    [self setNeedsLayout];
}

#pragma mark - Property

- (void)setSpaceHeaderHeight:(CGFloat)spaceHeaderHeight
{
    if (_spaceHeaderHeight != spaceHeaderHeight) {
        _spaceHeaderHeight = spaceHeaderHeight;
        
        [self setNeedsLayout];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"contentSize"]) {
        // Initiate a layout recalculation only when a subviewʼs frame or contentSize has changed
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            UIScrollView *scrollView = object;
            CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = scrollView.contentSize;
            if (!CGSizeEqualToSize(newContentSize, oldContentSize)) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
            }
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))] ||
              [keyPath isEqualToString:NSStringFromSelector(@selector(bounds))]) {
        UIView *subview = object;
        CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame = subview.frame;
        if (!CGRectEqualToRect(newFrame, oldFrame)) {
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //让contentView始终保持在可视区域的中心
    self.contentView.frame = CGRectMake(0, self.bounds.origin.y + self.spaceHeaderHeight, self.frame.size.width, self.frame.size.height) ; // self.bounds;
    self.contentView.bounds = CGRectMake(0, self.contentOffset.y, self.frame.size.width, self.frame.size.height);   //(CGRect){ self.contentOffset, self.contentView.bounds.size};
    
    CGFloat yOffsetOfCurrentSubview = 0;
    
    for (UIView *subview in self.subviewsArray) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            CGRect frame = scrollView.frame;
            CGPoint contentOffset = scrollView.contentOffset;

            if (self.contentOffset.y < yOffsetOfCurrentSubview) {
                contentOffset.y = 0.0;
                frame.origin.y = yOffsetOfCurrentSubview;
            } else {
                contentOffset.y = self.contentOffset.y - yOffsetOfCurrentSubview;
                frame.origin.y = self.contentOffset.y;
            }

            scrollView.frame = frame;
            scrollView.contentOffset = contentOffset;

            yOffsetOfCurrentSubview += scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
        }
        else {
            CGRect frame = CGRectMake(0, yOffsetOfCurrentSubview, self.contentView.bounds.size.width, subview.frame.size.height);
            subview.frame = frame;
            
            yOffsetOfCurrentSubview += frame.size.height;
        }
    }
    
    CGFloat minContentHeight = self.bounds.size.height - (self.contentInset.top + self.contentInset.bottom) + self.spaceHeaderHeight;

    CGPoint contentOffset = self.contentOffset;
    self.contentSize = CGSizeMake(self.bounds.size.width, fmax(yOffsetOfCurrentSubview, minContentHeight));
    //设置contentSize可能引起contentOffset的变化
    if (!CGPointEqualToPoint(contentOffset, self.contentOffset)) {
        [self setContentOffset:contentOffset];
        [self setNeedsLayout];
    }
}

@end
