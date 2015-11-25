//
//  LPHPageBar.m
//  LPMultiViewControllerDemo
//
//  Created by XuYafei on 15/11/9.
//  Copyright © 2015年 loopeer. All rights reserved.
//

#import "LPHPageBar.h"
#import "LPHPageBarItem.h"

static CGFloat _textEdgeInsert = 25;
static CGFloat _badgeEdgeInsert = 4;
static CGFloat _badgeRadius = 8;
static const NSInteger _viewTag = 123;
static const NSInteger _labelTag = 456;
static const NSInteger _badgeViewTag = 789;
static const CGFloat _duration = 0.25;

@implementation LPHPageBar {
    UIScrollView *_scrollView;
    NSMutableArray<UIView *> *_itemViews;
    UIView *_selectedView;
    UIView *_indicatorView;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray array];
        _textColor = [UIColor grayColor];
        self.backgroundColor = [UIColor whiteColor];
        _itemFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.itemHeight = 36;
        self.indicatorHeight = 2;
        _offsetScale = 0;
        _topViewRect = CGRectZero;
    }
    return self;
}

- (void)reloadViews {
    if (_scrollView) {
        [_scrollView removeFromSuperview];
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = self.backgroundColor;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    [self autosizeIfNeeded];
    NSInteger sumWidth = 0;
    for (int i = 0; i < _items.count; i++) {
        if (_items[i].itemWidth == 0) {
            _items[i].itemWidth = [self stringWidth:_items[i].title].width + _textEdgeInsert * 2;
        }
        if (_items[i].indicatorWidth == 0) {
            _items[i].indicatorWidth = _items[i].itemWidth;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(sumWidth, 0, _items[i].itemWidth, _itemHeight)];
        view.backgroundColor = self.backgroundColor;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [view addGestureRecognizer:tapGesture];
        view.tag = _viewTag + i;
        if (i == 0) {
            _selectedView = view;
        }
        
        if (!_items[i].customView) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height - _indicatorHeight)];
            label.numberOfLines = 1;
            label.text = _items[i].title;
            label.textAlignment = NSTextAlignmentCenter;
            if (i == 0) {
                label.textColor = self.tintColor;
            } else {
                label.textColor = _textColor;
            }
            label.font = _itemFont;
            label.tag = _labelTag;
            label.backgroundColor = [UIColor clearColor];
            
            UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _badgeRadius, _badgeRadius)];
            badge.center = CGPointMake(label.bounds.size.width - _textEdgeInsert + _badgeEdgeInsert + _badgeRadius / 2, label.center.y);
            badge.layer.cornerRadius = _badgeRadius / 2;
            badge.layer.masksToBounds = YES;
            badge.tag = _badgeViewTag;
            if (_items[i].showBadge) {
                badge.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:64.0/255.0 blue:63.0/255.0 alpha:1];
            } else {
                badge.backgroundColor = [UIColor clearColor];
            }
            
            [view addSubview:label];
            [view addSubview:badge];
        } else {
            [view addSubview:_items[i].customView];
        }
        
        [_scrollView addSubview:view];
        [_itemViews addObject:view];
        _items[i].pageBar = self;
        
        sumWidth += view.bounds.size.width;
    }
    _scrollView.contentSize = CGSizeMake(sumWidth, 0);
    
    _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _indicatorView.frame = CGRectMake(0, _itemViews[0].bounds.size.height, _items[0].indicatorWidth, _indicatorHeight);
    _indicatorView.backgroundColor = self.tintColor;
    [_scrollView addSubview:_indicatorView];
}

#pragma mark - Accessors

- (void)setTopViewRect:(CGRect)topViewRect {
    _topViewRect = topViewRect;
    self.frame = CGRectMake(0, _topViewRect.size.height, _topViewRect.size.width, _itemHeight + _indicatorHeight);
}

- (void)setItemHeight:(CGFloat)itemHeight {
    _itemHeight = itemHeight;
    self.frame = CGRectMake(0, _topViewRect.size.height, _topViewRect.size.width, _itemHeight + _indicatorHeight);
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    self.frame = CGRectMake(0, _topViewRect.size.height, _topViewRect.size.width, _itemHeight + _indicatorHeight);
}

- (void)setItems:(NSArray<LPHPageBarItem *> *)items {
    _items = items;
    [self reloadViews];
}

