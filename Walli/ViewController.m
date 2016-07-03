//
//  ViewController.m
//  Walli
//
//  Created by Ryang on 12/12/15.
//  Copyright © 2015 Ryang. All rights reserved.
//

#import "ViewController.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imgViewGif;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    FLAnimatedImage *logoGif = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"w" ofType:@"gif"]]];
    logoGif.loopCount = 1;
    self.imgViewGif.animatedImage = logoGif;
    [self.imgViewGif startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"show" sender:nil];
    });


    //[self.view addSubview:self.imgViewGif];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
