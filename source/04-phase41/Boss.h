#import <Foundation/Foundation.h>
#import "Employee.h"

@interface Boss : NSObject
@property (nonatomic, copy) NSString *name;
// strong 引用：老板持有员工，老板在则员工不会被释放
@property (nonatomic, strong) Employee *employee;
@end
