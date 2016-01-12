//
//  ReclamosTableViewCell.h
//  
//
//  Created by Vincent Villalta on 11/16/15.
//
//

#import <UIKit/UIKit.h>

@interface ReclamosTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tituloReclamo;
@property (weak, nonatomic) IBOutlet UILabel *fechaReclamo;
@property (weak, nonatomic) IBOutlet UILabel *numeroReclamo;
@property (weak, nonatomic) IBOutlet UIImageView *estado;

@end
