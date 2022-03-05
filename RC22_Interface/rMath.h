/* rMath */

#import <Cocoa/Cocoa.h>

// 0rigin
/*
#define VEKTORSIZE 0x400  // Anzahl Werte: 2048
#define STARTWERT   0x00  // Startwert: 0
#define ENDWERT     0x800 // Endwert: 4096
#define SCHRITTWEITE 0x20
#define DELTA  1.0/64 // Auffächerung. je kleiner desto enger
*/

// Variante 1
#define VEKTORSIZE 0x400  // Anzahl Werte: 1024
#define STARTWERT   0x00  // Startwert: 0
#define ENDWERT     0x400 // Endwert: 1024
#define SCHRITTWEITE 0x20
#define DELTA  1.0/48 // Auffächerung. je kleiner desto enger



#define FAKTOR 0x400

@interface rMath : NSObject
{
   
}

/*
Array mit DataArrays von je 2 Vektoren von 32 byte laenge mit 16-bit-Wert
*/

- (NSArray*)expoArrayMitStufe:(int) stufe;
- (NSArray*)expoDatenArrayMitStufe:(int)stufe;

- (NSString*)BinStringFromInt:(int)dieZahl;
- (NSArray*)BinArrayFrom:(int)dieZahl;
@end
