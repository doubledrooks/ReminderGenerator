//
//  RemindersViewController.h
//  ReminderGenerator
//
//  Created by Jeff Dean on 6/19/13.
//  Copyright (c) 2013 Doubled Rooks Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
