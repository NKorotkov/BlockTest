//
//  ViewController.m
//  BlockTest
//
//  Created by Nikolay Korotkov on 07/07/15.
//  Copyright (c) 2015 Simple Communication. All rights reserved.
//

#import "ViewController.h"

NSTimeInterval _delay = 2.0;

#define _GLOBAL_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ViewController ()

@property (copy, nonatomic) void (^aBlock)();

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Actions

- (IBAction)dispatchCycle:(id)sender {
    
    self.aBlock = ^{
        
        [NSThread sleepForTimeInterval:_delay];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        
        NSLog(@"SELF is: %@", self);
        
#pragma clang diagnostic pop
        
        NSLog(@"Dealloc is never called. Welcome to retain cycle!");
        
    };
    
    [self dispatchTask];
    
}

- (IBAction)dispatchWithoutCycle:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    self.aBlock = ^{
        
        [NSThread sleepForTimeInterval:_delay];
        NSLog(@"SELF is: %@", weakSelf);
        
        if (!weakSelf) {
             NSLog(@"SELF was released before execution!");
        }
       
        
    };
    
    [self dispatchTask];
    
}

- (IBAction)dispatchWithoutCycleSafe:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    self.aBlock = ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [NSThread sleepForTimeInterval:_delay];
        NSLog(@"SELF is: %@", strongSelf);
        
    };
    
    [self dispatchTask];
    
    
}

- (void)popToRoot {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)dispatchTask {
    
    NSLog(@"Dispatching task");
    
    dispatch_async(_GLOBAL_QUEUE, self.aBlock);
    
    [self popToRoot];
    
}


#pragma mark - Dealloc

- (void)dealloc {
    
    NSLog(@"SELF if deallocated!");
    
}

@end
