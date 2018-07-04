//
//  BugAssistiveResponseViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/25.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveResponseViewController.h"
#import "BugAssistiveHttpDataSource.h"
#import "BugAssistiveHttpHelper.h"

@interface BugAssistiveResponseViewController ()
{
    UITextView   *_textView;
    UIImageView  *_imageView;
    NSString     *_contentString;
}

@end

@implementation BugAssistiveResponseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (!self.isImage) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        [_textView setEditable:NO];
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSData* contentdata = self.data;
        if ([[BugAssistiveHttpHelper shareInstance] isHttpResponseEncrypt]) {
            if ([[BugAssistiveHttpHelper shareInstance] delegate] && [[BugAssistiveHttpHelper shareInstance].delegate respondsToSelector:@selector(decryptJson:)]) {
                contentdata = [[BugAssistiveHttpHelper shareInstance].delegate decryptJson:self.data];
            }
        }
        _textView.text = [BugAssistiveHttpDataSource prettyJSONStringFromData:contentdata];
        _contentString = _textView.text;
        
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName : style};
        CGRect r = [_textView.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, MAXFLOAT) options:option attributes:attributes context:nil];
        _textView.contentSize = CGSizeMake(self.view.bounds.size.width, r.size.height);
        [self.view addSubview:_textView];
    }
    else {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageWithData:self.data];
        [self.view addSubview:_imageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