- (void)setOffsetScale:(CGFloat)offsetScale {
    _offsetScale = offsetScale;
    NSInteger nextCount = _offsetScale / fabs(_offsetScale);
    //TOREFACTOR
    if (_selectedView.tag - _viewTag + nextCount > _items.count - 1
        || _selectedView.tag - _viewTag + nextCount < 0) {
        nextCount = 0;
    }
    UIView *nextView = _itemViews[_selectedView.tag - _viewTag + nextCount];
    CGFloat widthOffset = (_items[nextView.tag - _viewTag].indicatorWidth - _items[_selectedView.tag - _viewTag].indicatorWidth) * fabs(_offsetScale);
    _indicatorView.frame = CGRectMake(_indicatorView.frame.origin.x,
                                      _indicatorView.frame.origin.y,
                                      _items[_selectedView.tag - _viewTag].indicatorWidth + widthOffset,
                                      _indicatorView.frame.size.height);
    
    CGFloat offset = (_selectedView.bounds.size.width + nextView.bounds.size.width) / 2 * _offsetScale;
    _indicatorView.center = CGPointMake(_selectedView.center.x + offset, _indicatorView.center.y);
    
    CGFloat leftEdge = _scrollView.contentOffset.x;
    CGFloat rightEdge = leftEdge + self.bounds.size.width;
    CGFloat indicatorLeft = _indicatorView.frame.origin.x;
    CGFloat indicatorRight = indicatorLeft + _indicatorView.frame.size.width;
    if (indicatorRight > rightEdge) {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + (indicatorRight - rightEdge),
                                                _scrollView.contentOffset.y);
    } else if (indicatorLeft < leftEdge) {
        _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x - (leftEdge - indicatorLeft),
                                                _scrollView.contentOffset.y);
    }
    
    UILabel *nextLabel = [nextView viewWithTag:_labelTag];
    nextLabel.textColor = [LPHPageBar colorFromColor:_textColor toColor:self.tintColor scale:fabs(_offsetScale)];
    UILabel *selectedLabel = [_selectedView viewWithTag:_labelTag];
    selectedLabel.textColor = [LPHPageBar colorFromColor:self.tintColor toColor:_textColor scale:fabs(_offsetScale)];
    
    if (fabs(_offsetScale) >= 1) {
        _selectedView = _itemViews[_selectedView.tag - _viewTag + (NSInteger)_offsetScale];
    }
}

#pragma mark - Action

- (void)tapGesture:(UIGestureRecognizer *)gestureRecognizer {
    UILabel *selectedLabel = [_selectedView viewWithTag:_labelTag];
    UIView *view = gestureRecognizer.view;
    UILabel *label = [view viewWithTag:_labelTag];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedAtSection:withDuration:)]) {
        [_delegate didSelectedAtSection:view.tag - _viewTag withDuration:_duration];
    }
    [UIView animateWithDuration:_duration animations:^{
        selectedLabel.textColor = _textColor;
        label.textColor = self.tintColor;
        _indicatorView.frame = CGRectMake(_indicatorView.frame.origin.x,
                                          _indicatorView.frame.origin.y,
                                          _items[view.tag - _viewTag].indicatorWidth,
                                          _indicatorHeight);
        _indicatorView.center = CGPointMake(view.center.x, _indicatorView.center.y);
    } completion:^(BOOL finished) {
        _selectedView = view;
    }];
}

#pragma mark - Autosize

- (CGSize)stringWidth:(NSString *)string {
    CGSize maxsize = CGSizeMake(CGFLOAT_MAX, _itemFont.pointSize);
    NSDictionary *attribute = @{NSFontAttributeName:_itemFont};
    CGSize size = [string boundingRectWithSize:maxsize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size;
}

- (BOOL)needsAutosize {
    for (int i = 0; i < _items.count; i++) {
        if (_items[i].itemWidth != 0) {
            return NO;
        }
    }
    return YES;
}

- (void)autosizeIfNeeded {
    if ([self needsAutosize]) {
        CGFloat maxWidth = 0;
        for (int i = 0; i < _items.count; i++) {
            _items[i].itemWidth = [self stringWidth:_items[i].title].width  + _textEdgeInsert * 2;
            maxWidth = maxWidth > _items[i].itemWidth? maxWidth: _items[i].itemWidth;
        }
        if (maxWidth * _items.count < self.bounds.size.width) {
            for (int i = 0; i < _items.count; i++) {
                _items[i].itemWidth = self.bounds.size.width / _items.count;
            }
        }
    }
}

#pragma mark - UIcolor

+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)tocColor scale:(CGFloat)scale {
    NSArray<UIColor *> *color = @[fromColor, tocColor];
    NSMutableArray<NSNumber *> *red = [NSMutableArray array];
    NSMutableArray<NSNumber *> *green = [NSMutableArray array];
    NSMutableArray<NSNumber *> *blue = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        NSInteger numComponents = CGColorGetNumberOfComponents(color[i].CGColor);
        const CGFloat *components = CGColorGetComponents(color[i].CGColor);
        if (numComponents == 4) {
            [red addObject:[NSNumber numberWithDouble:components[0]]];
            [green addObject:[NSNumber numberWithDouble:components[1]]];
            [blue addObject:[NSNumber numberWithDouble:components[2]]];
        } else if (numComponents == 2) {
            [red addObject:[NSNumber numberWithDouble:components[0]]];
            [green addObject:[NSNumber numberWithDouble:components[0]]];
            [blue addObject:[NSNumber numberWithDouble:components[0]]];
        } else {
            [red addObject:@1];
            [green addObject:@1];
            [blue addObject:@1];
        }
    }
    CGFloat redOffset = [red[0] doubleValue] + ([red[1] doubleValue] - [red[0] doubleValue]) * scale;
    CGFloat greenOffset = [green[0] doubleValue] + ([green[1] doubleValue] - [green[0] doubleValue]) * scale;
    CGFloat blueOffset = [blue[0] doubleValue] + ([blue[1] doubleValue] - [blue[0] doubleValue]) * scale;
    return [UIColor colorWithRed:redOffset green:greenOffset blue:blueOffset alpha:1];
}

@end