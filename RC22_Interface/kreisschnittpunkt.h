//
//  kreisschnittpunkte.h
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 15.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

#ifndef kreisschnittpunkte_h
#define kreisschnittpunkte_h

extern void kreispunkte(void);

extern int circle_circle_intersection(double x0, double y0, double r0,
                               double x1, double y1, double r1,
                               double *xi, double *yi,
                               double *xi_prime, double *yi_prime);


#endif /* kreisschnittpunkte_h */
