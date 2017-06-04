/**
 * titanium-deep-learning
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "TiDeeplearningModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiDeeplearningModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"16ae195c-9c8b-4dbf-aaf7-6af9951bcd6f";
}

- (NSString *)moduleId
{
	return @"ti.deeplearning";
}

#pragma mark Lifecycle

- (void)startup
{
	[super startup];
	NSLog(@"[DEBUG] %@ loaded",self);
}

#pragma Public APIs

- (void)initializeNetwork:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *filename = [TiUtils stringValue:@"name" properties:args];
    NSString* networkPath = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension]];
    
    if (networkPath == nil) {
        NSLog(@"[ERROR] Couldn't find the neural network parameters file \"%s.ntwk\", did you add it as a resource to your application?\n", filename.UTF8String);
        return;
    }
    
    network = jpcnn_create_network([networkPath UTF8String]);

    if (network == NULL) {
        NSLog(@"[ERROR] Network could not be created, ensure the file exists and the file-structure matches the requirements.");
    }
}

- (void)classifyImage:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *image = [args objectForKey:@"image"];
    KrollCallback *callback = [args objectForKey:@"callback"];

    float minimumThreshold = [TiUtils floatValue:[args objectForKey:@"minimumThreshold"] def:0.01];
    float decay = [TiUtils floatValue:[args objectForKey:@"decay"] def:0.75];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[image stringByDeletingPathExtension] ofType:[image pathExtension]];

    void* inputImage = jpcnn_create_image_buffer_from_file([imagePath UTF8String]);
    
    if (inputImage == NULL) {
        NSLog(@"[ERROR] Could not create image buffer. Ensure the image path is correct.");
        return;
    }
    
    float* predictions;
    int predictionsLength;
    char** predictionsLabels;
    int predictionsLabelsLength;
    jpcnn_classify_image(network, inputImage, 0, 0, &predictions, &predictionsLength, &predictionsLabels, &predictionsLabelsLength);
    
    jpcnn_destroy_image_buffer(inputImage);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:predictionsLength];
    
    for (int index = 0; index < predictionsLength; index += 1) {
        const float predictionValue = predictions[index];
        const float decayedPredictionValue = (predictionValue * decay);
        char* label = predictionsLabels[index % predictionsLabelsLength];

        if (decayedPredictionValue > minimumThreshold) {
            [result addObject:@{@"label": [NSString stringWithFormat:@"%s", label], @"value": NUMFLOAT(predictionValue)}];
        }
    }
    
    jpcnn_destroy_network(network);
    
    [callback call:@[@{@"result": result}] thisObject:self];
}
@end
