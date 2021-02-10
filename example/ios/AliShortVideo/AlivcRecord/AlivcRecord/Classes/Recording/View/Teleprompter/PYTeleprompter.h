//
//  PYTeleprompter.h
//  example
//
//  Created by jimmy on 2021/1/21.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    TeleprompterTypeLeft,
    TeleprompterTypeUp,
} TeleprompterType;

NS_ASSUME_NONNULL_BEGIN

@interface PYTeleprompter : UIView
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) NSString *word;
- (instancetype)initWithType:(TeleprompterType)type;

- (void)updateViewsByStartStatus:(BOOL)isStart;
@end

NS_ASSUME_NONNULL_END
