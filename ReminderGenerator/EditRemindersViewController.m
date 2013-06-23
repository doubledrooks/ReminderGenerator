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

@property(strong, nonatomic) EKEventStore *eventStore;

@end

@implementation EditRemindersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventStore = [EKEventStore new];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Loaded Edit View");
    self.flashView.alpha = 0;
}

- (void) dealloc {
    self.eventStore = nil;
}

#pragma mark - Button Actions

- (IBAction)didTapCreateReminderButton:(id)sender {
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSDictionary *remindersPlist = [NSDictionary
                    dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                        pathForResource:@"Reminders"
                        ofType:@"plist"]];
 
                EKCalendar *calendar = [self.eventStore defaultCalendarForNewReminders];
                NSInteger index = 0;
                for(NSString *key in remindersPlist) {
                    for (NSDictionary *reminderInfo in [remindersPlist objectForKey:key]) {
                        [self createReminder:reminderInfo inCalendar:calendar];
                        index++;
                    }
                }

                [self setFlash:[NSString stringWithFormat:@"%d reminders were created", index]];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}

- (IBAction)didTapCreateReminderInLists:(id)sender {
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSDictionary *calendars = [NSDictionary
                    dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                        pathForResource:@"Reminders"
                        ofType:@"plist"]];

                NSInteger reminderCount = 0;
                NSInteger calendarCount = calendars.count;

                for (NSString *calendarName in calendars) {
                    NSLog(@"Creating calendar named %@", calendarName);
                    EKCalendar *calendar = [self createCalendarWithName:calendarName withEventStore:self.eventStore];
                    NSArray *reminders = [calendars objectForKey:calendarName];
                    for(NSDictionary *reminderInfo in reminders) {
                        [self createReminder:reminderInfo inCalendar:calendar];
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
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
                for(EKCalendar *calendar in calendars) {
                    NSLog(@"Deleting calendar named %@", calendar.title);
                    [self.eventStore removeCalendar:calendar commit:YES error:nil];
                }
                [self setFlash:[NSString stringWithFormat:@"%d Reminder lists were deleted", calendars.count]];
            }
            else {
                self.flashLabel.text = @"Permission Denied";
            }
        });
    }];
}

#pragma mark - Private Methods

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

- (void)createReminder:(NSDictionary *)reminderInfo inCalendar:(EKCalendar *)calendar {
    NSLog(@"Creating reminder titled %@", reminderInfo[@"Title"]);
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.calendar = calendar;
    reminder.title = reminderInfo[@"Title"];
    reminder.notes = reminderInfo[@"Notes"];
    [self.eventStore saveReminder:reminder commit:YES error:nil];
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
