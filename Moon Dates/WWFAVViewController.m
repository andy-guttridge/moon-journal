//
//  WWFAVViewController.m
//  Moon Journal
//
//  Created by Andy Guttridge on 04/11/2017.
//  Copyright © 2017 Andy Guttridge. All rights reserved.
//

#import "WWFAVViewController.h"

@interface WWFAVViewController ()

@end

@implementation WWFAVViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.showsPlaybackControls = NO; //Ensure that playback controls are not shown. Called in this method to ensure this is dealt with before the view appears, because changing this property while the view is displayed destroys UI controls.
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    NSBundle *mainBundle = [NSBundle mainBundle]; //Get a reference to the app bundle.
    NSURL *videoURL = [mainBundle URLForResource:@"letitgo_vid" withExtension:@"m4v"]; //Get the URL for our video file.
    AVAsset *letItGoVid = [AVAsset assetWithURL:videoURL]; //Create an AVAsset containing our Let It Go video.
    AVPlayerItem *letItGoVidItem = [AVPlayerItem playerItemWithAsset:letItGoVid]; //Create an AVPlayerItem for our AVAsset.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(letItGoVidDidReachEnd) name: AVPlayerItemDidPlayToEndTimeNotification object: letItGoVidItem]; //Request a notification when the video finishes playing, and call the letItGoVidDidReachEnd method when this happens.
    AVPlayer *thePlayer = [AVPlayer playerWithPlayerItem:letItGoVidItem]; //Create an AVPlayer for our AVPlayerItem.
    self.player = thePlayer; //Assign our player to the player property of the view controller.
    [thePlayer play]; //Play our video.
}

-(void) letItGoVidDidReachEnd
{
    NSLog (@"Video Reached End");
    //Next, configure and show an alert message with an OK button.
    
    NSString *letItGoMessage = @"This sacred ritual is now complete";
    
    UIAlertController *letItGoAlertController = [UIAlertController alertControllerWithTitle:@"Ritual Complete" message:letItGoMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion: nil];
    }
    ];
    [letItGoAlertController addAction:OKAction];
    [self presentViewController:letItGoAlertController animated:YES completion:nil];
    
   //Return to the journal view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
