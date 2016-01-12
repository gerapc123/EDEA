//
//  HomeViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "ReclamosViewController.h"
#import "CentrosViewController.h"
#import "ConsumosViewController.h"
#import "FacturasViewController.h"
#import "NovedadesViewController.h"
#import "PerfilViewController.h"
#import "AcercaViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
}

- (IBAction)reclamos:(id)sender {
    ReclamosViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReclamosViewController"];
    [self.navigationController pushViewController:vc animated:false];
}
- (IBAction)centros:(id)sender {
    CentrosViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CentrosViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)consumos:(id)sender {
    ConsumosViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumosViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)facturas:(id)sender {
    FacturasViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FacturasViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)novedades:(id)sender {
    NovedadesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NovedadesViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)perfil:(id)sender {
    PerfilViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PerfilViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)acerca:(id)sender {
    AcercaViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AcercaViewController"];
    [self.navigationController pushViewController:vc animated:false];
}

@end
