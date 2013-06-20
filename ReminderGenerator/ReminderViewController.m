//
//  ReminderViewController.m
//  ReminderGenerator
//
//  Created by Jeff Dean on 6/19/13.
//  Copyright (c) 2013 Doubled Rooks Inc. All rights reserved.
//

#import "ReminderViewController.h"
#import <EventKit/EventKit.h>

@interface ReminderViewController ()

@end

@implementation ReminderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapCreateReminderButton:(id)sender {
    EKEventStore *eventStore = [EKEventStore new];

    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *reminders = @[
                    @{@"title": @"Go to Google", @"notes": @"http://google.com/"},
                    @{@"title": @"Go to Amazon", @"notes": @"http://amazon.com/"},
                    @{@"title": @"Go to Apple", @"notes": @"http://apple.com/"},
                ];
            
                EKCalendar *calendar = [eventStore defaultCalendarForNewReminders];
                for (NSDictionary *reminderInfo in reminders) {
                    EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
                    reminder.calendar = calendar;
                    reminder.title = reminderInfo[@"title"];
                    reminder.notes = reminderInfo[@"notes"];
                    [eventStore saveReminder:reminder commit:YES error:nil];
                }
                [self setFlash:[NSString stringWithFormat:@"%d reminders were created", reminders.count]];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}

- (void)setFlash:(NSString *)message {
    self.flashLabel.text = message;
    self.flashLabel.alpha = 1.0f;
    [self performSelector:@selector(fadeFlash) withObject:nil afterDelay:3.5];
}

- (void)fadeFlash {
    [UIView animateWithDuration:1.5 animations:^() {
        self.flashLabel.alpha = 0.0f;
    }];
}

- (IBAction)didTapDeleteAllButton:(id)sender {
    EKEventStore *eventStore = [EKEventStore new];

    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *reminderLists = [eventStore calendarsForEntityType:EKEntityTypeReminder];

                NSPredicate *predicate = [eventStore
                    predicateForIncompleteRemindersWithDueDateStarting:nil
                    ending:nil
                    calendars:reminderLists];

                [eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *events) {
                    NSInteger index = 0;
                    for(EKReminder *reminder in events) {
                      [eventStore removeReminder:reminder commit:YES error:nil];
                      index++;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setFlash:[NSString stringWithFormat:@"%d reminders were deleted", index]];
                    });
                }];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}
@end
