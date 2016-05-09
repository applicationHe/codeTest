//
//  ViewController.m
//  codeTest
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 何万牡. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goscan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
//    NSError * error = nil;
//    AVCaptureDevice * captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];//设备
//    
//    AVCaptureSession * session = [[AVCaptureSession alloc] init];//捕捉会话
//    [session setSessionPreset:AVCaptureSessionPresetHigh];//设置采集率
//    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];//输入流
//    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];//输出流
//    
//    //添加到捕捉会话
//    [session addInput:input];
//    [session addOutput:output];
//    
//    //扫码类型:需要先将输出流添加到捕捉会话后在进行设置
//    
//    //这里只设置了可扫描二维码,有条码需要,在数组中继续添加即可
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//    //输出流delegate,在主线程刷新UI
//    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    
//    AVCaptureVideoPreviewLayer * videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];//预览
//    videoPreviewLayer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:videoPreviewLayer atIndex:0];//添加预览
//    //还可以设置扫描的范围 output.rectofInterest //不设置默认全屏
//    
//    //开始扫描
//    [session startRunning];
    
    
}
-(void)goscan
{
    ScanViewController * scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}
#pragma mark - Delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString * content = @"";
    AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects.firstObject;
    content = metadataObject.stringValue;//获取二维码中的信息字符串
    //对此字符串进行处理(音效、网址分析、页面跳转等)
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:content delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
#pragma - 相册扫描二维码
-(void)choicePhoto
{
    //调用相册
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString * content = @"";
    //取出选中的图片
    UIImage * pickImage = info[UIImagePickerControllerOriginalImage];
    NSData * imageData = UIImagePNGRepresentation(pickImage);
    CIImage * ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector * detector = [CIDetector detectorOfType:CIFeatureTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    NSArray * feature = [detector featuresInImage:ciImage];
    
    for (CIQRCodeFeature * result in feature) {
        content = result.messageString;
    }
    //进行处理(音效、网址分析、页面跳转)
}
@end
