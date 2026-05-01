#import <Foundation/Foundation.h>

// 📜 1. 定义协议 (通常也写在 .h 文件中)
@protocol Singer <NSObject>
@required
// @required 表示以下方法是必须实现的，任何遵守 Singer 协议的类都必须实现这个方法
- (void)sing;

@optional
// @optional 表示以下方法是可选的，遵守 Singer 协议的
- (void)composeMusic; 
- (void)holdConvert; 

@end

@protocol Dancer <NSObject>
- (void)dance; // 协议方法，任何遵守 Dancer 协议的类都必须实现这个方法
@end

// --------------------------------------------------

// 🛠️ 2. 接口定义：使用尖括号 < > 来遵守多个协议，用逗号隔开
@interface Idol : NSObject <Singer, Dancer> // Idol 类同时遵守 Singer 和 Dancer 协议
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

        if ([superStar respondsToSelector:@selector(composeMusic)]) {
            [superStar composeMusic];
        } else {
            NSLog(@"composeMusic 方法是可选的，当前对象没有实现它。");
        }
    }
    return 0;
}