//
//  ConsumosViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "ConsumosViewController.h"
#import "SWRevealViewController.h"
#import "SimpleBarChart.h"
#import "GlobalVars.h"
@interface ConsumosViewController ()<SimpleBarChartDataSource, SimpleBarChartDelegate>
{
    NSMutableArray *data;
    NSMutableArray *users;
    CZPickerView *picker;
    NSMutableArray *_values;
    IBOutlet SimpleBarChart *_chart;
    NSArray *_barColors;
    
}
@property (weak, nonatomic) IBOutlet UIButton *select;
@property (weak, nonatomic) IBOutlet UILabel *cuenta;
@property (weak, nonatomic) IBOutlet UILabel *domicilio;
@property (weak, nonatomic) IBOutlet UIView *chartView;

@end

@implementation ConsumosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _values	= [[NSMutableArray alloc] init];
    _barColors = @[[UIColor colorWithRed:0.541 green:0.922 blue:0.996 alpha:1], [UIColor redColor], [UIColor blackColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor greenColor]];
    
    _chart.delegate	= self;
    _chart.dataSource = self;
    _chart.barShadowOffset = CGSizeMake(2.0, 1.0);
    _chart.animationDuration = 1.0;
    _chart.barShadowColor = [UIColor grayColor];
    _chart.barShadowAlpha = 0.5;
    _chart.barShadowRadius = 1.0;
    _chart.barWidth	= 23.0;
    _chart.xLabelType = SimpleBarChartXLabelTypeHorizontal;
    _chart.xLabelFont = [UIFont fontWithName:@"Helvetica" size:10.0f];
    _chart.yLabelFont = [UIFont fontWithName:@"Helvetica" size:10.0f];
    _chart.barTextFont = [UIFont fontWithName:@"Helvetica" size:10.0f];
    _chart.barTextType = SimpleBarChartBarTextTypeRoof;
    _chart.barTextColor	= [UIColor blackColor];
    _chart.gridColor = [UIColor grayColor];
}


- (IBAction)selectAccount:(id)sender {
    [picker show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
}


-(void)viewDidAppear:(BOOL)animated{
    [self getUsersFromDatabase];
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    [self showAccountWithPositionInArray:globals.selectedAccount];
    
    picker = [[CZPickerView alloc] initWithHeaderTitle:@"Cuentas"
                                     cancelButtonTitle:@"Cancelar"
                                    confirmButtonTitle:@"Seleccionar"];
    [picker setSelectedRows:[NSArray arrayWithObject:[NSNumber numberWithInt:globals.selectedAccount]]];
    picker.delegate = self;
    picker.dataSource = self;
    [picker setHeaderBackgroundColor:[self.view backgroundColor]];
}


-(void)getUsersFromDatabase{
    data = [[NSMutableArray alloc] init];
    users = [[NSMutableArray alloc] init];
    
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
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    if (globals.consumosArray == nil) {
        [globals initConsumosArrayWithUsers:users];
    }
}

-(void)showAccountWithPositionInArray: (NSInteger)positon{
    NSDictionary *temp = [users objectAtIndex:positon];
    self.cuenta.text = [NSString stringWithFormat:@"%@ - %@", [temp objectForKey:@"sucursal"], [temp objectForKey:@"cuenta"]];
    self.domicilio.text = [temp objectForKey:@"domicilio"];
    
    [SVProgressHUD show];
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([[globals.consumosArray objectAtIndex:positon] isKindOfClass:[NSString class]]) {
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
        [soap requestURL:kWs soapAction:getConsumoHistorico];
    } else {
        [SVProgressHUD dismiss];
        _values = [globals.consumosArray objectAtIndex:positon];
        [_chart reloadData];
    }
}

#pragma mark - SOAP

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD dismiss];
    NSDictionary *result = [soapEngine dictionaryValue];
    _values = [[result objectForKey:@"TConsumoHistoricoList"] objectForKey:@"TConsumoHistorico"];
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    [globals.consumosArray setObject:_values atIndexedSubscript:globals.selectedAccount];
    
    [_chart reloadData];
}

#pragma mark - Chart

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    int maxConsumo = 0;
    for (NSDictionary * aValueDict in _values) {
        int consumo = [[aValueDict objectForKey:@"consumo"] intValue];
        if (consumo > maxConsumo) {
            maxConsumo = consumo;
        }
    }
    _chart.incrementValue = maxConsumo/6;
    
    return _values.count;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    return [[[_values objectAtIndex:index] objectForKey:@"consumo"] floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"%@ kWh", [[_values objectAtIndex:index] objectForKey:@"consumo"]];
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] objectForKey:@"periodo"];
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    return [_barColors objectAtIndex:0];
}


#pragma mark - DATABASE

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

#pragma mark - CZPickerView

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
    globals.consumos = nil;
    globals.facturas = nil;
    [self showAccountWithPositionInArray:row];
    
}

@end
