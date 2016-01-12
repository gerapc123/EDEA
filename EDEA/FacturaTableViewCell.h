//
//  FacturaTableViewCell.h
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacturaTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *emision;
@property (weak, nonatomic) IBOutlet UILabel *importe;
@property (weak, nonatomic) IBOutlet UILabel *estado;

@end
