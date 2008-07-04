
/*
File: ByteSwap.h

Contains: Fast Endian Mapping Utilities

Version: 0.1

Copyright: ) 1998-9 by Steve Sisak, all rights reserved.

Permission is granted to use this code freely as long as
this notice is preserved

Bugs?: Please send bugs to Steve Sisak <email@hidden>

*/


#ifndef __BYTESWAP__
#define __BYTESWAP__

#ifndef __ENDIAN__
#include <Endian.h>
#endif

#if PRAGMA_ONCE
#pragma once
#endif

#if PRAGMA_STRUCT_ALIGN
#pragma options align=mac68k
#elif PRAGMA_STRUCT_PACKPUSH
#pragma pack(push, 2)
#elif PRAGMA_STRUCT_PACK
#pragma pack(2)
#endif

/*

This needs to be set if compiler supports __sthbrx, etc.

*/

#if __MWERKS__
#define PPC_BYTE_SWAP TARGET_CPU_PPC
#define PPC_BYTE_SWAP_OUT_OF_LINE qDebug
#endif

#if PPC_BYTE_SWAP_OUT_OF_LINE

// These are provided for certain debuggers which have trouble stepping over __sthbrx, etc.

UInt8 LoadByteSwapped(const UInt8* src);
SInt8 LoadByteSwapped(const SInt8* src);
UInt32 LoadByteSwapped(const UInt16* src);
SInt32 LoadByteSwapped(const SInt16* src);
UInt32 LoadByteSwapped(const UInt32* src);
SInt32 LoadByteSwapped(const SInt32* src);

void StoreByteSwapped(UInt8 valu, UInt8* dst);
void StoreByteSwapped(UInt16 valu, UInt16* dst);
void StoreByteSwapped(SInt16 valu, SInt16* dst);
void StoreByteSwapped(UInt32 valu, UInt32* dst);
void StoreByteSwapped(SInt32 valu, SInt32* dst);

#elif PPC_BYTE_SWAP

// The PowerPC can byte-swap 16- and 32-bit valuse integral values while loading/storing them

// NOTE: LoadByteSwapped(const UInt16* src) returning a UInt32 is not a typo -- __lhbrx is
// defined to zero the high word making the result a valid UInt32 (saving a gratuitous mask
// if that's what the user wants) LoadByteSwapped(const SInt16* src) returns an SInt16 so
// an extend will be generated if the user assigns to an SInt32 but not if they use an SInt16.

// The SInt8/UInt8 no-ops are defined for convenience/consistency in using the templated types

inline UInt8 LoadByteSwapped(const UInt8* src) { return *src; }
inline SInt8 LoadByteSwapped(const SInt8* src) { return *src; }
inline UInt32 LoadByteSwapped(const UInt16* src) { return static_cast<UInt32>(__lhbrx((void*) src, 0)); }
inline SInt16 LoadByteSwapped(const SInt16* src) { return static_cast<SInt16>(__lhbrx((void*) src, 0)); }
inline UInt32 LoadByteSwapped(const UInt32* src) { return static_cast<UInt32>(__lwbrx((void*) src, 0)); }
inline SInt32 LoadByteSwapped(const SInt32* src) { return static_cast<SInt32>(__lwbrx((void*) src, 0)); }

inline void StoreByteSwapped(UInt8 valu, UInt8* dst) { *dst = valu; }
inline void StoreByteSwapped(UInt16 valu, UInt16* dst) { __sthbrx(valu, dst, 0); }
inline void StoreByteSwapped(SInt16 valu, SInt16* dst) { __sthbrx(valu, dst, 0); }
inline void StoreByteSwapped(UInt32 valu, UInt32* dst) { __stwbrx(valu, dst, 0); }
inline void StoreByteSwapped(SInt32 valu, SInt32* dst) { __stwbrx(valu, dst, 0); }

#else

inline UInt8 LoadByteSwapped(const UInt8* src) { return *src; }
inline SInt8 LoadByteSwapped(const SInt8* src) { return *src; }
inline UInt16 LoadByteSwapped(const UInt16* src) { return static_cast<UInt16>(Endian16_Swap(*src)); }
inline SInt16 LoadByteSwapped(const SInt16* src) { return static_cast<SInt16>(Endian16_Swap(*src)); }
inline UInt32 LoadByteSwapped(const UInt32* src) { return static_cast<UInt32>(Endian32_Swap(*src)); }
inline SInt32 LoadByteSwapped(const SInt32* src) { return static_cast<SInt32>(Endian32_Swap(*src)); }

inline void StoreByteSwapped(UInt8 valu, UInt8* dst) { *dst = valu; }
inline void StoreByteSwapped(UInt16 valu, UInt16* dst) { *dst = static_cast<UInt16>(Endian16_Swap(valu)); }
inline void StoreByteSwapped(SInt16 valu, SInt16* dst) { *dst = static_cast<SInt16>(Endian16_Swap(valu)); }
inline void StoreByteSwapped(UInt32 valu, UInt32* dst) { *dst = static_cast<UInt32>(Endian32_Swap(valu)); }
inline void StoreByteSwapped(SInt32 valu, SInt32* dst) { *dst = static_cast<SInt32>(Endian32_Swap(valu)); }

#endif

inline UInt64 LoadByteSwapped(const UInt64* src) { return Endian64_Swap(*src); }
inline SInt64 LoadByteSwapped(const SInt64* src) { return Endian64_Swap(*src); }

