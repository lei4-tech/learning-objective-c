#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 无需 Info.plist：手动创建 NSApplication 并设置 Delegate
        NSApplication *app = [NSApplication sharedApplication];

        // 作为标准前台应用运行（显示 Dock 图标 + 菜单栏）
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];

        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];

        [app activateIgnoringOtherApps:YES];
        [app run];
    }
    return 0;
}
