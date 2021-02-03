//
//  PYTeleprompter.m
//  example
//
//  Created by jimmy on 2021/1/21.
//

#import "PYTeleprompter.h"

@interface PYTeleprompter()

@end

@implementation PYTeleprompter

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithType:(TeleprompterType)type
{
    self = [super init];
    if (self) {
        [self setupViewsWithType:type];
    }
    return self;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.text = self.word;
        _textView.textColor = [UIColor whiteColor];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.showsVerticalScrollIndicator = NO;
    }
    return _textView;
}

- (void)setWord:(NSString *)word {
    if (word && ![word isEqualToString:@""]) {
        self.textView.text = word;
    }
}


- (void)setupViews {
    
    
}

- (void)setupViewsWithType:(TeleprompterType)type {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [self addSubview:self.textView];
    if (type == TeleprompterTypeUp) {
        if (@available(iOS 9.0, *)) {
            [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:80].active = YES;
            [self.textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:18].active = YES;
            [self.textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-18].active = YES;
            [self.textView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-30].active = YES;
        } else {
            // Fallback on earlier versions
        }
    } else if (type == TeleprompterTypeLeft) {
        if (@available(iOS 9.0, *)) {
            [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor constant:14].active = YES;
            [self.textView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-12].active = YES;
            [self.textView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
            [self.textView.widthAnchor constraintEqualToConstant:550].active = YES;
        } else {
            // Fallback on earlier versions
        }
        
    }
}

@end
