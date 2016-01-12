//
//  PerfilViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "PerfilViewController.h"
#import "SWRevealViewController.h"
#import "PerfilTableViewCell.h"
#import "GlobalVars.h"

@interface PerfilViewController (){
    NSMutableArray *data;
    
    NSInteger indexToDelete;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PerfilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    indexToDelete = -1;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadDatabase];
}


- (IBAction)delete:(UIButton*)sender {
    if ([data count] > 1) {
        indexToDelete = sender.tag;
        UIAlertView *delete = [[UIAlertView alloc] initWithTitle:@"¿ Eliminar cuenta ?" message:@"¿ Está seguro de eliminar la cuenta seleccionada ?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Si", nil];
        [delete show];
    } else {
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"No puedes eliminar todas las cuentas" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        [errorAlert show];
    }
}


- (FMDatabase *)openDatabase
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"edea.sqlite"]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:@"edea" ofType:@"sqlite"];
    
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    if (![db open])
        NSLog(@"Failed to open database!");
    return db;
}


-(void)loadDatabase{
    data = [[NSMutableArray alloc] init];
    FMDatabase *db = [self openDatabase];
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM user"];
    while([results next]) {
        NSDictionary* dict = @{@"id":@([results intForColumn:@"id"]),
                               @"nombre":[results stringForColumn:@"nombre"],
                               @"cuenta":@([results intForColumn:@"cuenta"]),
                               @"sucursal":@([results intForColumn:@"sucursal"]),
                               @"domicilio":[results stringForColumn:@"domicilio"],
                               @"validada":@([results intForColumn:@"validada"])};
        [data addObject:dict];
    }
    [self.tableView reloadData];
}

#pragma mark - TableView


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSDictionary * userSelectedData = [data objectAtIndex:indexPath.row];
    BOOL validada = [[userSelectedData objectForKey:@"validada"] boolValue];
    if (validada) {
        [[GlobalVars sharedInstance] resetAndSelectUserAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *temp = [data objectAtIndex:indexPath.row];
    PerfilTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.selectedImage.hidden = YES;
    cell.selectedImage.image = [UIImage imageNamed:@"tilde-verde"];
    cell.account.text = [NSString stringWithFormat:@"%@ - %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"]];
    cell.address.text = [temp objectForKey:@"domicilio"];
    cell.deleteButton.tag = indexPath.row;
    if ([GlobalVars sharedInstance].selectedAccount == indexPath.row) {
        cell.selectedImage.hidden = NO;
    }
    if (![[temp objectForKey:@"validada"] boolValue]) {
        cell.selectedImage.hidden = NO;
        cell.selectedImage.image = [UIImage imageNamed:@"invalidada"];
    }
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return data.count;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        NSDictionary *temp = [data objectAtIndex:indexToDelete];
        FMDatabase *db = [self openDatabase];
        [db open];
        [db executeUpdate:@"DELETE FROM user WHERE id = ?", [temp objectForKey:@"id"]];
        
        GlobalVars * globals = [GlobalVars sharedInstance];
        [data removeObjectAtIndex:indexToDelete];
        if (globals.selectedAccount == indexToDelete) {
            [globals resetAndSelectUserAtIndex:0];
        } else {
            if (globals.selectedAccount > 0) {
                [globals resetAndSelectUserAtIndex:globals.selectedAccount-1];
            } else {
                [globals resetAndSelectUserAtIndex:0];
            }
        }
        [_tableView reloadData];
    }
}

#pragma mark - Menu

- (IBAction)showMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
