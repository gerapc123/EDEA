//
//  NovedadesViewController.m
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import "NovedadesViewController.h"
#import "SWRevealViewController.h"
#import "NovedadesTableViewCell.h"
@interface NovedadesViewController (){
    NSArray *data;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NovedadesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(void)viewDidAppear:(BOOL)animated{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localArray = [documentsDirectory stringByAppendingPathComponent:@"novedades.dat"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile: localArray];
    if(array == nil)
    {
        [SVProgressHUD show];
        SOAPEngine *soap = [[SOAPEngine alloc] init];
        soap.licenseKey = @"kuSpmvqJEogw93H4ryqyhV9v7e9QZbN2qCI1dBCqd2kPUZhRTcezoeNyY9rw82+fCZHGJnM+UGgfDSmz3lkxdg==";
        soap.userAgent = @"SOAPEngine";
        soap.delegate = self;
        soap.authorizationMethod = SOAP_AUTH_BASIC;
        soap.username = @"app";
        soap.password = @"apptest";
        [soap setValue:@"10" forKey:@"cantidad"];
        [soap requestURL:kWs soapAction:getNoticiasWeb];
    }else{
        data = array;
    }

    
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML {
    NSDictionary *result = [soapEngine dictionaryValue];
    NSLog(@"%@", result);
    [SVProgressHUD dismiss];
    data = [[result objectForKey:@"TNoticiasWebList"] objectForKey:@"TNoticiasWeb"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localArray = [documentsDirectory stringByAppendingPathComponent:@"novedades.dat"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile: localArray];
    [array addObject:data];
    [array writeToFile:localArray atomically:YES];

    NSLog(@"%lu", (unsigned long)data.count);
    [self.tableView reloadData];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 300;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *temp = [data objectAtIndex:indexPath.row];
    NovedadesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.titleLabel.text = [temp objectForKey:@"titulo"];
    cell.dateLabel.text = [temp objectForKey:@"fecha"];
    cell.contentLabel.text = [temp objectForKey:@"texto_breve"];
    NSString *string = [temp objectForKey:@"imagen"];  // replace with encocded string
    NSData *imageData = [self dataFromBase64EncodedString:string];
    cell.image.image = [UIImage imageWithData:imageData];
    
    return cell;
}

-(NSData *)dataFromBase64EncodedString:(NSString *)string{
    if (string.length > 0) {
        
        //the iPhone has base 64 decoding built in but not obviously. The trick is to
        //create a data url that's base 64 encoded and ask an NSData to load it.
        NSString *data64URLString = [NSString stringWithFormat:@"data:;base64,%@", string];
        NSData *d = [NSData dataWithContentsOfURL:[NSURL URLWithString:data64URLString]];
        return d;
    }
    return nil;
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
