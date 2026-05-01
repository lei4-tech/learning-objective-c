#import <Foundation/Foundation.h>

// 📜 1. 定义协议 (通常也写在 .h 文件中)
@protocol Singer <NSObject>
- (void)sing;
@end

@protocol Dancer <NSObject>
- (void)dance;
@end

// --------------------------------------------------

// 🛠️ 2. 接口定义：使用尖括号 < > 来遵守多个协议，用逗号隔开
@interface Idol : NSObject <Singer, Dancer>
@end

// ⚙️ 3. 实现类：必须实现协议中规定的方法
@implementation Idol

- (void)sing {
    NSLog(@"唱歌：🎵 啦啦啦~");
}

- (void)dance {
    NSLog(@"跳舞：🕺 动起来~");
}

@end

// --------------------------------------------------

// 🚀 4. 调用
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Idol *superStar = [[Idol alloc] init];
        [superStar sing];
        [superStar dance];
    }
    return 0;
}