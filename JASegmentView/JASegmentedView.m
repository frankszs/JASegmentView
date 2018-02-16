//
//  JASegmentedView.m
//
//  Created by Junaid Ahmed on 5/09/16.
//  Copyright © 2016 frankszs. All rights reserved.
//

#import "JASegmentedView.h"

@interface JASegmentedView ()

@property (nonatomic, strong) NSArray *segmentStrings;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, strong) NSArray *labelViews;
@property (nonatomic, strong) NSArray *buttonViews;

@property (nonatomic) NSInteger prominentIndex;

@property (nonatomic) BOOL isAnimating;

@end

@implementation JASegmentedView

#pragma mark - Init Methods

-(id)init{
    if(self = [super init]){
        [self completeInit];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self completeInit];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self completeInit];
    }
    return self;
}

//Called by init, initWithFrame: and initWithCoder: methods.
-(void)completeInit{
    
    //Set default values and build.
    _stageColor = [UIColor colorWithWhite:0.85 alpha:1];
    _stageCornerRadius = 2;
    _panelColor = [UIColor whiteColor];
    _panelCornerRadius = 1;
    _panelInset = 4;
    _deselectedTextColor = [UIColor lightGrayColor];
    _selectedTextColor = [UIColor darkGrayColor];
    _fontName = @"Georgia";
    _fontSize = 12;
    _style = SegmentedViewStyleDefault;
    _lineWidth = 2;
    _springDamping = 0.7;
    _prominentIndex = -1;
    
    [self setSegments:@"Left", @"Right", nil];
}

//Called by interfaceBuilder only, if class is IB_DESIGNABLE. Sets default state.
-(void)prepareForInterfaceBuilder{
    [super prepareForInterfaceBuilder];
    [self completeInit];
}


#pragma mark - Maintenance Methods

-(void)layoutSubviews{
    
    [self repositionSubviews];
    [self bringSubviewToFront:self.panelView];
    
    //Reframe buttons and labels.
    for(int i = 0; i < [self.segmentStrings count]; i++){
        UILabel *label = self.labelViews[i];
        UIButton *button = self.buttonViews[i];
        CGRect frame = CGRectMake((self.bounds.size.width/[self.segmentStrings count])*i, 0, (self.bounds.size.width/[self.segmentStrings count]), self.bounds.size.height);
        [label setFrame:frame];
        [button setFrame:frame];
        [self bringSubviewToFront:label];
        [self bringSubviewToFront:button];
    };
}

//Called by layoutSubviews and updateIndex:fromIndex:animated, animatable.
-(void)repositionSubviews{
    
    //Reframe panel, frame depends style.
    if(self.style == SegmentedViewStyleDefault)
        [self.panelView setFrame:CGRectMake(((self.bounds.size.width/[self.segmentStrings count])*self.selectedIndex)+(self.panelInset/2), self.panelInset/2, (self.bounds.size.width/[self.segmentStrings count])-self.panelInset, self.bounds.size.height-self.panelInset)];
    
    else if(self.style == SegmentedViewStyleUnderline)
        [self.panelView setFrame:CGRectMake(((self.bounds.size.width/[self.segmentStrings count])*self.selectedIndex)+(self.panelInset/2), self.bounds.size.height-self.lineWidth, (self.bounds.size.width/[self.segmentStrings count])-self.panelInset, self.lineWidth)];
    
    else if(self.style == SegmentedViewStyleOverline)
         [self.panelView setFrame:CGRectMake(((self.bounds.size.width/[self.segmentStrings count])*self.selectedIndex)+(self.panelInset/2), 0, (self.bounds.size.width/[self.segmentStrings count])-self.panelInset, self.lineWidth)];
}

