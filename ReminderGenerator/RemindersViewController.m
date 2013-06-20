//
//  RemindersViewController.m
//  ReminderGenerator
//
//  Created by Jeff Dean on 6/19/13.
//  Copyright (c) 2013 Doubled Rooks Inc. All rights reserved.
//

#import "RemindersViewController.h"
#import <EventKit/EventKit.h>

@interface RemindersViewController ()
@property(strong, nonatomic) EKEventStore *eventStore;
@property(strong, nonatomic) NSDictionary *groupedReminders;
@property(strong, nonatomic) NSArray *calendars;
@end

@implementation RemindersViewController

- (void)viewDidLoad{
    self.eventStore = [EKEventStore new];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Loaded Table View");

    [self getGroupedRemindersOnComplete:^(NSDictionary *reminders) {
        self.groupedReminders = reminders;
        self.calendars = [[self.groupedReminders allKeys]
            sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [a compare:b];
            }];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.calendars.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)self.groupedReminders[self.calendars[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ReminderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [UITableViewCell new];
    }
    NSArray *reminders = self.groupedReminders[self.calendars[indexPath.section]];
    EKReminder *reminder = reminders[indexPath.row];
    cell.textLabel.text = reminder.title;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.calendars[section];
}

#pragma mark - Table view delegate

#pragma mark Private Methods

- (void)getGroupedRemindersOnComplete:(void(^)(NSDictionary *))completeBlock {
    NSMutableDictionary *groupedReminders = [NSMutableDictionary dictionary];
    NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];

    NSPredicate *predicate = [self.eventStore
        predicateForIncompleteRemindersWithDueDateStarting:nil
        ending:nil
        calendars:calendars];

    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *events) {
        for(EKReminder *reminder in events) {
            if (!groupedReminders[reminder.calendar.title]) {
                [groupedReminders setObject:[NSMutableArray array] forKey:reminder.calendar.title];
            }

            [[groupedReminders objectForKey:reminder.calendar.title] addObject: reminder];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(groupedReminders);
            }
        });
    }];
}


@end
