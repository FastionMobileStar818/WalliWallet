//
//  UIAlertView+Starlet.m
//  Starlet
//
//  Created by Lion User on 20/08/2013.
//  Copyright (c) 2013 Starlet. All rights reserved.
//
#import "UIAlertView+Starlet.h"
#import <objc/runtime.h>
#import "CustomIOS7AlertView.h"

@interface UIAlertViewDelegate : NSObject<UIAlertViewDelegate>

@property (strong, nonatomic) AlertCompleteHandler  completeHandler;

@end

static UIAlertView* sCurrentAlertView = nil;

@implementation UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.completeHandler) {
        self.completeHandler(buttonIndex);
    }
    sCurrentAlertView = nil;
}

@end

@implementation CustomIOS7AlertView (AttachTap)

- (void)attachmentTapped:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateFailed) return;
    
    //    UITextView *textView = (UITextView*)[self viewWithTag:20140];
    UILabel *textView = (UILabel*)[self viewWithTag:20140];
    //    NSTextContainer *textContainer = textView.textContainer;
    //    NSLayoutManager *layoutManager = textView.layoutManager;
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:textView.attributedText];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [storage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:textView.bounds.size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = textView.numberOfLines;
    textContainer.lineBreakMode = textView.lineBreakMode;
    [layoutManager addTextContainer:textContainer];
    
    CGPoint point = [gesture locationInView:textView]; //[touch locationInView:textView];
    //    point.x -= textView.textContainerInset.left;
    //    point.y -= textView.textContainerInset.top;
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:point inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (characterIndex >= textView.text.length)
    {
        return;
    }
    
    NSRange range = NSMakeRange(0, 0);
    NSTextAttachment *textAttachment = [textView.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&range];
    if (textAttachment)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:UIAlertViewTextAttachmentTapNotification object:nil userInfo:@{@"NSTextAttachment": textAttachment}];
        return;
    }
    textAttachment = nil;
}

@end

@implementation UIAlertView (Starlet)

- (UILabel*)getBodyTextLabel {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
        return nil;
    return [self valueForKey:@"_bodyTextLabel"];
#if 0
    Ivar ivar = class_getInstanceVariable([self class], "_bodyTextLabel");
    void* labelptr = ((__bridge void*)self) + ivar_getOffset(ivar);
    UILabel* label = (__bridge_transfer UILabel*)(*(void**)labelptr);
    return label;
#endif
}

+ (void)showMessage:(NSString*)message {
    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    sCurrentAlertView = [UIAlertView showMessage:message align:NSTextAlignmentLeft delegate:nil];
}

+ (UIAlertView*)showMessage:(NSString*)message delegate:(id)delegate {
    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    sCurrentAlertView = [UIAlertView showMessage:message align:NSTextAlignmentLeft delegate:delegate];
    return sCurrentAlertView;
}

+ (UIAlertView*)showMessage:(NSString*)message align:(NSTextAlignment)alignment delegate:(id)delegate {
    if (message.length < 1)
        return nil;

    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    
    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:delegate cancelButtonTitle:nil otherButtonTitles:(@"OK"), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = alignment;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
    return sCurrentAlertView;
}

+ (UIAlertView*)showAlertMessage:(NSString*)message delegate:(id)delegate {
    if (message.length < 1)
        return nil;

    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];

    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:delegate cancelButtonTitle:(@"No") otherButtonTitles:(@"Yes"), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
    return sCurrentAlertView;
}

+ (void)showMessage:(NSString*)message complete:(AlertCompleteHandler) handler {
    static UIAlertViewDelegate* sAlertDelegate = nil;
    if (sAlertDelegate == nil)
        sAlertDelegate = [UIAlertViewDelegate new];
    sAlertDelegate.completeHandler = handler;

    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];

    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:sAlertDelegate cancelButtonTitle:nil otherButtonTitles:(@"OK"), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
}

+ (void)showAlertMessage:(NSString*)message complete:(AlertCompleteHandler) handler {
    static UIAlertViewDelegate* sAlertDelegate = nil;
    if (sAlertDelegate == nil)
        sAlertDelegate = [UIAlertViewDelegate new];
    sAlertDelegate.completeHandler = handler;
    
    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    
    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:sAlertDelegate cancelButtonTitle:(@"No") otherButtonTitles:(@"Yes"), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
}

