//
//  ScanViewController.m
//  codeTest
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 何万牡. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height

@interface ScanViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    UIImagePickerController * imagePicker;
}
@property (nonatomic,strong) AVCaptureDevice * device;

@property (nonatomic,strong) AVCaptureDeviceInput * input;

@property (nonatomic,strong)AVCaptureMetadataOutput * output;

@property (nonatomic,strong)AVCaptureSession * session;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;

@property (nonatomic,assign)BOOL isScanSuccess;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    UIBarButtonItem * navRightButton = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(goPhoto)];
    self.navigationItem.rightBarButtonItem = navRightButton;
    self.navigationItem.title = @"二维码/条码";
    //添加扫描框
    [self initBgView];
    //开始扫描
    [self startScan];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_session) {
        [self.session startRunning];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}
-(void)goPhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString * content = @"";
    UIImage * image = info[UIImagePickerControllerOriginalImage];
    NSData * imageData = UIImagePNGRepresentation(image);
    CIImage * ciImage = [[CIImage alloc] initWithData:imageData];
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    NSArray * feature = [detector featuresInImage:ciImage];
    for (CIQRCodeFeature * result in feature) {
        if (result.messageString) {
            content = result.messageString;
            break;
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:content delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }];
    
}
//可重写view的drawrect方法直接画，这里因为懒，所以直接从古早项目中粘贴过来。
- (void)initBgView{
    
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:bgView];
    //基准线
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(mainWidth/16, mainHeight/2-0.5, mainWidth/8*7, 1)];
    line.backgroundColor = [UIColor redColor];
    [bgView addSubview:line];
    //上部
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight/6)];
    upView.alpha = 0.4;
    upView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:upView];
    //说明
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(mainWidth/20, mainHeight/24, mainWidth/10*9, 50);
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=@"将二维码置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [upView addSubview:labIntroudction];
    //左侧
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, mainHeight/6, mainWidth/16, mainHeight/12*7)];
    leftView.alpha = 0.4;
    leftView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:leftView];
    //右侧
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(mainWidth/16*15, mainHeight/6, mainWidth/16, mainHeight/12*7)];
    rightView.alpha = 0.4;
    rightView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:rightView];
    //底部
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, mainHeight/4*3, mainWidth, mainHeight/4)];
    downView.alpha = 0.4;
    downView.backgroundColor = [UIColor blackColor];
    [bgView addSubview:downView];
}

-(void)startScan
{
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    [self.session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString * content = @"";
    AVMetadataMachineReadableCodeObject * metdataObject = metadataObjects.firstObject;
    content = metdataObject.stringValue;
    if (content) {
        [self.session stopRunning];
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:content delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - Getter
-(AVCaptureDevice *)device
{
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

-(AVCaptureDeviceInput *)input
{
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

-(AVCaptureMetadataOutput *)output
{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
    }
    return _output;
}
-(AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}
-(AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}
@end
