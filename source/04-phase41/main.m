#import <Foundation/Foundation.h>
#import "NSString+EmailValidation.h"
#import "Boss.h"
#import "Employee.h"

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

        boss.employee = employee;
        employee.boss = boss;
        [employee reportTo];

        // boss 置 nil 后，employee.boss（weak）自动变为 nil
        boss = nil;
        NSLog(@"老板对象释放后，employee.boss = %@", employee.boss);
    }
    return 0;
}
