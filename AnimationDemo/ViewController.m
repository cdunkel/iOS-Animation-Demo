//
//  ViewController.m
//  AnimationDemo
//
//  Created by Chris Dunkel on 5/16/17.
//  Copyright © 2017 Career Soft, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *greenView;

@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;

@property (nonatomic) NSInteger step;

- (void)presentViews;
- (void)presentViewsAnimatedSimple;
- (void)presentViewsAnimatedCompletion;
- (void)presentAvLayer;
- (void)addPerspective;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.step = 0;  // This is a hacked flow control var, to control which animations occur each time the user taps the view

    self.blueView   = [[UIView alloc] initWithFrame:CGRectMake(-100, 50, 100, 100)];
    self.redView    = [[UIView alloc] initWithFrame:CGRectMake(-100, 200, 100, 100)];
    self.greenView  = [[UIView alloc] initWithFrame:CGRectMake(-100, 350, 100, 100)];

    [self blueView].backgroundColor     = [UIColor blueColor];
    [self redView].backgroundColor      = [UIColor redColor];
    [self greenView].backgroundColor    = [UIColor greenColor];

    // Important so we don't get constraints we don't want.  Otherwise iOS will create constraints at runtime.
    [self blueView].translatesAutoresizingMaskIntoConstraints   = NO;
    [self redView].translatesAutoresizingMaskIntoConstraints    = NO;
    [self greenView].translatesAutoresizingMaskIntoConstraints  = NO;

    self.avPlayerLayer = [[AVPlayerLayer alloc] init];
    NSURL *videoUrl = [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
    [self avPlayerLayer].player = [AVPlayer playerWithURL:videoUrl];
    [[self avPlayerLayer] player].muted = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self view] addSubview:[self blueView]];
    [[self view] addSubview:[self redView]];
    [[self view] addSubview:[self greenView]];

    [self avPlayerLayer].frame = [[self redView] frame];
    [[[self view] layer] addSublayer:[self avPlayerLayer]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    /**
     Uncomment only one block of function calls at a time to see the different animation types.
     **/
    
    // Uncomment to see the non-animated version
//    [self presentViews];

    // Uncomment to see the simple animation version
//    [self presentViewsAnimatedSimple];

    // Uncomment for the more complex animations and animation chaining
    [self presentViewsAnimatedCompletion];
    [self presentAvLayer];
    [self addPerspective];
    self.step++;
}


- (void)presentViews {
    [self blueView].frame   = CGRectMake(50, 50, 100, 100);
    [self redView].frame    = CGRectMake(50, 200, 100, 100);
    [self greenView].frame  = CGRectMake(50, 350, 100, 100);
}

- (void)presentViewsAnimatedSimple {
    [UIView animateWithDuration:0.5
                     animations:^() {
                         [self blueView].frame   = CGRectMake(50, 50, 100, 100);
                     }];
    [UIView animateWithDuration:0.5
                     animations:^() {
                         [self redView].frame    = CGRectMake(50, 200, 100, 100);
                     }];
    [UIView animateWithDuration:0.5
                     animations:^() {
                         [self greenView].frame  = CGRectMake(50, 350, 100, 100);
                     }];
}

- (void)presentViewsAnimatedCompletion {
    if ([self step] == 0) {
        CGFloat newWidth = CGRectGetWidth([[self view] frame]) - 100;

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             [self blueView].frame = CGRectMake(50, 50, newWidth, 100);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:1.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^() {
                                                  [self blueView].frame = CGRectMake(0, 0, CGRectGetWidth([[self view] frame]), 150);
                                              }
                                              completion:^(BOOL done) {

                                              }];
                         }];
        [UIView animateWithDuration:0.5
                              delay:0.3
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             [self redView].frame = CGRectMake(50, 200, newWidth, 100);
                         }
                         completion:^(BOOL finished) {

                         }];
        [UIView animateWithDuration:0.5
                              delay:0.6
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             [self greenView].frame = CGRectMake(50, 350, newWidth, 100);
                         }
                         completion:^(BOOL finished) {

                         }];
    }
}

- (void)presentAvLayer {
    if ([self step] == 1) {
        CGFloat newWidth = CGRectGetWidth([[self view] frame]) - 100;
        // Start playing video
        [[[self avPlayerLayer] player] play];
        // Animating the raw layer
        [CATransaction begin];
        [CATransaction setValue:@(1.0) forKey:kCATransactionAnimationDuration];
        [self avPlayerLayer].frame = CGRectMake(50, 500, newWidth, 100);
        [self avPlayerLayer].transform = CATransform3DMakeRotation((float)(M_PI), 0.0, 0.0, 1.0);
        [CATransaction commit];
    }
}

- (void)addPerspective {
    if ([self step] == 2) {
        CATransform3D perspective = CATransform3DIdentity;
        CGFloat eyePosition = 30.0;
        perspective.m34 = (CGFloat) (-1.0 / eyePosition);
        [[self view] layer].sublayerTransform = perspective;

        [UIView animateWithDuration:1.5
                         animations:^() {
                             // How to animate layer operations along with UIView attributes
                             CABasicAnimation* layerAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
                             layerAnimation.duration = 1.5;
                             layerAnimation.beginTime = 0; //CACurrentMediaTime() + 1;
                             layerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                             layerAnimation.fromValue = @(0.0);
                             layerAnimation.toValue = @(5.0);
                             [[[self greenView] layer] addAnimation:layerAnimation forKey:@"layerAnimation"];
                             [[self greenView] layer].zPosition = 5.0;

                             [[self blueView] layer].zPosition = 1.0;
                             [[self redView] layer].zPosition = 2.5;
                         }];

        [CATransaction begin];
        [CATransaction setValue:@(1.0)
                         forKey:kCATransactionAnimationDuration];
        [self avPlayerLayer].zPosition = 2.0;
        [CATransaction commit];
    }
}

@end
