//
//  AddAccountViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "AddAccountViewController.h"
#import "Constants.h"
#import <FMDB/FMDB.h>
@interface AddAccountViewController (){
    SOAPEngine *soap;
}

@end

@implementation AddAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    soap = [[SOAPEngine alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendUser:(id)sender {
    if ([self.accountPrefix.text isEqualToString:@""] ||
        [self.account.text isEqualToString:@""] ||
        [self.name.text isEqualToString:@""] ||
        [self.mail.text isEqualToString:@""]) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Formulario incompleto" message:@"Todos los campos son obligatorios" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [SVProgressHUD show];
    soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
    soap.userAgent = @"SOAPEngine";
    soap.delegate = self;
    soap.authorizationMethod = SOAP_AUTH_BASIC;
    soap.username = @"app";
    soap.password = @"apptest";
    [soap setIntegerValue:[self.accountPrefix.text intValue] forKey:@"sucursal"];
    [soap setIntegerValue:[self.account.text intValue] forKey:@"cuenta"];
    [soap setValue:self.name.text forKey:@"nombre"];
    [soap setValue:self.mail.text forKey:@"email"];
    [soap setValue:[UserDefaults objectForKey:@"token"] forKey:@"movil"];
    [soap requestURL:kWs soapAction:appRegistro];
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD dismiss];
    NSDictionary *result = [soapEngine dictionaryValue];
    NSLog(@"%@", result);
    
    if (![[result objectForKey:@"TRegistroList"] isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Falló la registración, verifique sus datos" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString * estado = [[[result objectForKey:@"TRegistroList"] objectForKey:@"TRegistro"] objectForKey:@"estado"];
    
    if (estado && ![estado isEqualToString:@""]) {
        if ([estado isEqualToString: @"OK"] || [estado isEqualToString:@"00"]) {
            
            //Chequeo si no es status 00 y error
            NSString * message = [[[result objectForKey:@"TRegistroList"] objectForKey:@"TRegistro"] objectForKey:@"mensaje"];
            if ([message isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada, debes ingresar con una cuenta validada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
                return;
            }
            
            NSString *domicilio  = [[[result objectForKey:@"TRegistroList"] objectForKey:@"TRegistro"] objectForKey:@"domicilio"];
            if (!domicilio) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada, debes ingresar con una cuenta validada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
                return;
            }
            FMDatabase *db = [self openDatabase];
            [db open];
        
            
            NSInteger validada = [estado isEqualToString:@"OK"];
            
            BOOL Success = [db executeUpdate:@"INSERT INTO user (nombre, email, cuenta, sucursal, domicilio, validada) VALUES (?, ?, ?, ?, ?, ?)" withArgumentsInArray:@[[self normalizeString:self.name.text], [self normalizeString:self.mail.text], [self normalizeString:self.account.text], [self normalizeString:self.accountPrefix.text], domicilio, [NSString stringWithFormat:@"%d", validada]]];
            if (Success && !validada) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración pendiente de aprobación" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([estado isEqualToString: @"01"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sucursal y/o cuenta inexistente" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        } else if ([estado isEqualToString: @"02"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada, debes ingresar con una cuenta validada" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
}

-(NSString*)normalizeString:(NSString*)string{
    return [[NSString alloc] initWithData:
                         [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]
                         encoding:NSASCIIStringEncoding];
}

- (IBAction)dismiss:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
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


@end
