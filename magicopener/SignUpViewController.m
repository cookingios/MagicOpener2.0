//
//  SignUpViewController.m
//  MagicOpener
//
//  Created by wenlin on 13-7-28.
//  Copyright (c) 2013年 isaced. All rights reserved.
//

#import "SignUpViewController.h"


@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet BZGFormField *emailTextField;
@property (weak, nonatomic) IBOutlet BZGFormField *passwordTextField;

@property (unsafe_unretained,nonatomic) BOOL isEditing;


- (IBAction)validateSignUpInfo:(id)sender;

@end

@implementation SignUpViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self configSignUpTextField];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"SignUp"];
    
    self.isEditing = NO;
    //self.backgroundScrollView.contentSize = CGSizeMake(320, 520);
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"SignUp"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - config textfield
- (void)configSignUpTextField{
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
	// Do any additional setup after loading the view.
    self.emailTextField.textField.placeholder = @"注册邮箱";
    self.emailTextField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailTextField.textField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.textField.tag = 180 ;
    __weak SignUpViewController *weakSelf = self;
    [self.emailTextField setTextValidationBlock:^BOOL(BZGFormField *field,NSString *text) {
        NSString *trimText = [MOHelper trimString:text];
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:trimText]) {
            weakSelf.emailTextField.alertView.title = @"邮箱地址格式不正常";
            return NO;
        } else {
            return YES;
        }
    }];
    
    self.passwordTextField.textField.placeholder = @"设置密码";
    self.passwordTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.textField.secureTextEntry = YES;
    self.passwordTextField.textField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.textField.tag = 240;
    [self.passwordTextField setTextValidationBlock:^BOOL(BZGFormField *field,NSString *text) {
        NSString *trimText = [MOHelper trimString:text];
        if (trimText.length < 6) {
            weakSelf.passwordTextField.alertView.title = @"密码不能少于6位";
            return NO;
        } else {
            return YES;
        }
    }];
}


#pragma mark - textfield delegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 180 && textField.text.length>0) {
        NSString *trimText = [MOHelper trimString:textField.text];
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:trimText]) {
            [MOHelper showErrorMessage:@"邮箱地址格式不正常" inViewController:self];
        }
    }else if(textField.tag == 240 && textField.text.length>0){
        NSString *trimText = [MOHelper trimString:textField.text];
        if (trimText.length < 6) {
            [MOHelper showErrorMessage:@"密码不能少于6位" inViewController:self];
        }
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@" "]){
    	return NO;
    }
    else {
    	return YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 180:
            [self.passwordTextField.textField becomeFirstResponder];
            break;
        case 240:
            [self validateSignUpInfo:textField];
        default:
            break;
    }
    
    return YES;
}


#pragma mark - validate signup info
- (IBAction)validateSignUpInfo:(id)sender {
    
    [TSMessage dismissActiveNotification];
    
    [self.view endEditing:YES];
    NSString *error = @"";
    
    if (self.emailTextField.formFieldState != BZGFormFieldStateValid) {
        error = @"请检查注册邮箱";
        [self.emailTextField.textField becomeFirstResponder];
        return [MOHelper showErrorMessage:error inViewController:self];
    }
    if (self.passwordTextField.formFieldState != BZGFormFieldStateValid) {
        error = @"请检查密码设置";
        [self.passwordTextField.textField becomeFirstResponder];
        return [MOHelper showErrorMessage:error inViewController:self];
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self performBlock:^{
        if (!hud.hidden) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"网络连接出现问题";
            [hud hide:YES afterDelay:2];
        }
    } afterDelay:15];
    
    PFUser *user = [PFUser user];
    user.username = self.emailTextField.textField.text;
    user.password = self.passwordTextField.textField.text;
    user.email = self.emailTextField.textField.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        if (!error) {
            //Setup the installation.
            PFInstallation *installation = [PFInstallation currentInstallation];
            [installation setObject:user forKey:@"owner"];
            [installation saveInBackground];
            
            [PFCloud callFunctionInBackground:@"addFreeChance"
                               withParameters:@{}
                                        block:^(NSNumber *ratings, NSError *error) {
                                            if (!error) {
                                                // ratings is 4.5
                                                NSLog(@"注册成功,增加生命");
                                            }
                                        }];
        } else {
            NSString *errorString = @"";
            if ([error code] == kPFErrorUsernameTaken) {
                errorString = @"用户名已被注册,请更换";
            } else if ([error code] == kPFErrorConnectionFailed) {
                errorString = @"网络连接不上了";
            } else if (error) {
                NSLog(@"Error: %@", [error userInfo][@"error"]);
            }
            [MOHelper showErrorMessage:errorString inViewController:self];
        }
    }];
    
    
}



@end

