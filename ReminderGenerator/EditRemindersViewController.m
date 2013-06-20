//
//  ReminderViewController.m
//  ReminderGenerator
//
//  Created by Jeff Dean on 6/19/13.
//  Copyright (c) 2013 Doubled Rooks Inc. All rights reserved.
//

#import "EditRemindersViewController.h"
#import <EventKit/EventKit.h>

@interface EditRemindersViewController ()

@end

@implementation EditRemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Loaded Edit View");
    self.flashView.alpha = 0;
}

- (IBAction)didTapCreateReminderButton:(id)sender {
    EKEventStore *eventStore = [EKEventStore new];

    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *reminders = @[
                    @{@"title": @"Go to Google", @"notes": @""},
                    @{@"title": @"Go to Amazon", @"notes": @""},
                    @{@"title": @"Go to Apple", @"notes": @""},
                ];
            
                EKCalendar *calendar = [eventStore defaultCalendarForNewReminders];
                for (NSDictionary *reminderInfo in reminders) {
                    NSLog(@"Creating reminder titled %@", reminderInfo[@"title"]);
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


- (IBAction)didTapCreateReminderInLists:(id)sender {
    EKEventStore *eventStore = [EKEventStore new];

    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSDictionary *calendars = @{
                    @"Personal": @[
                        @{@"title": @"Learn to juggle", @"notes": @""},
                        @{@"title": @"Climb more", @"notes": @""},
                        @{@"title": @"Lose 10 pounds", @"notes": @""},
                    ],
                    @"Responsibilities": @[
                        @{@"title": @"Mow lawn", @"notes": @""},
                        @{@"title": @"Pay bills", @"notes": @""},
                        @{@"title": @"Fix car", @"notes": @""},
                    ],
                    @"Relationships": @[
                        @{@"title": @"Call mom", @"notes": @""},
                        @{@"title": @"Check in with Adam", @"notes": @""},
                        @{@"title": @"Send dad birthday card", @"notes": @""},
                    ],
                };
            
                NSInteger reminderCount = 0;
                NSInteger calendarCount = calendars.count;

                for (NSString *calendarName in calendars) {
                    NSLog(@"Creating calendar named %@", calendarName);
                    EKCalendar *calendar = [self createCalendarWithName:calendarName withEventStore:eventStore];
                    NSArray *reminders = [calendars objectForKey:calendarName];
                    for(NSDictionary *reminderInfo in reminders) {
                        NSLog(@"  creating reminder titled %@", reminderInfo[@"title"]);
                        EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
                        reminder.calendar = calendar;
                        reminder.title = reminderInfo[@"title"];
                        reminder.notes = reminderInfo[@"notes"];
                        [eventStore saveReminder:reminder commit:YES error:nil];
                        reminderCount++;
                    }
                }
                [self setFlash:[NSString stringWithFormat:@"%d reminders in %d lists were created", reminderCount, calendarCount]];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}

- (IBAction)didTapDeleteAllRemindersButton:(id)sender {
    EKEventStore *eventStore = [EKEventStore new];

    [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *calendars = [eventStore calendarsForEntityType:EKEntityTypeReminder];
                for(EKCalendar *calendar in calendars) {
                    NSLog(@"Deleting calendar named %@", calendar.title);
                    [eventStore removeCalendar:calendar commit:YES error:nil];
                }
                [self setFlash:[NSString stringWithFormat:@"%d Reminder lists were deleted", calendars.count]];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}

- (EKCalendar *)createCalendarWithName:(NSString *)calendarName withEventStore:(EKEventStore *)eventStore {
    EKCalendar* calendar;
    calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:eventStore];
    
    EKSource* localSource;
    for (EKSource* source in eventStore.sources) {
        NSLog(@"Source type matches %d", source.sourceType == EKSourceTypeLocal);
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }

    calendar.source = localSource;
    calendar.title = calendarName;
    NSError* error;
    [eventStore saveCalendar:calendar commit:YES error:&error];
    if(error) {
        NSLog(@"Could not create calendar %@", calendar.title);
        NSLog(@"%@", error.description);
    }
    return calendar;
}

- (void)setFlash:(NSString *)message {
    self.flashView.alpha = 1;
    self.flashLabel.text = message;
    [self performSelector:@selector(fadeFlash) withObject:nil afterDelay:3.5];
}

- (void)fadeFlash {
    [UIView animateWithDuration:1.5 animations:^() {
        self.flashView.alpha = 0.0f;
    }];
}

@end
