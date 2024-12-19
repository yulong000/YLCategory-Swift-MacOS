//
//  YLTextField.h
//  QQ
//
//  Created by 魏宇龙 on 2022/4/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLTextField : NSTextField

/// 是否支持换行，default = NO
@property (nonatomic, assign) BOOL lineFeed;

@end

NS_ASSUME_NONNULL_END