+ (void)showAlertMessage:(NSString*)message yesTitle:(NSString*)title noTitle:(NSString*)other complete:(AlertCompleteHandler) handler {
    static UIAlertViewDelegate* sAlertDelegate = nil;
    if (sAlertDelegate == nil)
        sAlertDelegate = [UIAlertViewDelegate new];
    sAlertDelegate.completeHandler = handler;
    
    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];

    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:sAlertDelegate
                                         cancelButtonTitle:(other ? other : (@"No"))
                                         otherButtonTitles:(title ? title : (@"Yes")), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
}

+ (UIAlertView*)showPushMessage:(NSString*)message showView:(BOOL)showView complete:(AlertCompleteHandler) handler {
    static UIAlertViewDelegate* sAlertDelegate = nil;
    if (sAlertDelegate == nil)
        sAlertDelegate = [UIAlertViewDelegate new];
    sAlertDelegate.completeHandler = handler;

    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    
    NSString* cancel = nil;
    if (showView)
        cancel = (@"Cancel");

    sCurrentAlertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:sAlertDelegate cancelButtonTitle:cancel otherButtonTitles:(@"View"), nil];
    UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    [sCurrentAlertView show];
    
    return sCurrentAlertView;
}

+ (UIView*)createCustomBodyLabel:(NSString*)title message:(NSAttributedString*)message {
    UILabel* bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
//    UITextView* bodyLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
//    bodyLabel.backgroundColor = [UIColor clearColor];
//    bodyLabel.editable = NO;
//    bodyLabel.selectable = NO;
    bodyLabel.tag = 20140;
    
    bodyLabel.font = [UIFont systemFontOfSize:17];
    bodyLabel.numberOfLines = 0;
    if (title.length > 0)
        title = [title stringByAppendingString:@"\n\n"];
    NSMutableAttributedString *bodyString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15]}];
    [bodyString appendAttributedString:message];
    
    bodyLabel.attributedText = bodyString;
    CGSize bodySize = [bodyLabel sizeThatFits:CGSizeMake(260, 9999)];
    
    UIView* bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, bodySize.height + 20)];
    bodyView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = bodyLabel.frame;
    frame.origin.x = 10;
    frame.origin.y = 10;
    frame.size = bodySize;
    bodyLabel.frame = frame;
    
    [bodyView addSubview:bodyLabel];
    return bodyView;
}

+ (UIView*)createCustomTitleImage:(UIImage*)titleImage message:(NSAttributedString*)message {
    UILabel* bodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 20)];
    bodyLabel.tag = 20140;
    
    bodyLabel.font = [UIFont systemFontOfSize:17];
    bodyLabel.numberOfLines = 0;
    NSAttributedString *bodyString = message;
//    NSMutableAttributedString *bodyString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15]}];
//    [bodyString appendAttributedString:message];
    
    bodyLabel.attributedText = bodyString;
    CGSize bodySize = [bodyLabel sizeThatFits:CGSizeMake(260, 9999)];

    UIView* bodyView;
    CGRect titleImageFrame = CGRectZero;
    if (titleImage) {
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage];
        titleImageFrame = CGRectMake(0, 0, 280, round((titleImage.size.height * 280 / titleImage.size.width)));
        titleImageView.frame = titleImageFrame;
        titleImageView.contentMode = UIViewContentModeScaleToFill;
        
        bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, titleImageFrame.size.height + bodySize.height + 20)];
        [bodyView addSubview:titleImageView];
    } else {
        bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, bodySize.height + 20)];
        
    }
    bodyView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = bodyLabel.frame;
    frame.origin.x = 10;
    frame.origin.y = CGRectGetMaxY(titleImageFrame);
    frame.size = bodySize;
    bodyLabel.frame = frame;
    
    [bodyView addSubview:bodyLabel];
    return bodyView;
}

static CustomIOS7AlertView *sCustomAlertView = nil;

+ (void)closeCustomAlertView {
    [sCustomAlertView close];
    sCustomAlertView = nil;
}

