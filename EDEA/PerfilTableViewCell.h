//
//  PerfilTableViewCell.h
//  EDEA
//
//  Created by Vincent Villalta on 9/14/15.
//  Copyright (c) 2015 Vincent Villalta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerfilTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;

@end
