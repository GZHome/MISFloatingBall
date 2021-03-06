//
//  DemoBallTitleTableViewController.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/29.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "DemoBallTitleTableViewController.h"

#import "MISFloatingBall.h"

@interface DemoBallTitleTableViewController ()

@property (nonatomic, strong) NSMutableArray *imageDatas;

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) MISFloatingBall *floatingBall;

@end

@implementation DemoBallTitleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
//    self.floatingBall = [MISFloatingBall alloc] ini
    self.floatingBall.backgroundColor = [UIColor lightGrayColor];
    
    __weak typeof(self) weakSelf = self;
    [self.floatingBall setClickHander:^{
        [weakSelf.floatingBall disVisible];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test:) name:UIWindowDidBecomeVisibleNotification object:nil];
}

- (void)test:(NSNotification*)noti {
    NSLog(@"111");
    UIWindow *window = noti.object;
    NSArray *windows = [UIApplication sharedApplication].windows;
    NSLog(@"current window count %ld", windows.count);
    NSLog(@"Window has become keyWindow: %@, window level: %f, index of windows: %ld", window, window.windowLevel, [windows indexOfObject:window]);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.floatingBall visible];
}

- (NSMutableArray *)imageDatas {
    if (!_imageDatas) {
        _imageDatas = [NSMutableArray array];
        for (NSInteger index = 0; index < 1000; index++) {
            [_imageDatas addObject:@"apple"];
        }
    }
    return _imageDatas;
}

#pragma mark - Tick

- (void)tick:(CADisplayLink *)link {
    if (self.lastTime == 0) {
        self.lastTime = link.timestamp;
        return;
    }
    
    self.count++;
    
    NSTimeInterval delta = link.timestamp - self.lastTime;
    if (delta < 1) return;
    
    self.lastTime = link.timestamp;
    float fps = self.count / delta;
    self.count = 0;
    
    CGFloat progress = fps / 60.0;
    
    [self.floatingBall setContent:[NSString stringWithFormat:@"%d FPS", (int)round(fps)] contentType:MISFloatingBallContentTypeText];
    self.floatingBall.textTypeTextColor = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageDatas.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    if (indexPath.item != 0) {
        cell.imageView.image = [UIImage imageNamed:self.imageDatas[indexPath.item]];
        cell.textLabel.text = @"我是一张图片，滚动看FPS";
    }
    else {
        UITextView *textview = [[UITextView alloc] initWithFrame:cell.bounds];
        [textview becomeFirstResponder];
        [cell addSubview:textview];
//        [self.floatingBall visible];
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:self.view.bounds];
        
        window.backgroundColor = [UIColor yellowColor];
        
        UIViewController *vc = [[UIViewController alloc] init];
        window.rootViewController = vc;
        [window makeKeyAndVisible];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [NSThread sleepForTimeInterval:0.1f];
}
@end
