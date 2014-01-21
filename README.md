DMScanner
=========

iOS7 Machine readable codes convenience wrapper

Code from this post - http://weblog.invasivecode.com/post/63692508105/machine-readable-code-ios-7.
It felt a lot of work to add all this code everytime I needed scanning functionality, so this.

####Implementation####
- Import DMScanner.h and .m files in your project
- Allocate an instance of DMScanner and just call `[scanner startScanning]`
- The delegate method `scannerFoundMachineReadableCode:(NSString *)code ofType:(NSString *)type` fires everytime a code is found by the engine.
- Done. Conveniant. Fast!
