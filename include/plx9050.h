
/* 
 *	Register definitions for PLX9050 chip (also PLX9052)
 * 	Copyright 2001 - Dave Mills, The Random Factory
 */

#define PLX_LASxRR(x)	(0x00 + x*4)	/* Local Address space x range register */
#define PLX_LAS0RR	0x00		/* Local Address space 0 range register */
#define PLX_LAS1RR	0x04		/* Local Address space 1 range register */
#define PLX_LAS2RR	0x08		/* Local Address space 2 range register */
#define PLX_LAS3RR	0x0c		/* Local Address space 3 range register */

#define PLX_EROMRR	0x10		/* Expansion ROM range register */
#define PLX_EROMBA	0x24		/* Expansion ROM local base address (Remap) register*/
#define PLX_EROMBRD	0x38		/* Expansion ROM Bus Region Descriptor register*/

#define PLX_LASxBA(x)	(0x14 + x*4)	/* Local Address space x Local Base Address (Remap) register  */
#define PLX_LAS0BA	0x14		/* Local Address space 0 Local Base Address (Remap) register */
#define PLX_LAS1BA	0x18		/* Local Address space 1 Local Base Address (Remap) register */
#define PLX_LAS2BA	0x1c		/* Local Address space 2 Local Base Address (Remap) register */
#define PLX_LAS3BA	0x20		/* Local Address space 3 Local Base Address (Remap) register */

#define PLX_LASxBRD(x)	(0x28 + x*4)	/* Local Address space x Bus Region Descriptor register */
#define PLX_LAS0BRD	0x28		/* Local Address space 0 Bus Region Descriptor register */
#define PLX_LAS1BRD	0x2c		/* Local Address space 1 Bus Region Descriptor register */
#define PLX_LAS2BRD	0x30		/* Local Address space 2 Bus Region Descriptor register */
#define PLX_LAS3BRD	0x34		/* Local Address space 3 Bus Region Descriptor register */

#define PLX_CSxBASE(x)	(0x3c + x*4)	/* Chip Select x Base Address Register */
#define PLX_CS0BASE	0x3c		/* Chip Select 0 Base Address Register */
#define PLX_CS1BASE	0x40		/* Chip Select 1 Base Address Register */
#define PLX_CS2BASE	0x44		/* Chip Select 2 Base Address Register */
#define PLX_CS3BASE	0x48		/* Chip Select 3 Base Address Register */

#define PLX_INITCSR	0x4c		/* Interrupt Control/Status register */
#define PLX_CNTRL	0x50		/* User I/O, PCI Target Response, Serial EEPROM, Init */

#define PLX_LASRR_MEM_32BIT	0x00000000
#define PLX_LASRR_MEM_1M	0x00000002
#define PLX_LASRR_MEM_64BIT	0x00000004
#define PLX_LASRR_PREFETCH	0x00000008

#define PLX_LASBA_ENABLE	0x00000001
#define PLX_LAS_MEM_SPACE	0x0ffffff0
#define PLX_LAS_IO_SPACE	0x0ffffffc

#define PLX_LASBRD_BURST	0x00000001
#define PLX_LASBRD_READY_INPUT	0x00000002
#define PLX_LASBRD_BTERM_INPUT	0x00000004
#define PLX_LASBRD_NO_PREFETCH	0x00000000
#define PLX_LASBRD_PREFETCH4	0x00000028
#define PLX_LASBRD_PREFETCH8	0x00000030
#define PLX_LASBRD_PREFETCH16	0x00000038
#define PLX_LASBRD_NRAD_WAIT(x)	(x << 6) &  0x000007c0
#define PLX_LASBRD_NRDD_WAIT(x)	(x << 11) & 0x00001800
#define PLX_LASBRD_NXDA_WAIT(x)	(x << 13) & 0x00006000
#define PLX_LASBRD_NWAD_WAIT(x)	(x << 15) & 0x000f8000
#define PLX_LASBRD_NWDD_WAIT(x)	(x << 20) & 0x00300000

#define PLX_LASBRD_BUS_8BIT	0x00000000
#define PLX_LASBRD_BUS_16BIT	0x00400000
#define PLX_LASBRD_BUS_32BIT	0x00800000
#define PLX_LASBRD_BIG_ENDIAN	0x01000000
#define PLX_LASBRD_LIT_ENDIAN	0x00000000
#define PLX_LASBRD_BE_LANEHIGH	0x02000000
#define PLX_LASBRD_BE_LANELOW	0x00000000
#define PLX_LASBRD_RD_STROBE(x) 	(x << 26) & 0x0c000000
#define PLX_LASBRD_WRT_STROBE(x)	(x << 28) & 0x30000000
#define PLX_LASBRD_WRT_CHOLD(x)		(x << 30) & 0xc0000000

