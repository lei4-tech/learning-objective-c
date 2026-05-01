太棒了，我们之前的进度非常顺利。现在我们继续完成**阶段三（进阶特性）**的剩余两块核心拼图：**Category（分类/类别）** 和 **ARC 内存管理**。

掌握了这两个概念，你就能看懂绝大多数现有的 Objective-C 项目代码了。

### 1. Category（分类/类别）：不修改源码也能增加新方法

在很多语言中，如果你想给一个已有的类增加新功能，通常只能选择继承（写一个子类）。但在 Objective-C 中，**Category** 允许你在不破坏原有类结构、甚至**没有类源码**的情况下，直接给类“外挂”新的方法。

这在扩充系统级类（如 `NSString`）时尤其好用。

**Demo：给系统的 `NSString` 添加一个判断是否是邮箱格式的方法**

```objc
#import <Foundation/Foundation.h>

// 🛠️ 1. 定义分类的接口
// 语法：@interface 已有类名 (分类名称)
@interface NSString (EmailValidation)
- (BOOL)isValidEmail;
@end

// ⚙️ 2. 实现分类的方法
@implementation NSString (EmailValidation)
- (BOOL)isValidEmail {
    // 这里简单演示一下逻辑，实际开发会用正则表达式
    return [self containsString:@"@"] && [self containsString:@"."];
}
@end

// 🚀 3. 调用
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *myEmail = @"test@apple.com";
        
        // 就像调用 NSString 本身自带的方法一样自然！
        if ([myEmail isValidEmail]) {
            NSLog(@"%@ 是一个合法的邮箱", myEmail);
        }
    }
    return 0;
}
```

*注意：Category 主要是用来添加**方法**的，通常不能用来添加属性（成员变量）。*

---

### 2. ARC 内存管理：`strong` 与 `weak`

Objective-C 使用的是 **自动引用计数 (ARC, Automatic Reference Counting)** 来管理内存。它不像 Java 或 Python 那样有一个在后台运行的垃圾回收器（Garbage Collector）。ARC 其实是在**编译阶段**，由编译器自动帮你在代码中插入内存的增加和释放指令。

理解 ARC 的核心在于两个属性修饰符：**`strong`（强引用）** 和 **`weak`（弱引用）**。

* **`strong`**：表示“我需要这个对象活着”。只要有一个 `strong` 指针指向一个对象，这个对象就不会被销毁（引用计数 +1）。我们之前定义的 `NSString *name` 属性默认就是强引用。
* **`weak`**：表示“我可以指向这个对象，但它的死活与我无关”。如果没有别人用 `strong` 牵着这个对象，它被销毁了，我的 `weak` 指针会自动变成 `nil`（空），防止应用崩溃。



**为什么需要 `weak`？为了打破“循环引用”（Retain Cycle）。**

如果 A 强引用了 B，B 又强引用了 A。两人互相拉扯，谁也无法释放，就会造成**内存泄漏**。
最经典的场景就是我们刚才学的**协议（Delegate 代理模式）**：

```objc
@interface Boss : NSObject
// 老板雇佣员工，强引用（发工资，不能让员工跑了）
@property (nonatomic, strong) Employee *myEmployee;
@end

@interface Employee : NSObject
// 员工知道自己的老板是谁，但不能用 strong，否则互相强引用导致内存泄漏
// 所以代理/反向引用通常使用 weak
@property (nonatomic, weak) Boss *myBoss;
@end
```

至此，你已经走完了 Objective-C 基础语法的快速入门链路。从变量定义到面向对象，再到独有的分类和内存管理机制，整个骨架已经搭建完毕了。