-(void)buildSubviews{
    
    //Remove any previous views.
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //Temp arrays for views.
    NSMutableArray *tempLabelViews = [[NSMutableArray alloc] init];
    NSMutableArray *tempButtonViews = [[NSMutableArray alloc] init];
    
    //Create views and add as subviews.
    for(int i = 0; i < [self.segmentStrings count]; i++){
        NSString *segmentString = self.segmentStrings[i];
        if([segmentString isKindOfClass:[NSString class]]){
            
            //Create label.
            UILabel *label = [[UILabel alloc] init];
            [label setText:segmentString];
            [label setTextAlignment:NSTextAlignmentCenter];
            [tempLabelViews addObject:label];
            [self addSubview:label];
            
            //Create button.
            UIButton *button = [[UIButton alloc] init];
            button.tag = i;
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [tempButtonViews addObject:button];
            [self addSubview:button];
        }
    }
    self.labelViews = [NSArray arrayWithArray:tempLabelViews];
    self.buttonViews = [NSArray arrayWithArray:tempButtonViews];
    
    //Create panel.
    self.panelView = [[UIView alloc] init];
    [self addSubview:self.panelView];
    
    //Set visuals and layout.
    [self updateVisualStates];
    [self layoutIfNeeded];
}

//Updates visual appearance of view using current values. Takes into account current selected index. Does not animate.
-(void)updateVisualStates{
    
    //Update stage and panel appearance.
    self.backgroundColor = self.stageColor;
    self.layer.cornerRadius = self.stageCornerRadius;
    self.panelView.backgroundColor = self.panelColor;
    self.panelView.layer.cornerRadius = self.panelCornerRadius;
    self.panelView.hidden = self.style == SegmentedViewStyleNoLine;
    
    //Update label text colors and create font.
    UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
    UIFont *prominentFont = [UIFont fontWithName:self.prominentFontName size:self.prominentFontSize];
    
    //Check for nil font.
    if(!font)
        font = [UIFont systemFontOfSize:self.fontSize weight:UIFontWeightSemibold];
    if(!prominentFont)
        prominentFont = [UIFont systemFontOfSize:self.prominentFontSize weight:UIFontWeightSemibold];
    
    for(int i = 0; i < [self.labelViews count]; i++){
        UILabel *label = self.labelViews[i];
        label.font = self.prominentIndex == i ? prominentFont : font;
        if(i == self.selectedIndex){
            UIColor *textColor = self.prominentIndex == i ? self.prominentSelectedTextColor : self.selectedTextColor;
            [label setTextColor:textColor];
        }
        else{
              UIColor *textColor = self.prominentIndex == i ? self.prominentDeselectedTextColor : self.deselectedTextColor;
            [label setTextColor:textColor];
        }
    }
}