#define PLX_CHIP_SELECT_ENABLE	0x00000001

#define PLX_INT1_LOCAL_ENABLE	0x00000001
#define PLX_INT1_POL_HIGH	0x00000002
#define PLX_INT1_STATUS		0x00000004
#define PLX_INT2_LOCAL_ENABLE	0x00000008
#define PLX_INT2_POL_HIGH	0x00000010
#define PLX_INT2_STATUS		0x00000020
#define PLX_INT_PCI_ENABLE	0x00000040
#define PLX_INT_SW_ENABLE	0x00000080
#define PLX_INT1_LOCAL_EDGE	0x00000100
#define PLX_INT2_LOCAL_EDGE	0x00000200
#define PLX_INT1_CLR_LOCAL_EDGE	0x00000400
#define PLX_INT2_CLR_LOCAL_EDGE	0x00000800
#define PLX_ISA_MODE_ENABLED	0x00001000


#define PLX_CNTRL_PIN_WAIT0	0x00000001
#define PLX_CNTRL_USER0_OUT	0x00000002
#define PLX_CNTRL_USER0_SET	0x00000004
#define PLX_CNTRL_PIN_LLOCK	0x00000008
#define PLX_CNTRL_USER1_OUT	0x00000010
#define PLX_CNTRL_USER1_SET	0x00000020
#define PLX_CNTRL_PIN_CS2	0x00000040
#define PLX_CNTRL_USER2_OUT	0x00000080
#define PLX_CNTRL_USER2_SET	0x00000100
#define PLX_CNTRL_PIN_CS3	0x00000200
#define PLX_CNTRL_USER3_OUT	0x00000400
#define PLX_CNTRL_USER3_SET	0x00000800
#define PLX_CNTRL_BAR0_ISMEM	0x00001000
#define PLX_CNTRL_BAR1_ISIO	0x00002000
#define PLX_CNTRL_PREFETCH	0x00004000
#define PLX_CNTRL_RD_WRT_FLUSH	0x00008000
#define PLX_CNTRL_RD_NO_FLUSH	0x00010000
#define PLX_CNTRL_RD_WRT_RETRY	0x00020000
#define PLX_CNTRL_WRT_NOWAIT	0x00040000
#define PLX_CNTRL_RETRY_CLK(x)  (x << 19) & 0x00780000
#define PLX_CNTRL_DSLV_LOCK	0x00800000
#define PLX_CNTRL_EEPROM_CLOCK	0x01000000
#define PLX_CNTRL_EEPROM_SELECT	0x02000000
#define PLX_CNTRL_EEPROM_WRITE	0x04000000
#define PLX_CNTRL_EEPROM_READ	0x08000000
#define PLX_CNTRL_EEPROM_VALID	0x10000000
#define PLX_CNTRL_EEPROM_RELOAD	0x20000000
#define PLX_CNTRL_RESET		0x40000000
#define PLX_CNTRL_EEPROM_REV	0x80000000

#define PLX_PCIIDR	PCI_VENDOR_ID
#define PLX_PCICR	PCI_COMMAND
#define PLX_PCISR	PCI_STATUS
#define PLX_PCIREV	PCI_REVISION_ID
#define PLX_PCICCR	PCI_CLASS_PROG
#define PLX_PCICLSR	PCI_CACHE_LINE_SIZE
#define PLX_PCILTR	PCI_LATENCY_TIMER
#define PLX_PCIHTR	PCI_HEADER_TYPE
#define PLX_PCIBISTR	PCI_BIST
#define PLX_PCIBAR0	PCI_BASE_ADDRESS_0
#define PLX_PCIBAR1	PCI_BASE_ADDRESS_1
#define PLX_PCIBAR2	PCI_BASE_ADDRESS_2
#define PLX_PCIBAR3	PCI_BASE_ADDRESS_3
#define PLX_PCIBAR4	PCI_BASE_ADDRESS_4
#define PLX_PCIBAR5	PCI_BASE_ADDRESS_5
#define PLX_PCICIS	PCI_CARDBUS_CIS
#define PLX_PCISVID	PCI_SUBSYSTEM_VNEDOR_ID
#define PLX_PCISID	PCI_SUBSYSTEM_ID
#define PLX_PCIERBAR	PCI_ROM_ADDRESS
#define PLX_PCIILR	PCI_INTERRUPT_LINE
#define PLX_PCIIPR	PCI_INTERRUPT_PIN
#define PLX_PCIMGR	PCI_MIN_GNT
#define PLX_PCIMLR	PCI_MAX_LAT












