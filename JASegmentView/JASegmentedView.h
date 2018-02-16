//
//  JASegmentedView.h
//
//  Created by Junaid Ahmed on 5/09/16.
//  Copyright © 2016 frankszs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SegmentedViewStyle){
    
    SegmentedViewStyleDefault = 0,
    SegmentedViewStyleUnderline = 1,
    SegmentedViewStyleOverline = 2,
    SegmentedViewStyleNoLine = 3
};

IB_DESIGNABLE
@interface JASegmentedView : UIControl

@property (nonatomic) SegmentedViewStyle style;
@property (nonatomic) IBInspectable NSInteger styleInteger;

@property (nonatomic, strong) IBInspectable UIColor *stageColor;
@property (nonatomic) IBInspectable CGFloat stageCornerRadius;

@property (nonatomic, strong) IBInspectable UIColor *panelColor;
@property (nonatomic) IBInspectable CGFloat panelCornerRadius;
@property (nonatomic) IBInspectable CGFloat panelInset;

@property (nonatomic, strong) IBInspectable UIColor *deselectedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *selectedTextColor;

@property (nonatomic, strong) IBInspectable NSString *fontName;
@property (nonatomic) IBInspectable CGFloat fontSize;

@property (nonatomic, strong) IBInspectable NSString *prominentFontName;
@property (nonatomic) IBInspectable CGFloat prominentFontSize;

@property (nonatomic, strong) IBInspectable UIColor *prominentDeselectedTextColor;
@property (nonatomic, strong) IBInspectable UIColor *prominentSelectedTextColor;

@property (nonatomic) IBInspectable CGFloat lineWidth;

@property (nonatomic) IBInspectable CGFloat springDamping;

@property (nonatomic, readonly) NSInteger segmentAmount;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic) BOOL delaySwitch;


-(void)setSegments:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION;
-(void)setSegmentsWithArray:(NSArray *)strings;
-(void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

-(void)setProminentIndex:(NSInteger)prominentIndex;

@end
