//
//  YLTextField.m
//  QQ
//
//  Created by 魏宇龙 on 2022/4/19.
//

#import "YLTextField.h"

@interface YLTextFieldCell : NSTextFieldCell

@end

@implementation YLTextFieldCell

- (instancetype)init {
    if (self = [super init]) {
        self.scrollable = YES;
    }
    return self;
}

- (NSRect)drawingRectForBounds:(NSRect)rect {
    NSRect newRect = [super drawingRectForBounds:rect];
    NSSize size = [self cellSizeForBounds:rect];
    if(NSHeight(newRect) > size.height) {
        newRect.size.height = size.height;
        newRect.origin.y += (NSHeight(rect) - size.height) / 2;
    }
    return newRect;
}

- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)delegate start:(NSInteger)selStart length:(NSInteger)selLength {
    NSRect newRect = self.scrollable ? [self drawingRectForBounds:rect] : rect;
    [super selectWithFrame:newRect inView:controlView editor:textObj delegate:delegate start:selStart length:selLength];
}

- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)delegate event:(NSEvent *)event {
    NSRect newRect = self.scrollable ? [self drawingRectForBounds:rect] : rect;
    [super editWithFrame:newRect inView:controlView editor:textObj delegate:delegate event:event];
}

@end



@implementation YLTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.cell = [[YLTextFieldCell alloc] init];
        self.editable = YES;
    }
    return self;
}

- (void)setLineFeed:(BOOL)lineFeed {
    _lineFeed = lineFeed;
    self.cell.scrollable = !lineFeed;
}

@end
