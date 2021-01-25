//
//  PYTeleprompter.m
//  example
//
//  Created by jimmy on 2021/1/21.
//

#import "PYTeleprompter.h"

@interface PYTeleprompter()
@property(nonatomic, strong) UITextView *textView;
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

- (UITextView *)textView {
  if (!_textView) {
    _textView = [[UITextView alloc] initWithFrame:self.bounds];
    _textView.backgroundColor = [UIColor colorWithRed:101/255.0 green:31/255.0 blue:255/255.0 alpha:0.7];
    _textView.editable = NO;
    _textView.selectable = NO;
    _textView.text = self.word;
    _textView.textColor = [UIColor whiteColor];
  }
  return _textView;
}

- (void)setWord:(NSString *)word {
    if (word && ![word isEqualToString:@""]) {
        self.textView.text = word;
    }
}


- (void)setupViews {
  [self addSubview:self.textView];

  
}

@end
