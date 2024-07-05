/** @file
File:       IccEval.cpp

Contains:   Implementation of the CIccProfile Evaluation utilites.

Version:    V1

Copyright:  (c) see ICC Software License
*/

/*
* The ICC Software License, Version 0.2
*
*
* Copyright (c) 2003-2012 The International Color Consortium. All rights 
* reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer. 
*
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in
*    the documentation and/or other materials provided with the
*    distribution.
*
* 3. In the absence of prior written permission, the names "ICC" and "The
*    International Color Consortium" must not be used to imply that the
*    ICC organization endorses or promotes products derived from this
*    software.
*
*
* THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED.  IN NO EVENT SHALL THE INTERNATIONAL COLOR CONSORTIUM OR
* ITS CONTRIBUTING MEMBERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
* USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
* OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
* ====================================================================
*
* This software consists of voluntary contributions made by many
* individuals on behalf of the The International Color Consortium. 
*
*
* Membership in the ICC is encouraged when this software is used for
* commercial purposes. 
*
*  
* For more information on The International Color Consortium, please
* see <http://www.color.org/>.
*  
* 
*/

////////////////////////////////////////////////////////////////////// 
// HISTORY:
//
// -Initial implementation by Max Derhak 5-15-2003
//
//////////////////////////////////////////////////////////////////////

#include <math.h>
#include "IccEval.h"
#include "IccTag.h"
#include <algorithm>  // For std::fill

#ifdef USEREFICCMAXNAMESPACE
namespace refIccMAX {
#endif

static const icFloatNumber SMALLNUM = (icFloatNumber)0.0001;
static const icFloatNumber LESSTHANONE = (icFloatNumber)(1.0 - SMALLNUM);

icStatusCMM CIccEvalCompare::EvaluateProfile(CIccProfile *pProfile, icUInt8Number nGran/* = 0 */,
                                             icRenderingIntent nIntent/* = icUnknownIntent */, icXformInterp nInterp/* = icInterpLinear */,
                                             bool buseMpeTags/* = true */)
{
  if (!pProfile)
  {
    return icCmmStatCantOpenProfile;
  }

  if (pProfile->m_Header.deviceClass != icSigInputClass &&
      pProfile->m_Header.deviceClass != icSigDisplayClass &&
      pProfile->m_Header.deviceClass != icSigOutputClass &&
      pProfile->m_Header.deviceClass != icSigColorSpaceClass)
  {
    return icCmmStatInvalidProfile;
  }

  CIccCmm dev2Lab(icSigUnknownData, icSigLabData);
  CIccCmm Lab2Dev2Lab(icSigLabData, icSigLabData, false);

  icStatusCMM result;

  result = dev2Lab.AddXform(*pProfile, nIntent, nInterp, NULL, icXformLutColorimetric, buseMpeTags);
  if (result != icCmmStatOk)
  {
    return result;
  }

  result = dev2Lab.Begin();
  if (result != icCmmStatOk)
  {
    return result;
  }

  result = Lab2Dev2Lab.AddXform(*pProfile, nIntent, nInterp, NULL, icXformLutColorimetric, buseMpeTags);
  if (result != icCmmStatOk)
  {
    return result;
  }

  result = Lab2Dev2Lab.Begin();
  if (result != icCmmStatOk)
  {
    return result;
  }

  // Initialize all arrays to zero to avoid garbage values
  icFloatNumber sPixel[15] = {0};
  icFloatNumber devPcs[15] = {0}, roundPcs1[15] = {0}, roundPcs2[15] = {0};

  int ndim = icGetSpaceSamples(pProfile->m_Header.colorSpace);
  int ndim1 = ndim + 1;

  // Determine granularity
  if (!nGran)
  {
    CIccTagLutAtoB *pTag = (CIccTagLutAtoB *)pProfile->FindTag(icSigAToB0Tag + (nIntent == icAbsoluteColorimetric ? icRelativeColorimetric : nIntent));
    if (!pTag || ndim == 3)
    {
      nGran = 33;
    }
    else
    {
      CIccCLUT *pClut = pTag->GetCLUT();
      if (pClut)
      {
        nGran = pClut->GridPoints() + 2;
      }
      else
      {
        nGran = 33;
      }
    }
  }

  int i, j;
  icFloatNumber stepsize = (icFloatNumber)(1.0 / (icFloatNumber)(nGran - 1));
  icFloatNumber *steps = new icFloatNumber[ndim1]; // Allocate memory for steps

  // Initialize all elements in `steps` to nstart (0.0)
  std::fill(steps, steps + ndim1, 0.0);

  // Ensure `steps[0]` is initialized and loop will terminate
  while (steps[0] <= 1.0)
  {
    for (j = 0; j < ndim; j++)
    {
      sPixel[j] = icMin(steps[j + 1], 1.0);
    }

    // Increment the last index correctly
    steps[ndim] += stepsize;

    // Adjust indexing logic
    for (i = ndim; i > 0; i--)
    {
      if (steps[i] > 1.0)
      {
        steps[i] = 0.0;
        steps[i - 1] += stepsize;
      }
      else
      {
        break;
      }
    }

    dev2Lab.Apply(devPcs, sPixel);        // Convert device value to PCS
    Lab2Dev2Lab.Apply(roundPcs1, devPcs); // First round-trip
    Lab2Dev2Lab.Apply(roundPcs2, roundPcs1); // Second round-trip

    icLabFromPcs(devPcs);
    icLabFromPcs(roundPcs1);
    icLabFromPcs(roundPcs2);

    Compare(sPixel, devPcs, roundPcs1, roundPcs2);
  }

  delete[] steps; // Cleanup allocated memory

  return icCmmStatOk;
}

icStatusCMM CIccEvalCompare::EvaluateProfile(const icChar *szProfilePath, icUInt8Number nGrid/* = 0 */, icRenderingIntent nIntent/* = icUnknownIntent */,
                                             icXformInterp nInterp/* = icInterpLinear */, bool buseMpeTags/* = true */)
{
  CIccProfile *pProfile = ReadIccProfile(szProfilePath);

  if (!pProfile)
  {
    return icCmmStatCantOpenProfile;
  }

  icStatusCMM result = EvaluateProfile(pProfile, nGrid, nIntent, nInterp, buseMpeTags);

  delete pProfile;

  return result;
}


#ifdef USEREFICCMAXNAMESPACE
} //namespace refIccMAX
#endif
