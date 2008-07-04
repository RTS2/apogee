/*
 *	@(#)coor.h	1.3	10/22/92
 */
typedef struct  {
	char	name[16];
        double  ra, dec, epoch, mag;
} OBJECT;

typedef struct	{
	double	ra, dec;
} COOR;
