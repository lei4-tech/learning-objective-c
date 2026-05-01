#import "Greeter.h"
#include <iostream>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // C++ code
        std::cout << "Starting the program..." << std::endl;
        std::cout << "Hello from C++!" << std::endl;

        Greeter *greeter = [[Greeter alloc] init];
        [greeter sayHello];
    }
    return 0;
}