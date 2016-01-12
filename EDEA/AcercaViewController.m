//
//  AcercaViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "AcercaViewController.h"
#import "SWRevealViewController.h"
#import "TerminosViewController.h"

@interface AcercaViewController ()

@end

@implementation AcercaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
}


-(IBAction)wwwButtonTapped:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.edeaweb.com.ar/"]];
}


-(IBAction)twitterButtonTapped:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/prensaedea"]];
}


@end
