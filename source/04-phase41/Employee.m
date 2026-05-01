#import "Employee.h"
#import "Boss.h"

@implementation Employee
- (void)reportTo {
    if (self.boss) {
        NSLog(@"%@ 向老板 %@ 汇报工作", self.name, self.boss.name);
    }
}
@end
