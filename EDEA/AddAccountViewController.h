//
//  AddAccountViewController.h
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "Constants.h"
#import <SOAPEngine64/SOAPEngine.h>
#import "AFSQLManager.h"
@interface AddAccountViewController : UIViewController <NSURLConnectionDataDelegate, NSXMLParserDelegate, SOAPEngineDelegate>{
    
}

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *mail;
@property (weak, nonatomic) IBOutlet UITextField *accountPrefix;
@property (weak, nonatomic) IBOutlet UITextField *account;



@end
