#import <Foundation/Foundation.h>

// ==================================================
// 知识点一：Category（分类）
// 语法：@interface 已有类名 (分类名称)
// 作用：不修改、不继承原有类，直接为其"外挂"新方法
// ==================================================

// 🛠️ 为系统类 NSString 添加邮箱格式验证方法
@interface NSString (EmailValidation)
- (BOOL)isValidEmail;
@end

@implementation NSString (EmailValidation)
- (BOOL)isValidEmail {
    // 简单判断：包含 @ 且包含 .
    return [self containsString:@"@"] && [self containsString:@"."];
}
@end


// ==================================================
// 知识点二：ARC 内存管理 —— strong 与 weak
// strong：强引用，持有对象，引用计数 +1，对象不会被销毁
// weak  ：弱引用，不持有对象，对象销毁后指针自动置 nil
// 典型场景：两个对象互相引用时，其中一方必须用 weak 打破循环
// ==================================================

@class Boss; // 前向声明，让 Employee 能引用 Boss 类型

@interface Employee : NSObject
@property (nonatomic, copy) NSString *name;
// 员工持有老板的弱引用：老板不因员工而存活，避免循环引用
@property (nonatomic, weak) Boss *boss;
- (void)reportTo;
@end

@interface Boss : NSObject
@property (nonatomic, copy) NSString *name;
// 老板持有员工的强引用：老板在，员工就不会被释放
@property (nonatomic, strong) Employee *employee;
@end

@implementation Employee
- (void)reportTo {
    // weak 属性在对象销毁后会自动变为 nil，这里先判空再使用
    if (self.boss) {
        NSLog(@"%@ 向老板 %@ 汇报工作", self.name, self.boss.name);
    }
}
@end

@implementation Boss
@end


// ==================================================
// 主程序
// ==================================================
int main(int argc, const char * argv[]) {
    @autoreleasepool {

        // --- Category 演示 ---
        NSLog(@"===== Category =====");
        NSString *validEmail   = @"test@apple.com";
        NSString *invalidEmail = @"not-an-email";

        NSLog(@"%@ 是合法邮箱：%@", validEmail,   [validEmail isValidEmail]   ? @"YES" : @"NO");
        NSLog(@"%@ 是合法邮箱：%@", invalidEmail, [invalidEmail isValidEmail] ? @"YES" : @"NO");


        // --- ARC strong / weak 演示 ---
        NSLog(@"\n===== ARC: strong & weak =====");

        Boss     *boss     = [[Boss alloc] init];
        Employee *employee = [[Employee alloc] init];

        boss.name     = @"张总";
        employee.name = @"小李";

        // 建立双向引用：boss strong -> employee，employee weak -> boss
        boss.employee    = employee;
        employee.boss    = boss;

        [employee reportTo];

        // 演示 weak 自动置 nil：将 boss 置 nil，模拟老板对象被释放
        // 此时 employee.boss（weak）会自动变为 nil
        boss = nil;
        NSLog(@"老板对象释放后，employee.boss = %@", employee.boss); // 输出 (null)
    }
    return 0;
}
