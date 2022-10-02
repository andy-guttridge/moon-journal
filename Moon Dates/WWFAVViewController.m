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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Ensure playback controls not shown.
    self.showsPlaybackControls = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    //Get references to app bundle and video file URL
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *videoURL = [mainBundle URLForResource:@"letitgo_vid" withExtension:@"m4v"];
    
    //Create AVAsset containing video and AVPlayerItem to play it.
    AVAsset *letItGoVid = [AVAsset assetWithURL:videoURL];
    AVPlayerItem *letItGoVidItem = [AVPlayerItem playerItemWithAsset:letItGoVid];
    
    //Request notification when the video finishes playing, and call the letItGoVidDidReachEnd method when this happens.
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(letItGoVidDidReachEnd) name: AVPlayerItemDidPlayToEndTimeNotification object: letItGoVidItem];
    
    //Create AVPlayer for our AVPlayerItem, assign to view controller and play.
    AVPlayer *thePlayer = [AVPlayer playerWithPlayerItem:letItGoVidItem];
    self.player = thePlayer;
    [thePlayer play];
}

-(void) letItGoVidDidReachEnd {
    NSLog (@"Video Reached End");
    
    //Configure and show an alert message with an OK button. Returns to journal view when the alert is dismissed.
    NSString *letItGoMessage = @"This sacred ritual is now complete";
    
    UIAlertController *letItGoAlertController = [UIAlertController alertControllerWithTitle:@"Ritual Complete" message:letItGoMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion: nil];
    }];
    [letItGoAlertController addAction:OKAction];
    [self presentViewController:letItGoAlertController animated:YES completion:nil];
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
