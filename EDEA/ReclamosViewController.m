//
//  ReclamosViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "ReclamosViewController.h"
#import "SWRevealViewController.h"
#import <LGRadioButtonsView/LGRadioButtonsView.h>
#import "DLRadioButton.h"
#import "GlobalVars.h"
@interface ReclamosViewController (){
    NSMutableArray *data;
    CZPickerView *picker;
    NSArray *options;
    NSInteger selectedAccount;
    NSString *optionSelected;
}
@property (weak, nonatomic) IBOutlet UIButton *select;
@property (weak, nonatomic) IBOutlet UILabel *cuenta;
@property (weak, nonatomic) IBOutlet UILabel *domicilio;
@property (strong, nonatomic) LGRadioButtonsView    *options;
@property (weak, nonatomic) IBOutlet UIView *optionContainer;
@property (nonatomic) NSArray *buttomRadioButtons;
@end

@implementation ReclamosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float height = self.optionContainer.frame.size.height / 6 - 5;
    float y = 0;
    options = @[@"Falta suministro", @"Baja Tensión", @"Sobretensión", @"Pared electrizada", @"Cable cortado", @"Poste roto"];
    NSArray *values = @[@01, @02, @03, @05, @06, @14];
    DLRadioButton *firstButton = [[DLRadioButton alloc] initWithFrame:CGRectMake(5, y, self.optionContainer.frame.size.width, height)];
    firstButton.iconColor = [UIColor blackColor];
    [firstButton setTitle:[options objectAtIndex:0] forState:UIControlStateNormal];
    firstButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [firstButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    firstButton.tag = [[values objectAtIndex:0] integerValue];
    firstButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [firstButton addTarget:self action:@selector(logSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionContainer addSubview:firstButton];
    y += height;
    NSMutableArray *otherButtons = [NSMutableArray new];
    for (int i = 1; i < options.count; i++) {
        DLRadioButton *select = [[DLRadioButton alloc] initWithFrame:CGRectMake(5, y, self.optionContainer.frame.size.width, height)];
        [select setTitle:[options objectAtIndex:i] forState:UIControlStateNormal];
        select.iconColor = [UIColor blackColor];
        select.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        select.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        select.tag = [[values objectAtIndex:i] integerValue];
        [select addTarget:self action:@selector(logSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        [select setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [otherButtons addObject:select];
        [self.optionContainer addSubview:select];
        y += height;
    }
    firstButton.otherButtons = otherButtons;
    self.buttomRadioButtons = [@[firstButton] arrayByAddingObjectsFromArray:otherButtons];
}

- (IBAction)sendReclamo:(id)sender {
    [SVProgressHUD show];
    NSDictionary *temp = [data objectAtIndex:selectedAccount];
    SOAPEngine *soap = [[SOAPEngine alloc] init];
    soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
    soap.userAgent = @"SOAPEngine";
    soap.delegate = self;
    soap.authorizationMethod = SOAP_AUTH_BASIC;
    soap.username = @"app";
    soap.password = @"apptest";
    [soap setIntegerValue:[[temp objectForKey:@"sucursal"] integerValue] forKey:@"sucursal"];
    [soap setIntegerValue:[[temp objectForKey:@"cuenta"] integerValue]forKey:@"cuenta"];
    [soap setValue: @" " forKey:@"puntom"];
    [soap setValue:optionSelected forKey:@"motivo"];
    [soap requestURL:kWs soapAction:appGeneraReclamoTecnico];
    
}

- (IBAction)logSelectedButton:(DLRadioButton *)radiobutton {
    optionSelected = [NSString stringWithFormat:@"%02ld", (long)radiobutton.selectedButton.tag];
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD showSuccessWithStatus:@"Completado"];
    NSDictionary *result = [soapEngine dictionaryValue];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reclamo" message:[result objectForKey:@"nro_reclamo"]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];

    NSLog(@"%@", result);
    
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showMenu:(id)sender {
    SWRevealViewController *revealController = self.revealViewController;
    [revealController revealToggleAnimated:true];
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
    [self showAccountWithPositionInArray:row];
    GlobalVars *globals = [GlobalVars sharedInstance];
    globals.selectedAccount = row;
    NSLog(@"%@", [data objectAtIndex:row]);
    
}

@end
