//
//  NSResponder+category.m
//  YLCategory-MacOS
//
//  Created by 魏宇龙 on 2023/5/8.
//

#import "NSResponder+category.h"
#import <objc/runtime.h>

#ifndef kAppIsDarkTheme
// 判断当前app是否是深色模式
#define kAppIsDarkTheme                    ([NSApp.effectiveAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua)
#endif

#ifndef kSystemIsDarkTheme
// 系统当前是否是深色模式
#define kSystemIsDarkTheme          \
^ BOOL{                             \
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];    \
    id style = [dict objectForKey:@"AppleInterfaceStyle"];  \
    return style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"];  \
}()
#endif

@implementation NSResponder (category)

- (YLThemeChangedHandler)systemThemeChangedHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSystemThemeChangedHandler:(YLThemeChangedHandler)systemThemeChangedHandler {
    objc_setAssociatedObject(self, @selector(systemThemeChangedHandler), systemThemeChangedHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if(systemThemeChangedHandler) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(yl_systemThemeChanged) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    } else {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }
}

- (void)yl_systemThemeChanged {
    if (self.systemThemeChangedHandler) {
        self.systemThemeChangedHandler(self, kSystemIsDarkTheme);
    }
}

- (YLThemeChangedHandler)appThemeChangedHandler {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAppThemeChangedHandler:(YLThemeChangedHandler)appThemeChangedHandler {
    objc_setAssociatedObject(self, @selector(appThemeChangedHandler), appThemeChangedHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if(appThemeChangedHandler) {
        [NSApp addObserver:self forKeyPath:@"effectiveAppearance" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [NSApp removeObserver:self forKeyPath:@"effectiveAppearance" context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"effectiveAppearance"]) {
        if(self.appThemeChangedHandler) {
            self.appThemeChangedHandler(self, kAppIsDarkTheme);
        }
    }
}

- (void)dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"AppleInterfaceThemeChangedNotification" object:nil];
    if(self.appThemeChangedHandler) {
        [NSApp removeObserver:self forKeyPath:@"effectiveAppearance" context:nil];
    }
}

@end