inline void StoreByteSwapped(UInt64 val, UInt64* dst) { *dst = (UInt64) Endian64_Swap(val); }
inline void StoreByteSwapped(SInt64 val, SInt64* dst) { *dst = (SInt64) Endian64_Swap(val); }

// template for a byte-swapped integer

template <class T>
struct ByteSwapped
{
T rawValue;

inline ByteSwapped() { }
inline ByteSwapped(T val) { StoreByteSwapped(val, &rawValue); }
inline ByteSwapped(const ByteSwapped<T>& val) { rawValue = val.rawValue; }

inline operator T() const { return LoadByteSwapped(&rawValue); }

inline ByteSwapped<T>& operator=(T val) { StoreByteSwapped(val, &rawValue); return *this; }
inline ByteSwapped<T>& operator=(const ByteSwapped<T>& rhs) { rawValue = rhs.rawValue; return *this; }

inline ByteSwapped<T>& operator+=(T val) { *this = *this + val; return *this; }
inline ByteSwapped<T>& operator-=(T val) { *this = *this - val; return *this; }
inline ByteSwapped<T>& operator*=(T val) { *this = *this * val; return *this; }
inline ByteSwapped<T>& operator/=(T val) { *this = *this / val; return *this; }
};

template <class T>
inline void CopyByteSwapped(const T* src, ByteSwapped<T>* dst, UInt32 count)
{
while (count-- > 0)
{
T v = *src++;
*dst++ = v;
}
}

template <class T>
inline void CopyByteSwapped(const ByteSwapped<T>* src, T* dst, UInt32 count)
{
while (count-- > 0)
{
T v = *src++;
*dst++ = v;
}
}

// Byte-swapped integral types

typedef ByteSwapped<UInt16> BSUInt16;
typedef ByteSwapped<SInt16> BSSInt16;
typedef ByteSwapped<UInt32> BSUInt32;
typedef ByteSwapped<SInt32> BSSInt32;
typedef ByteSwapped<UInt64> BSUInt64;
typedef ByteSwapped<SInt64> BSSInt64;

#if TARGET_RT_BIG_ENDIAN

// Little-endian types

typedef BSUInt16 LEUInt16;
typedef BSSInt16 LESInt16;
typedef BSUInt32 LEUInt32;
typedef BSSInt32 LESInt32;
typedef BSUInt64 LEUInt64;
typedef BSSInt64 LESInt64;

// Big-endian types

typedef UInt16 BEUInt16;
typedef SInt16 BESInt16;
typedef UInt32 BEUInt32;
typedef SInt32 BESInt32;
typedef UInt64 BEUInt64;
typedef SInt64 BESInt64;

#else

// Little-endian types

typedef UInt16 LEUInt16;
typedef SInt16 LESInt16;
typedef UInt32 LEUInt32;
typedef SInt32 LESInt32;
typedef UInt64 LEUInt64;
typedef SInt64 LESInt64;

// Big-endian types

typedef BSUInt16 BEUInt16;
typedef BSSInt16 BESInt16;
typedef BSUInt32 BEUInt32;
typedef BSSInt32 BESInt32;
typedef BSUInt64 BEUInt64;
typedef BSSInt64 BESInt64;

#endif

void ByteSwapArray(const UInt16* src, BSUInt16* dst, UInt32 count);
void ByteSwapArray(const UInt32* src, BSUInt32* dst, UInt32 count);
void ByteSwapArray(const UInt64* src, BSUInt64* dst, UInt32 count);

//-

inline void ByteSwapArray(const SInt16* src, BSSInt16* dst, UInt32 count)
{
ByteSwapArray((const UInt16*) src, (BSUInt16*) dst, count);
}

inline void ByteSwapArray(const SInt32* src, BSSInt32* dst, UInt32 count)
{
ByteSwapArray((const UInt32*) src, (BSUInt32*) dst, count);
}

inline void ByteSwapArray(const SInt64* src, BSSInt64* dst, UInt32 count)
{
ByteSwapArray((const UInt64*) src, (BSUInt64*) dst, count);
}

//-

inline void ByteSwapArray(const BSUInt16* src, UInt16* dst, UInt32 count)
{
ByteSwapArray((const UInt16*) src, (BSUInt16*) dst, count);
}

inline void ByteSwapArray(const BSUInt32* src, UInt32* dst, UInt32 count)
{
ByteSwapArray((const UInt32*) src, (BSUInt32*) dst, count);
}

inline void ByteSwapArray(const BSUInt64* src, UInt64* dst, UInt32 count)
{
ByteSwapArray((const UInt64*) src, (BSUInt64*) dst, count);
}

//-

inline void ByteSwapArray(const BSSInt16* src, SInt16* dst, SInt32 count)
{
ByteSwapArray((const UInt16*) src, (BSUInt16*) dst, count);
}

inline void ByteSwapArray(const BSSInt32* src, SInt32* dst, SInt32 count)
{
ByteSwapArray((const UInt32*) src, (BSUInt32*) dst, count);
}

inline void ByteSwapArray(const BSSInt64* src, SInt64* dst, SInt32 count)
{
ByteSwapArray((const UInt64*) src, (BSUInt64*) dst, count);
}


#if PRAGMA_STRUCT_ALIGN
#pragma options align=reset
#elif PRAGMA_STRUCT_PACKPUSH
#pragma pack(pop)
#elif PRAGMA_STRUCT_PACK
#pragma pack()
#endif

#endif // __BYTESWAP__
