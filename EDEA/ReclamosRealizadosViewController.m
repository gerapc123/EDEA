//
//  ReclamosRealizadosViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "ReclamosRealizadosViewController.h"
#import "ReclamosTableViewCell.h"
#import "GlobalVars.h"
@interface ReclamosRealizadosViewController (){
    NSMutableArray *data;
    NSMutableArray *tableViewData;
    CZPickerView *picker;
    NSInteger selectedAccount;
}
@property (weak, nonatomic) IBOutlet UIButton *select;
@property (weak, nonatomic) IBOutlet UILabel *cuenta;
@property (weak, nonatomic) IBOutlet UILabel *domicilio;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ReclamosRealizadosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableViewData = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////// CONTRUCT ACCOUNTS
-(void)viewDidAppear:(BOOL)animated{
    data = [[NSMutableArray alloc] init];
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
        NSDictionary* dict = @{@"id":@([results intForColumn:@"id"]), @"nombre":[results stringForColumn:@"nombre"], @"cuenta":@([results intForColumn:@"cuenta"]), @"sucursal":@([results intForColumn:@"sucursal"]), @"domicilio":[results stringForColumn:@"domicilio"], @"validada":[results stringForColumn:@"validada"]};
        if ([(NSString*)[dict objectForKey:@"validada"] boolValue]) {
            [data addObject:dict];
        }
    }
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    [self showAccountWithPositionInArray:globals.selectedAccount];
    
    picker = [[CZPickerView alloc] initWithHeaderTitle:@"Cuentas"
                                     cancelButtonTitle:@"Cancelar"
                                    confirmButtonTitle:@"Seleccionar"];
    picker.delegate = self;
    picker.dataSource = self;
    [picker setSelectedRows:[NSArray arrayWithObject:[NSNumber numberWithInt:globals.selectedAccount]]];
    [picker setHeaderBackgroundColor:[UIColor colorWithRed:102/255.0f green:204/255.0f blue:1.0f alpha:1.0f]];
}

-(void)showAccountWithPositionInArray: (NSInteger)positon{
    NSDictionary *temp = [data objectAtIndex:positon];
    self.cuenta.text = [NSString stringWithFormat:@"%@ - %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"]];
    self.domicilio.text = [temp objectForKey:@"domicilio"];
    selectedAccount  = positon;
    
    [SVProgressHUD show];
    NSDictionary *tem = [data objectAtIndex:positon];
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
    soap.userAgent = @"SOAPEngine";
    soap.delegate = self;
    soap.authorizationMethod = SOAP_AUTH_BASIC;
    soap.username = @"app";
    soap.password = @"apptest";
    [soap setIntegerValue:[[tem objectForKey:@"sucursal"] integerValue] forKey:@"sucursal"];
    [soap setIntegerValue:[[tem objectForKey:@"cuenta"] integerValue]forKey:@"cuenta"];
    [soap requestURL:kWs soapAction:appConsultaReclamoTecnico];
}


- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD dismiss];
    NSDictionary *result = [soapEngine dictionaryValue];
    NSLog(@"%@", result);
    [tableViewData removeAllObjects];
    NSDictionary *tempDic = [result objectForKey:@"TConsultaRecTecList"];
    
    if ([tempDic isKindOfClass:[NSDictionary class]] && tempDic.count > 0) {
        id listaDeReclamos = [tempDic objectForKey:@"TRecTec_Estado"];
        if ([listaDeReclamos isKindOfClass:[NSArray class]]) {
            NSArray *miListaDeReclamos = [tempDic objectForKey:@"TRecTec_Estado"] ;
            for (NSDictionary * temp in miListaDeReclamos) {
                [tableViewData addObject:temp];
            }
        } else if ([listaDeReclamos isKindOfClass:[NSDictionary class]]){
            [tableViewData addObject:listaDeReclamos];
        }
        [self.tableView reloadData];
    } else {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"" message:@"No hay reclamos para la cuenta seleccionada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [aler show];
        [self back:nil];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableViewData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *temp = [tableViewData objectAtIndex:indexPath.row];
    ReclamosTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *label = [[temp objectForKey:@"motivo"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    label = [label stringByReplacingOccurrencesOfString:@"Ã" withString:@"Ó"];

    cell.tituloReclamo.text = label;
    
    cell.fechaReclamo.text = [NSString stringWithFormat:@"Fecha: %@", [temp objectForKey:@"fecha"]];
    cell.numeroReclamo.text = [NSString stringWithFormat:@"Número de reclamo: %@", [temp objectForKey:@"nro_reclamo"]];
    if ([[NSString stringWithFormat:@"%@",[temp objectForKey:@"estado"]] isEqualToString:@"PENDIENTE"]) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        [cell setTintColor:[UIColor colorWithRed:0.847 green:0.737 blue:0.592 alpha:1]];
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell setTintColor:[UIColor colorWithRed:0.341 green:0.435 blue:0 alpha:1] ];
    }
    return cell;
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
    NSDictionary *temp = [data objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ - %@ / %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"], [temp objectForKey:@"domicilio"]];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return data.count;
}

-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    globals.selectedAccount = row;
    globals.facturas = nil;
    globals.consumos = nil;
    
    [self showAccountWithPositionInArray:row];
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
