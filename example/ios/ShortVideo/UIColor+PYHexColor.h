//
//  UIColor+PYHexColor.h
//  example
//
//  Created by jimmy on 2021/1/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PYColor(_hex_)   [UIColor dl_colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]

@interface UIColor (PYHexColor)

/**
 Creates and returns a color object from hex string.
 
 @discussion:
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 The alpha will be set to 1.0 if there is no alpha component.
 It will return nil when an error occurs in parsing.
 
 Example: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  The hex string value for the new color.
 
 @return        An UIColor object from string, or nil if an error occurs.
 */
+ (nullable UIColor *)py_colorWithHexString:(NSString *)hexStr;

/**
 Creates and returns a color object from hex string.
 
 @discussion:
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 The alpha will be set to 1.0 if there is no alpha component.
 It will return nil when an error occurs in parsing.
 
 Example: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  The hex string value for the new color.
 
 @param alpha the alpha of the color
 
 @return        An UIColor object from string, or nil if an error occurs.
 */
+ (nullable UIColor *)py_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
