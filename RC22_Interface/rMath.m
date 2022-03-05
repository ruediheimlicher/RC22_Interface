#import "rMath.h"




@implementation rMath

- (id) init
{
   if (self = [ super init])
       {
          return self;
       }
   return NULL;
}

- (NSArray*)expoDatenArrayMitStufe:(int)stufe
{
   
   NSMutableArray* datenarray = [[NSMutableArray alloc]initWithCapacity:0];
   
   float exparr[ENDWERT-STARTWERT];
    float wertarray[ENDWERT-STARTWERT];
   int intwertarray[ENDWERT-STARTWERT];

   float maxwert = 0;
   for (int i=0;i<VEKTORSIZE;i++)
   {
      if (stufe)
      {
         float delta = stufe *DELTA;
      float position = STARTWERT + i*SCHRITTWEITE;
      float exponent = delta*position/FAKTOR;
      float wert = exp(exponent);
      //float maxwert = wert;
      exparr[i]= wert;
      }
      else
      {
         exparr[i] = STARTWERT + (ENDWERT - STARTWERT)/VEKTORSIZE*i;
      }
     // fprintf(stderr,"%2.0f\t%2.8f\t%2.2f\n",position,exponent,wert);
     // float wert1 = pow(2.0,(stufe+0.2)*position/FAKTOR );
      //float wert2 = pow(2.0,(stufe+0.4)*position/FAKTOR );
      
      //fprintf(stderr,"%2.0f\t%2.2f\t%2.2f\t%2.2f\n",position,wert,wert1,wert2);
   }
   
   for (int i=0;i<VEKTORSIZE;i++)
   {
      float wert = (exparr[i]-exparr[0])*FAKTOR + STARTWERT;
      wertarray[i]=(exparr[i]-exparr[0])*FAKTOR + STARTWERT;
      if ((i % 64 ==0)|| (i==VEKTORSIZE-1))
      {
        // fprintf(stderr,"%2d\t%2.2f\n",i,wert);
      }
   }
   wertarray[VEKTORSIZE-1]=ENDWERT + STARTWERT;
  //fprintf(stderr,"\n");
   maxwert=wertarray[VEKTORSIZE-1];
   //fprintf(stderr,"maxwert: %2.2f\n",maxwert);
   for (int i=0;i<VEKTORSIZE;i++)
   {
      float wert = STARTWERT + (wertarray[i]-STARTWERT)/(maxwert - STARTWERT) * (ENDWERT - STARTWERT) ;
     intwertarray[i]= round(wert);
      int intwert = round(wert);
      if ((i % 64 ==0)|| (i==VEKTORSIZE-1))
      {
   //      fprintf(stderr,"%2d\t%2.2f\n",i,wert);
   //      fprintf(stderr,"%d\t",intwert);
      }
      
      
      //Daten hintereinander einfuegen
      [datenarray addObject:[NSNumber numberWithInt:(intwert & 0xFF)]]; // LO
      [datenarray addObject:[NSNumber numberWithInt:(intwert >>8)]]; // HI
  
   }
   //fprintf(stderr,"%d\t",intwertarray[VEKTORSIZE-1]);
   //fprintf(stderr,"Anzahl daten: %d\n",(int)[datenarray count]);

   
   return datenarray;
}
- (NSArray*)expoArrayMitStufe:(int)stufe
{
   NSMutableArray* arrayLO = [[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* arrayHI = [[NSMutableArray alloc]initWithCapacity:0];
   
   float exparr[ENDWERT-STARTWERT];
   float wertarray[ENDWERT-STARTWERT];
   int intwertarray[ENDWERT-STARTWERT];
   
   float maxwert = 0;
   for (int i=0;i<VEKTORSIZE;i++)
   {
      if (stufe)
      {
         float delta = stufe *1.0/16;
         float position = STARTWERT + i*SCHRITTWEITE;
         float exponent = delta*position/1000;
         float wert = exp(exponent);
         //float maxwert = wert;
         exparr[i]= wert;
      }
      else
      {
         exparr[i] = STARTWERT + (ENDWERT - STARTWERT)/VEKTORSIZE*i;
      }
      // fprintf(stderr,"%2.0f\t%2.8f\t%2.2f\n",position,exponent,wert);
      // float wert1 = pow(2.0,(stufe+0.2)*position/1000 );
      //float wert2 = pow(2.0,(stufe+0.4)*position/1000 );
      
      //fprintf(stderr,"%2.0f\t%2.2f\t%2.2f\t%2.2f\n",position,wert,wert1,wert2);
   }
   
   for (int i=0;i<VEKTORSIZE;i++)
   {
      float wert = (exparr[i]-exparr[0])*1000 + STARTWERT;
      wertarray[i]=(exparr[i]-exparr[0])*1000 + STARTWERT;
      //fprintf(stderr,"%2d\t%2.2f\n",i,wert);
   }
   //fprintf(stderr,"\n");
   maxwert=wertarray[VEKTORSIZE-1];
   //fprintf(stderr,"maxwert: %2.2f\n",maxwert);
   for (int i=0;i<VEKTORSIZE;i++)
   {
      float wert = STARTWERT + (wertarray[i]-STARTWERT)/(maxwert - STARTWERT) * (ENDWERT - STARTWERT) ;
      intwertarray[i]= round(wert);
      int intwert = round(wert);
      if (i % 16 ==0)
      {
         //fprintf(stderr,"%2d\t%2.2f",i,wert);
         //fprintf(stderr,"%d\t",intwert);
      }
      
      [arrayLO addObject:[NSNumber numberWithInt:(intwert & 0xFF)]];
      [arrayHI addObject:[NSNumber numberWithInt:(intwert >>8)]];
      
   }
   //fprintf(stderr,"%d\t",intwertarray[VEKTORSIZE-1]);
   //fprintf(stderr,"\n");
   
   
   return [NSArray arrayWithObjects:arrayLO,arrayHI, nil];
}

- (NSString*)BinStringFromInt:(int)dieZahl
{
	int pos=0;
	int rest=0;
	int zahl=dieZahl;
	
	NSString* BinString=[NSString string];
	while (zahl)
	{
		rest=zahl%2;
		if (rest)
		{
			BinString=[@"1" stringByAppendingString:BinString ];
		}
		else
		{
			BinString=[@"0"  stringByAppendingString:BinString];
		}
		zahl/=2;
		if (pos==3)
		{
         BinString=[@" " stringByAppendingString:BinString];
		}
		pos++;
		//NSLog(@"BinString: %@",BinString);
	}
	int i;
	for (i=pos;i<8;i++) //String mit fuehrenden Nullen ergänzen
	{
      //NSLog(@"lpos: %d %@",pos,BinString);
      if (i==4)
		{
         BinString=[@" " stringByAppendingString:BinString];
        // NSLog(@"leerstelle: %@",BinString);
		}

		BinString=[@"0"  stringByAppendingString:BinString];
	}
	return BinString;
}

- (NSArray*)BinArrayFrom:(int)dieZahl
{
	int rest=0;
	int zahl=dieZahl;
	//NSLog(@"BinArray start: Zahl: %d",zahl);
	NSMutableArray* BinArray=[[NSMutableArray alloc]initWithCapacity:8];
	int anzStellen=0;
	while (zahl)
	{
		
		rest=zahl%2;
		if (rest)
		{
			//NSLog(@"BinArray pos: %d Zahl: %d",anzStellen,1);
			[BinArray addObject:@"1"];
		}
		else
		{
			//NSLog(@"BinArray pos: %d Zahl: %d",anzStellen,0);
         
			[BinArray addObject:@"0"];
		}
		zahl/=2;
		anzStellen++;
	}
	//NSLog(@"BinArray: %@",[BinArray description]);
	int i;
	for (i=anzStellen;i<8;i++)
	{
      [BinArray addObject:@"0"];
	}
	return BinArray;
}


@end
