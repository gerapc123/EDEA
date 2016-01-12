//
//  FacturasViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "FacturasViewController.h"
#import "SWRevealViewController.h"
#import "FacturaTableViewCell.h"
#import "GlobalVars.h"
@interface FacturasViewController (){
    NSMutableArray *data;
    NSMutableArray *users;
    CZPickerView *picker;
    NSInteger selectedAccount;
    NSString *optionSelected;
}

@property (weak, nonatomic) IBOutlet UIButton *select;
@property (weak, nonatomic) IBOutlet UILabel *cuenta;
@property (weak, nonatomic) IBOutlet UILabel *domicilio;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FacturasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    data = [[NSMutableArray alloc] init];
    users = [[NSMutableArray alloc] init];
    
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


////////// CONTRUCT ACCOUNTS
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    FMDatabase *db = [self openDatabase];
    [db open];
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM user"];
    if ([s next]) {
        int totalCount = [s intForColumnIndex:0];
        if (totalCount > 1) {
            self.select.hidden = NO;
        }
    }
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM user"];
    while([results next]) {
        NSDictionary* dict = @{@"id":@([results intForColumn:@"id"]), @"nombre":[results stringForColumn:@"nombre"], @"cuenta":@([results intForColumn:@"cuenta"]), @"sucursal":@([results intForColumn:@"sucursal"]), @"domicilio":[results stringForColumn:@"domicilio"]};
        [users addObject:dict];
    }
    
    
    picker = [[CZPickerView alloc] initWithHeaderTitle:@"Cuentas"
                                     cancelButtonTitle:@"Cancelar"
                                    confirmButtonTitle:@"Seleccionar"];
    picker.delegate = self;
    picker.dataSource = self;
    [picker setHeaderBackgroundColor:[self.view backgroundColor]];
    GlobalVars *globals = [GlobalVars sharedInstance];
    [picker setSelectedRows:[NSArray arrayWithObject:[NSNumber numberWithInt:globals.selectedAccount]]];
    
    [self showAccountWithPositionInArray:globals.selectedAccount];
}


-(void)showAccountWithPositionInArray: (NSInteger)positon{
    NSDictionary *temp = [users objectAtIndex:positon];
    self.cuenta.text = [NSString stringWithFormat:@"%@ - %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"]];
    self.domicilio.text = [temp objectForKey:@"domicilio"];
    selectedAccount  = positon;
    
    [SVProgressHUD show];
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    if (globals.facturas.count > 0) {
        data = [globals.facturas copy];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }else{
        NSDictionary *tem = [users objectAtIndex:positon];
        SOAPEngine *soap = [[SOAPEngine alloc] init];
        soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
        soap.userAgent = @"SOAPEngine";
        soap.delegate = self;
        soap.authorizationMethod = SOAP_AUTH_BASIC;
        soap.username = @"app";
        soap.password = @"apptest";
        [soap setIntegerValue:[[tem objectForKey:@"sucursal"] integerValue] forKey:@"sucursal"];
        [soap setIntegerValue:[[tem objectForKey:@"cuenta"] integerValue]forKey:@"cuenta"];
        [soap requestURL:kWs soapAction:consultaFacturas];
    }
}


- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD dismiss];
    NSDictionary *result = [soapEngine dictionaryValue];

    GlobalVars *globals = [GlobalVars sharedInstance];
    if (globals.facturas.count > 0) {
        data = [globals.facturas copy];
        
    }else{
        data = [[result objectForKey:@"TConsultaFacturasList"] objectForKey:@"TConsultaFacturas"];
        globals.facturas = [[result objectForKey:@"TConsultaFacturasList"] objectForKey:@"TConsultaFacturas"];
    }
    
    [self.tableView reloadData];
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


- (IBAction)selectAccount:(id)sender {
    [picker show];
}


-(NSString *)czpickerView:(CZPickerView *)pickerView titleForRow:(NSInteger)row{
    NSDictionary *temp = [users objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ - %@ / %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"], [temp objectForKey:@"domicilio"]];
}


- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return users.count;
}


-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
    GlobalVars *globals = [GlobalVars sharedInstance];
    globals.selectedAccount = row;
    globals.facturas = nil;
    globals.consumos = nil;
    
    [self showAccountWithPositionInArray:row];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *temp = [data objectAtIndex:indexPath.row];
    FacturaTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.emision.text = [temp objectForKey:@"vencimiento"];
    cell.importe.text = [NSString stringWithFormat:@"$%@", [temp objectForKey:@"importe"]];
    NSString *stats = [temp objectForKey:@"estado"];
    cell.estado.text = stats;
    if ([stats isEqualToString:@"Paga"]) {
        cell.estado.textColor = [UIColor greenColor];
    }else{
        cell.estado.textColor = [UIColor redColor];
    }
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return data.count;
}


@end
