#import <Foundation/Foundation.h>
#import "Idol.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Idol *superStar = [[Idol alloc] init];
        [superStar sing];
        [superStar dance];
    }
    return 0;
}
