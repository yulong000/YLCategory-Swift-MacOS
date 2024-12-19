//
//  NSTextField+category.h
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2023/5/8.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextField (category)

/// 固定最大宽度，高度自适应
- (NSSize)sizeWithMaxWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
