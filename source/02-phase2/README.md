在 Objective-C 中，定义一个类通常分为两个部分：**接口（Interface）**和**实现（Implementation）**。这有点像写一份产品说明书和实际去制造产品。

| 部分 | 关键字 | 作用 | 常见文件后缀 |
| :--- | :--- | :--- | :--- |
| **接口** | `@interface` | 声明类名、属性（变量）和方法名。告诉别人“这个类能做什么”。 | `.h` (Header) |
| **实现** | `@implementation` | 编写方法的具体代码逻辑。定义“这个类具体怎么做”。 | `.m` (Message) |

来看一个典型的 Demo，我们定义一个 `Person` 类，并实例化它：

```objc
#import <Foundation/Foundation.h>

// 🛠️ 1. 定义接口 (通常放在 .h 文件中)
// NSObject 是 Objective-C 中绝大多数类的“基类”
@interface Person : NSObject

// 定义属性
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;

// 声明方法：前面的减号 (-) 代表这是一个实例方法（需要由对象来调用）
- (void)introduceYourself;

@end

// --------------------------------------------------

// ⚙️ 2. 编写实现 (通常放在 .m 文件中)
@implementation Person

// 实现具体的方法逻辑
- (void)introduceYourself {
    // self 类似于其他语言中的 this
    NSLog(@"大家好，我是 %@，今年 %d 岁。", self.name, self.age);
}

@end

// --------------------------------------------------

// 🚀 3. 实例化与调用
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 创建对象
        Person *xiaoming = [[Person alloc] init];
        
        // 给属性赋值
        xiaoming.name = @"小明";
        xiaoming.age = 22;
        
        // 调用方法
        [xiaoming introduceYourself];
    }
    return 0;
}
```

在这段代码的最后，你可能会注意到一个非常具有 Objective-C 特色的语法：**中括号 `[ ]`**。比如 `[[Person alloc] init]` 和 `[xiaoming introduceYourself]`。

在 Objective-C 中，调用方法被称为**“发送消息”（Message Passing）**。`[接收者 消息名称]` 是最基本的格式。

基于你对其他面向对象语言的理解，你觉得 `[[Person alloc] init]` 这个嵌套的中括号里，`alloc` 和 `init` 分别负责完成创建对象的哪两个关键步骤呢？

***我理解alloc是分配实例内存，init是调用构造函数完成初始化***

理解得非常准确。alloc 负责在堆内存中为对象分配空间，而 init 负责将这块内存初始化为安全的默认状态。Objective-C 把它们分开，是为了方便开发者编写各种自定义的初始化方法（比如 initWithName:age:）