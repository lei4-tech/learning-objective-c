#import "NSString+EmailValidation.h"

@implementation NSString (EmailValidation)
- (BOOL)isValidEmail {
    return [self containsString:@"@"] && [self containsString:@"."];
}
@end
