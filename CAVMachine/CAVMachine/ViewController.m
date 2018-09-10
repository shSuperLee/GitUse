//
//  ViewController.m
//  CAVMachine
//
//  Created by qiu on 2018/4/1.
//  Copyright © 2018年 ShSuperYang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//#define REQUESTURL  @"http://front.jukuhome.com/"
#define REQUESTURL  @"http://517ky.cn"


@interface ViewController ()<WKNavigationDelegate, WKUIDelegate>


@property (nonatomic, strong) WKWebView *cavWebV;

@property (nonatomic, strong) UIProgressView *progressView;//设置加载进度条


@end



@implementation ViewController



- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, WIDTH, 5);
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor greenColor];
        
    }
    return _progressView;
}



- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self loadWebView];
    
    [self setNavigationItem];
    
}


- (void)loadWebView {
    // 注释了没用有警告的代码
//    BOOL isiphoneX = KIsiPhoneX;
    _cavWebV = [[WKWebView alloc] init];
    _cavWebV.navigationDelegate = self;
    _cavWebV.UIDelegate = self;
//    _cavWebV.scrollView.scrollEnabled = NO;
    [_cavWebV addSubview:self.progressView];
    [_cavWebV bringSubviewToFront:self.progressView];
    [_cavWebV addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
    _cavWebV.frame = CGRectMake(0, 0, WIDTH, HEIGHT);

//    _cavWebV.TranslatesAutoresizingMaskIntoConstraints = NO;

    [_cavWebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:REQUESTURL]]];
    [self.view addSubview:_cavWebV];
}



#pragma mark - WKWebView UIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // 开始加载的时候，让进度条显示
    self.progressView.hidden = NO;
}


//kvo 监听进度
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _cavWebV) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.cavWebV.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.cavWebV.estimatedProgress
                              animated:animated];
        
        if (self.cavWebV.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.2f
                                  delay:0.2f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0.0f animated:NO];
                             }];
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


// 在dealloc方法里移除监听
- (void)dealloc {
    [self.cavWebV removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}




- (void)setNavigationItem {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title = @"ATB";
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSForegroundColorAttributeName:[UIColor whiteColor],
      NSFontAttributeName:[UIFont systemFontOfSize:18]};
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
