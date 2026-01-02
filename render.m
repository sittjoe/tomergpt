#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <PDFKit/PDFKit.h>

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSURL *url = [NSURL fileURLWithPath:@"correcciones.pdf"];
    PDFDocument *document = [[PDFDocument alloc] initWithURL:url];
    if (!document) {
      fprintf(stderr, "No pude abrir el PDF\n");
      return 1;
    }
    CGFloat scale = 2.0;
    NSInteger pageCount = document.pageCount;
    for (NSInteger index = 0; index < pageCount; index++) {
      PDFPage *page = [document pageAtIndex:index];
      NSRect bounds = [page boundsForBox:kPDFDisplayBoxMediaBox];
      size_t width = bounds.size.width * scale;
      size_t height = bounds.size.height * scale;
      CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
      CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
      CGColorSpaceRelease(colorSpace);
      if (!context) {
        fprintf(stderr, "No pude crear contexto para pagina %ld\n", (long)index + 1);
        continue;
      }
      CGContextSetRGBFillColor(context, 1, 1, 1, 1);
      CGContextFillRect(context, CGRectMake(0, 0, width, height));
      CGContextScaleCTM(context, scale, scale);
      CGPDFPageRef pageRef = page.pageRef;
      CGContextDrawPDFPage(context, pageRef);
      CGImageRef image = CGBitmapContextCreateImage(context);
      CGContextRelease(context);
      if (!image) {
        fprintf(stderr, "No pude crear imagen para pagina %ld\n", (long)index + 1);
        continue;
      }
      NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithCGImage:image];
      CGImageRelease(image);
      NSData *pngData = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
      NSString *fileName = [NSString stringWithFormat:@"correcciones-page-%02ld.png", (long)index + 1];
      NSURL *outputURL = [NSURL fileURLWithPath:fileName];
      NSError *error = nil;
      BOOL ok = [pngData writeToURL:outputURL options:NSDataWritingAtomic error:&error];
      if (!ok) {
        fprintf(stderr, "Error guardando pagina %ld: %s\n", (long)index + 1, error.localizedDescription.UTF8String);
      } else {
        printf("Pagina %ld guardada en %s\n", (long)index + 1, outputURL.path.UTF8String);
      }
    }
  }
  return 0;
}