-(void)buttonTapped:(UIButton *)button{
    
    //If delaySwitch is true, segmentedView will not switch values if the previous animation has not been completed.
    if(self.delaySwitch && self.isAnimating)
        return;
    
    NSInteger index = button.tag;
    
    //If index is different to selected index, move to new index.
    if(self.selectedIndex != index){
        [self updateIndex:index animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

//Handles selected index bool.
-(void)updateIndex:(NSInteger)index animated:(BOOL)animated{
    
    NSInteger previousIndex = _selectedIndex;
    _selectedIndex = index;
    
    if(animated){
        self.isAnimating = YES;
        
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:1 options:0 animations:^(){
            //Animate panel, frame depends on use of underline style.
            [self repositionSubviews];
            
             UIColor *deselectedTextColor = self.prominentIndex == previousIndex ? self.prominentDeselectedTextColor : self.deselectedTextColor;
            UIColor *selectedTextColor = self.prominentIndex == index ? self.prominentSelectedTextColor : self.selectedTextColor;
            
            [((UILabel *)self.labelViews[previousIndex]) setTextColor:deselectedTextColor];
            [((UILabel *)self.labelViews[index]) setTextColor:selectedTextColor];
        } completion:^(BOOL completion){self.isAnimating = NO;}];
    }
    else
        [self layoutIfNeeded];
}

#pragma mark - Custom Setters

-(void)setSegments:(NSString *)string, ...{

    NSMutableArray *tempSegmentStrings = [[NSMutableArray alloc] init];
    
    va_list argsList;
    id currentObject;
    
    if(string){
        //First argument is not part of the list.
        if([string isKindOfClass:[NSString class]])
            [tempSegmentStrings addObject:string];
        
        //Initialize argsList to start retriving additional arguments after first string.
        va_start(argsList, string);
        //Returns the next argument of type id, then checks for nil.
        while((currentObject = va_arg(argsList, id))){
            
            if([currentObject isKindOfClass:[NSString class]])
                [tempSegmentStrings addObject:currentObject];
        }
        va_end(argsList);
    }
    _segmentStrings = [NSArray arrayWithArray:tempSegmentStrings];
    _segmentAmount = [tempSegmentStrings count];
    
    //Setting new segments needs new buildSubview pass.
    [self buildSubviews];
}

-(void)setSegmentsWithArray:(NSArray *)strings{
    
    _segmentStrings = [NSArray arrayWithArray:strings];
    _segmentAmount = [strings count];
    
    //Setting new segments needs new buildSubview pass.
    [self buildSubviews];
}

-(void)setStageColor:(UIColor *)stageColor{
    _stageColor = stageColor;
    self.backgroundColor = stageColor;
}

-(void)setStageCornerRadius:(CGFloat)stageCornerRadius{
    _stageCornerRadius = stageCornerRadius;
    self.layer.cornerRadius = stageCornerRadius;
}

-(void)setPanelColor:(UIColor *)panelColor{
    _panelColor = panelColor;
    self.panelView.backgroundColor = panelColor;
}

-(void)setPanelCornerRadius:(CGFloat)panelCornerRadius{
    _panelCornerRadius = panelCornerRadius;
    self.panelView.layer.cornerRadius = panelCornerRadius;
}

-(void)setPanelInset:(CGFloat)panelInset{
    _panelInset = panelInset >= 0 ? panelInset : 0;
    [self setNeedsLayout];
}

-(void)setDeselectedTextColor:(UIColor *)deselectedTextColor{
    _deselectedTextColor = deselectedTextColor;
    [self updateVisualStates];
}

-(void)setSelectedTextColor:(UIColor *)selectedTextColor{
    _selectedTextColor = selectedTextColor;
    [self updateVisualStates];
}

-(void)setFontName:(NSString *)fontName{
    _fontName = fontName;
    [self updateVisualStates];
}

-(void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize >= 0 ? fontSize : 12;
    [self updateVisualStates];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex{
    [self setSelectedIndex:selectedIndex animated:NO];
}

-(void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated{
    //Check if given index in range, if so, don't do anything.
    if(selectedIndex < 0 || selectedIndex >= [self.segmentStrings count])
        return;
    
    [self setNeedsLayout];
    [self updateIndex:selectedIndex animated:animated];
    [self updateVisualStates];
}

-(void)setProminentIndex:(NSInteger)prominentIndex{
    
    //Must be within possible index range or -1, which indicates no prominent index.
    if(prominentIndex < -1 || prominentIndex >= [self.segmentStrings count])
        return;
    
    _prominentIndex = prominentIndex;
    
    [self setNeedsLayout];
    [self updateIndex:self.selectedIndex animated:NO];
    [self updateVisualStates];
}

//Using seperate integer to change the style property as enums are not IBInspectable.
-(void)setStyleInteger:(NSInteger)styleInteger{
    
    //Out of bounds integer give default style.
    if(styleInteger < 0 || styleInteger > 3){
        _style = SegmentedViewStyleDefault;
        _styleInteger = 0;
    }
    else{
        _style = (SegmentedViewStyle)styleInteger;
        _styleInteger = styleInteger;
      }
}

-(void)setStyle:(SegmentedViewStyle)style{
    _style = style;
    _styleInteger = style;
}



@end
