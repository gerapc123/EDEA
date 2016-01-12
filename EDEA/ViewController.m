//
//  ViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/7/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import <FMDB/FMDB.h>
#import "SWRevealViewController.h"
#import "TerminosViewController.h"
@interface ViewController (){
    SOAPEngine *soap;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    if (![us boolForKey:@"accepted"]) {
        TerminosViewController *t = [self.storyboard instantiateViewControllerWithIdentifier:@"TerminosViewController"];
        [self presentViewController:t animated:true completion:nil];
    }
    soap = [[SOAPEngine alloc] init];
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
    
    NSLog(@"Datos enviados: %@ %@ %@ %@", self.name.text, self.mail.text, self.accountPrefix.text, self.account.text);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    [SVProgressHUD dismiss];
    
    NSDictionary *result = [soapEngine dictionaryValue];
    NSLog(@"%@", result);
    
    if (![[result objectForKey:@"TRegistroList"] isKindOfClass:[NSDictionary class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Falló la registración, verifique sus datos o su conexión a internet." delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString * estado = [[[result objectForKey:@"TRegistroList"] objectForKey:@"TRegistro"] objectForKey:@"estado"];
    
    if (estado && ![estado isEqualToString:@""]) {
        if ([estado isEqualToString: @"OK"]) {
            NSString *domicilio  = [[[result objectForKey:@"TRegistroList"] objectForKey:@"TRegistro"] objectForKey:@"domicilio"];
            FMDatabase *db = [self openDatabase];
            [db open];
            BOOL Success = [db executeUpdate:@"INSERT INTO user (nombre, email, cuenta, sucursal, domicilio, validada) VALUES (?, ?, ?, ?, ?, ?)" withArgumentsInArray:@[self.name.text, self.mail.text, self.account.text, self.accountPrefix.text, domicilio, [NSNumber numberWithInt:1]]];
            if (!Success) {
                NSLog(@"database update failed");
            }
            SWRevealViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier: @"main"];
            [self presentViewController:controller animated:FALSE completion:nil];
            return;
        } else if ([estado isEqualToString:@"00"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada, debes ingresar con una cuenta validada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else if ([estado isEqualToString: @"01"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sucursal y cuenta inexistente" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else if ([estado isEqualToString: @"02"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Registración rechazada" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
        
        SWRevealViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier: @"main"];
        [self presentViewController:controller animated:FALSE completion:nil];
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
@end
