#import <Foundation/Foundation.h>
#import "Idol.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Idol *superStar = [[Idol alloc] init];
        [superStar sing];
        [superStar dance];

        // respondsToSelector: 运行时检查对象是否实现了可选方法
        if ([superStar respondsToSelector:@selector(composeMusic)]) {
            [superStar composeMusic];
        } else {
            NSLog(@"composeMusic 是可选方法，当前对象没有实现它。");
        }
    }
    return 0;
}
