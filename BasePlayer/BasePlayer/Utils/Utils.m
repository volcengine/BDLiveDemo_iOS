//
//  Utils.m
// 
//   BDLive SDK License
//   
//   Copyright 2023 Beijing Volcano Engine Technology Ltd. All Rights Reserved.
//   
//   The BDLive SDK was developed by Beijing Volcanoengine Technology Ltd. (hereinafter “Volcano Engine”). 
//   Any copyright or patent right is owned by and proprietary material of the Volcano Engine. 
//   
//   BDLive SDK is available under the VolcLive product and licensed under the commercial license. 
//   Customers can contact service@volcengine.com for commercial licensing options. 
//   Here is also a link to subscription services agreement: https://www.volcengine.com/docs/6256/68938.
//   
//   Without Volcanoengine's prior written permission, any use of BDLive SDK, in particular any use for commercial purposes, is prohibited. 
//   This includes, without limitation, incorporation in a commercial product, use in a commercial service, or production of other artefacts for commercial purposes. 
//   
//   Without Volcanoengine's prior written permission, the BDLive SDK may not be reproduced, modified and/or made available in any form to any third party. 
//

#import "Utils.h"

@implementation Utils

+ (NSString *)stringFromMultiLangString:(NSString *)multiLangString
                              langTypes:(NSArray<NSNumber *> *)langTypes
                               langType:(BDLLanguageType)langType {
    if (multiLangString.length == 0) {
        return nil;
    }
    NSArray *stringArray = [multiLangString componentsSeparatedByString:@"|"];
    NSString *string = stringArray.firstObject;
    NSUInteger strCount = stringArray.count;
    NSUInteger langCount = langTypes.count;
    
    if (langType == BDLLanguageTypeUnknown) {
        langType = [self getSystemLanguage];
    }
    NSInteger index = [langTypes indexOfObject:@(langType)];
    if (index != NSNotFound) {
        if (langCount < strCount) {
            if (langType < strCount) {
                string = stringArray[langType];
            }
        }
        else {
            if (index < strCount) {
                string = stringArray[index];
            }
        }
    }
    
    return string;
}

+ (BDLLanguageType)getSystemLanguage {
    BDLLanguageType sysLang;
    NSString *preferLang = [[NSLocale preferredLanguages] firstObject];
    if ([preferLang hasPrefix:@"zh-Hans"]) {
        sysLang = BDLLanguageTypeChinese;
    } else if ([preferLang hasPrefix:@"en"]) {
        sysLang = BDLLanguageTypeEnglish;
    } else if ([preferLang hasPrefix:@"ja"]) {
        sysLang = BDLLanguageTypeJapanese;
    } else {
        sysLang = BDLLanguageTypeTraditional;
    }
    return sysLang;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (hexString.length == 0) {
        return nil;
    }
    NSString* colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha;
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", colorString);
            return nil;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString* substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString* fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent = 0;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

@end