+ (id)showMessageWithTitle:(NSString*)title message:(NSAttributedString*)message button:(NSString*)buttonTitle complete:(AlertCompleteHandler) handler {
    return [self showAlertTitle:title message:message cancel:nil other:buttonTitle tap:NO complete:handler];
}
+ (id)showMessageWithTitleImage:(UIImage*)titleImage message:(NSAttributedString*)message button:(NSString*)buttonTitle complete:(AlertCompleteHandler) handler {
    return [self showAlertTitle:titleImage message:message cancel:nil other:buttonTitle tap:NO complete:handler];
}
+ (id)showMessageWithTitle:(NSString*)title message:(NSAttributedString*)message button:(NSString*)buttonTitle  tap:(BOOL)tapTextAttachment complete:(AlertCompleteHandler) handler {
    return [self showAlertTitle:title message:message cancel:nil other:buttonTitle tap:tapTextAttachment complete:handler];
}

+ (id)showAlertTitle:(id)title message:(NSAttributedString*)message cancel:(NSString*)cancelButton other:(NSString*)otherButton tap:(BOOL)tapTextAttachment complete:(AlertCompleteHandler) handler {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        
        [UIAlertView closeCustomAlertView];
        
        // Here we need to pass a full frame
        CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
        
        // Add some custom content to the alert view
        if ([title isKindOfClass:[UIImage class]])
            [alertView setContainerView:[UIAlertView createCustomTitleImage:title message:message]];
        else
            [alertView setContainerView:[UIAlertView createCustomBodyLabel:title message:message]];
        
        // Modify the parameters
        NSMutableArray *buttonTitles = [NSMutableArray array];
        if (cancelButton.length > 0) [buttonTitles addObject:cancelButton];
        if (otherButton.length > 0) [buttonTitles addObject:otherButton];
        if (buttonTitles.count < 1) [buttonTitles addObject:(@"OK")];
        alertView.buttonTitles = buttonTitles;
        
        // You may use a Block, rather than a delegate.
        [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
            if (handler)
                handler(buttonIndex);
            [alertView close];
            
            sCustomAlertView = nil;
        }];
        
        [alertView setUseMotionEffects:true];
        //tap
        if (tapTextAttachment) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:alertView action:@selector(attachmentTapped:)];
            tapGesture.numberOfTouchesRequired = 1;
            [alertView addGestureRecognizer:tapGesture];
        }
        
        // And launch the dialog
        [alertView show];
        
        sCustomAlertView = alertView;
        
        return alertView;
    } else {
        static UIAlertViewDelegate* sAlertDelegate = nil;
        if (sAlertDelegate == nil)
            sAlertDelegate = [UIAlertViewDelegate new];
        sAlertDelegate.completeHandler = handler;
        
        if (sCurrentAlertView)
            [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
        
        sCurrentAlertView = [[UIAlertView alloc] initWithTitle:title message:message.string delegate:sAlertDelegate cancelButtonTitle:(cancelButton ? cancelButton : (@"No")) otherButtonTitles:(otherButton ? otherButton : (@"Yes")), nil];
        
        UILabel* bodyLabel = [sCurrentAlertView getBodyTextLabel];
        if (bodyLabel) {
            bodyLabel.attributedText = message;
            bodyLabel.textAlignment = NSTextAlignmentLeft;
        }
        [sCurrentAlertView show];
    }
    return sCurrentAlertView;
}

@end

@interface UIDataAlertView()
@end

@implementation UIDataAlertView

@synthesize anyData;

+ (UIDataAlertView*)showAlertMessage:(NSString*)message delegate:(id)delegate data:(id)data  {
    if (sCurrentAlertView)
        [sCurrentAlertView dismissWithClickedButtonIndex:CancelButton animated:NO];
    
    UIDataAlertView* alert = [[UIDataAlertView alloc] initWithTitle:@"" message:message delegate:delegate cancelButtonTitle:@"아니" otherButtonTitles:@"예", nil];
    UILabel* bodyLabel = [alert getBodyTextLabel];
    if (bodyLabel) {
        bodyLabel.textAlignment = NSTextAlignmentLeft;
        bodyLabel.font = [UIFont systemFontOfSize:14];
    }
    
    alert.anyData = data;
    
    [alert show];
    
    sCurrentAlertView = alert;
    
    return alert;
}


@end