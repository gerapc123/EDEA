//
//  TerminosViewController.m
//  
//
//  Created by Vincent Villalta on 10/28/15.
//
//

#import "TerminosViewController.h"

@interface TerminosViewController ()

@end

@implementation TerminosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)accept:(id)sender {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us setBool:true forKey:@"accepted"];
    [self dismissViewControllerAnimated:true completion:nil];
    
}

-(IBAction)dismissTYC:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
