#import <Foundation/Foundation.h>

// 前向声明：Employee.h 与 Boss.h 互相引用，用 @class 代替 #import 打破循环
@class Boss;

@interface Employee : NSObject
@property (nonatomic, copy) NSString *name;
// weak 引用：员工知道老板是谁，但不持有老板，避免循环引用
@property (nonatomic, weak) Boss *boss;
- (void)reportTo;
@end
