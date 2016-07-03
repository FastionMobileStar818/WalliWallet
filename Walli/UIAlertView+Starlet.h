//
//  UIAlertView+Starlet.h
//  Starlet
//
//  Created by Lion User on 20/08/2013.
//  Copyright (c) 2013 Starlet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OKButton        1
#define CancelButton    0

typedef void (^AlertCompleteHandler)(NSInteger buttonIndex);

#define UIAlertViewTextAttachmentTapNotification    @"UIAlertViewTextAttachmentTapNotification"

@interface UIAlertView (Starlet)

+ (void)showMessage:(NSString*)message;
+ (UIAlertView*)showMessage:(NSString*)message delegate:(id)delegate;
+ (UIAlertView*)showMessage:(NSString*)message align:(NSTextAlignment)alignment delegate:(id)delegate;
+ (UIAlertView*)showAlertMessage:(NSString*)message delegate:(id)delegate;
+ (UIAlertView*)showPushMessage:(NSString*)message showView:(BOOL)showView complete:(AlertCompleteHandler) handler;

+ (void)showMessage:(NSString*)message complete:(AlertCompleteHandler) handler;
+ (void)showAlertMessage:(NSString*)message complete:(AlertCompleteHandler) handler;
+ (void)showAlertMessage:(NSString*)message yesTitle:(NSString*)title noTitle:(NSString*)other complete:(AlertCompleteHandler) handler;

+ (void)closeCustomAlertView;

+ (id)showMessageWithTitle:(NSString*)title message:(NSAttributedString*)message button:(NSString*)buttonTitle complete:(AlertCompleteHandler) handler;

+ (id)showMessageWithTitleImage:(UIImage*)titleImage message:(NSAttributedString*)message button:(NSString*)buttonTitle complete:(AlertCompleteHandler) handler;

+ (id)showMessageWithTitle:(NSString*)title message:(NSAttributedString*)message button:(NSString*)buttonTitle  tap:(BOOL)tapTextAttachment complete:(AlertCompleteHandler) handler;

+ (id)showAlertTitle:(id)title message:(NSAttributedString*)message cancel:(NSString*)cancelButton other:(NSString*)otherButton tap:(BOOL)tapTextAttachment complete:(AlertCompleteHandler) handler;

@end

@interface UIDataAlertView : UIAlertView
@property (strong, nonatomic) id anyData;

+ (UIDataAlertView*)showAlertMessage:(NSString*)message delegate:(id)delegate data:(id)data;

@end
