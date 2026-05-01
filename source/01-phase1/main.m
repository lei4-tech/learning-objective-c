#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 1. 定义变量
        int age = 20;
        NSString *name = @"Alice";

        // 2. 条件语句
        if (age >= 18) {
            NSLog(@"%@ 已经成年了。", name);
        } else {
            NSLog(@"%@ 还未成年。", name);
        }

        // 3. 循环语句
        NSLog(@"打印数字 1 到 5：");
        for (int i = 1; i <= 5; i++) {
            NSLog(@"%d...", i);
        }
    }
    return 0;
}