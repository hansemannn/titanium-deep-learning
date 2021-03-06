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

#include <sys/time.h>

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
        NSLog(@"[ERROR] Couldn't find the neural network parameters file \"%s\", did you add it as a resource to your application?\n", filename.UTF8String);
        return;
    }
    
    network = jpcnn_create_network([networkPath UTF8String]);

    if (network == NULL) {
        NSLog(@"[ERROR] Network could not be created, ensure the file exists and the file-structure matches the .ntwk requirements.");
    }
}

- (void)classifyImage:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    id image = [args objectForKey:@"image"];
    
    // Process image
    if ([image isKindOfClass:[NSString class]]) {
        image = [TiUtils stringValue:image];
    } else if ([image isKindOfClass:[TiBlob class]]) {
        image = [(TiBlob *)image path];
    }
    
    KrollCallback *callback = [args objectForKey:@"callback"];

    // Define default values
    float minimumThreshold = [TiUtils floatValue:[args objectForKey:@"minimumThreshold"] def:0.01];
    float decay = [TiUtils floatValue:[args objectForKey:@"decay"] def:0.75];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[image stringByDeletingPathExtension] ofType:[image pathExtension]];
    
    // Put image in image-buffer
    void *inputImage = jpcnn_create_image_buffer_from_file([imagePath UTF8String]);
    
    if (inputImage == NULL) {
        [callback call:@[@{@"success": NUMBOOL(NO), @"error": @"Could not create image buffer. Ensure the image path is correct."}] thisObject:self];
        return;
    }
    
    // Prepare predictions
    float *predictions;
    int predictionsLength;
    char **predictionsLabels;
    int predictionsLabelsLength;
    
    // Measure time
    struct timeval start;
    struct timeval end;
    
    gettimeofday(&start, NULL);
    jpcnn_classify_image(network, inputImage, 0, 0, &predictions, &predictionsLength, &predictionsLabels, &predictionsLabelsLength);
    gettimeofday(&end, NULL);
    
    const long seconds  = end.tv_sec  - start.tv_sec;
    const long useconds = end.tv_usec - start.tv_usec;
    const float duration = ((seconds) * 1000 + useconds / 1000.0) + 0.5;

    jpcnn_destroy_image_buffer(inputImage);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:predictionsLength];
    
    // Loop through results
    for (int index = 0; index < predictionsLength; index += 1) {
        const float predictionValue = predictions[index];
        const float decayedPredictionValue = (predictionValue * decay);
        char *label = predictionsLabels[index % predictionsLabelsLength];

        if (decayedPredictionValue > minimumThreshold) {
            [result addObject:@{@"label": [NSString stringWithFormat:@"%s", label], @"value": NUMFLOAT(predictionValue)}];
        }
    }
    
    jpcnn_destroy_network(network);
    
    [callback call:@[@{@"duration": NUMFLOAT(duration), @"success": NUMBOOL(YES), @"result": result}] thisObject:self];
}
@end
