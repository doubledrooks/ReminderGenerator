//
//  ReminderViewController.h
//  ReminderGenerator
//
//  Created by Jeff Dean on 6/19/13.
//  Copyright (c) 2013 Doubled Rooks Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditRemindersViewController : UIViewController

- (IBAction)didTapCreateReminderButton:(id)sender;
- (IBAction)didTapDeleteAllRemindersButton:(id)sender;
- (IBAction)didTapCreateReminderInLists:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *flashLabel;
@property (strong, nonatomic) IBOutlet UIView *flashView;

@end
