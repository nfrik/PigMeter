#import "GPUImageColorInvertFilter.h"

NSString *const kGPUImageInvertFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
    lowp vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
    
    gl_FragColor = vec4((1.0 - textureColor), 1.0);
 }
);                                                                    

@implementation GPUImageColorInvertFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageInvertFragmentShaderString]))
    {
		return nil;
    }
    
    return self;
}

@end

