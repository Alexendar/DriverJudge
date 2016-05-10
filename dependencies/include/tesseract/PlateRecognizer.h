//
//  PlateRecognizer.h
//  DriverJudge
//
//  Created by Aleksander on 05/04/16.
//  Copyright © 2016 Aleksander. All rights reserved.
//

#import <TesseractOCR/TesseractOCR.h>
#import "LicensePlate.h"
@interface PlateRecognizer : G8Tesseract
-(LicensePlate*) recognize: (UIImage*) binarizedImage;
@end
