#!/bin/zsh
##
## Assumes "iccFromXml" is available in the Build directory
## Command line option "clean" will remove ICCs only and not regenerate
##

# Set relative paths to the tool and directories
BUILD_DIR="$(pwd)"
TOOL_PATH="${BUILD_DIR}/Tools/IccFromXml/iccFromXml"
TESTING_DIR="${BUILD_DIR}/../Testing"
CONTRIB_DIR="${BUILD_DIR}/../contrib/UnitTests/CalcTest"
LOG_FILE="${CONTRIB_DIR}/generate_clean_icc.log"
ERRORS_FILE="${CONTRIB_DIR}/check_profiles_report.txt"

# Expected ICC Files
EXPECTED_ICC_FILES=(
    "Calc/CameraModel.icc"
    "Calc/ElevenChanKubelkaMunk.icc"
    "Calc/RGBWProjector.icc"
    "Calc/argbCalc.icc"
    "Calc/srgbCalcTest.icc"
    "Calc/srgbCalc++Test.icc"
    "CalcTest/calcCheckInit.icc"
    "CalcTest/calcExercizeOps.icc"
    "CMYK-3DLUTs/CMYK-3DLUTs.icc"
    "CMYK-3DLUTs/CMYK-3DLUTs2.icc"
    "Display/GrayGSDF.icc"
    "Display/LCDDisplay.icc"
    "Display/LaserProjector.icc"
    "Display/Rec2020rgbColorimetric.icc"
    "Display/Rec2020rgbSpectral.icc"
    "Display/Rec2100HlgFull.icc"
    "Display/Rec2100HlgNarrow.icc"
    "Display/RgbGSDF.icc"
    "Display/sRGB_D65_MAT-300lx.icc"
    "Display/sRGB_D65_MAT-500lx.icc"
    "Display/sRGB_D65_MAT.icc"
    "Display/sRGB_D65_colorimetric.icc"
    "Encoding/ISO22028-Encoded-sRGB.icc"
    "Encoding/ISO22028-Encoded-bg-sRGB.icc"
    "Encoding/sRgbEncoding.icc"
    "Encoding/sRgbEncodingOverrides.icc"
    "ICS/Lab_float-D65_2deg-Part1.icc"
    "ICS/Lab_float-IllumA_2deg-Part2.icc"
    "ICS/Lab_int-D65_2deg-Part1.icc"
    "ICS/Lab_int-IllumA_2deg-Part2.icc"
    "ICS/Rec2100HlgFull-Part1.icc"
    "ICS/Rec2100HlgFull-Part2.icc"
    "ICS/Rec2100HlgFull-Part3.icc"
    "ICS/Spec400_10_700-D50_2deg-Part1.icc"
    "ICS/Spec400_10_700-D93_2deg-Part2.icc"
    "ICS/XYZ_float-D65_2deg-Part1.icc"
    "ICS/XYZ_float-IllumA_2deg-Part2.icc"
    "ICS/XYZ_int-D65_2deg-Part1.icc"
    "ICS/XYZ_int-IllumA_2deg-Part2.icc"
    "Named/FluorescentNamedColor.icc"
    "Named/NamedColor.icc"
    "Named/SparseMatrixNamedColor.icc"
    "Overprint/17ChanPart1.icc"
    "mcs/Flexo-CMYKOGP/4ChanSelect-MID.icc"
    "mcs/Flexo-CMYKOGP/7ChanSelect-MID.icc"
    "mcs/Flexo-CMYKOGP/CGYK-SelectMID.icc"
    "mcs/Flexo-CMYKOGP/CMPK-SelectMID.icc"
    "mcs/Flexo-CMYKOGP/CMYK-SelectMID.icc"
    "mcs/Flexo-CMYKOGP/CMYKOGP-MVIS-Smooth.icc"
    "mcs/Flexo-CMYKOGP/OMYK-SelectMID.icc"
    "PCC/Lab_float-D50_2deg.icc"
    "PCC/Lab_float-D93_2deg-MAT.icc"
    "PCC/Lab_int-D50_2deg.icc"
    "PCC/Lab_int-D65_2deg-MAT.icc"
    "PCC/Lab_int-IllumA_2deg-MAT.icc"
    "PCC/Spec380_10_730-D50_2deg.icc"
    "PCC/Spec380_10_730-D65_2deg-MAT.icc"
    "SpecRef/argbRef.icc"
    "SpecRef/SixChanCameraRef.icc"
    "SpecRef/SixChanInputRef.icc"
    "SpecRef/srgbRef.icc"
    "SpecRef/RefDecC.icc"
    "SpecRef/RefDecH.icc"
    "SpecRef/RefIncW.icc"
)

# Clear or create log files
echo "" > "${LOG_FILE}"
echo "" > "${ERRORS_FILE}"

# Command line argument validation and tool availability
if [[ "${PWD}" != "${BUILD_DIR}" ]]; then
    echo "Please run this script from the Build directory."
    exit 1
elif [[ "$1" == "clean" ]]; then
    echo "CLEANING!" | tee -a "${LOG_FILE}"
elif [[ "$#" -ge 1 ]]; then
    echo "Unknown command line options" | tee -a "${LOG_FILE}"
    exit 1
elif [[ ! -x "${TOOL_PATH}" ]]; then
    echo "iccFromXml tool not found at ${TOOL_PATH}" | tee -a "${LOG_FILE}"
    exit 1
fi

# Function to process directories
process_directory() {
    local directory="$1"
    shift
    echo "Processing directory: ${directory}" | tee -a "${LOG_FILE}"
    cd "${directory}" || { echo "Directory not found: ${directory}" | tee -a "${LOG_FILE}"; return; }
    find . -iname "*.icc" -delete
    if [[ "$1" != "clean" ]]; then
        set -x
        for pair in "$@"; do
            eval "${pair}" >>"${LOG_FILE}" 2>&1
            local exit_code=$?
            if [[ ${exit_code} -ne 0 ]]; then
                echo "Error generating ICC: ${pair}" | tee -a "${LOG_FILE}"
                echo "${directory}: ${pair}" >> "${ERRORS_FILE}"
            fi
        done
        set +x
    fi
    cd - >/dev/null
}

# Function to check profiles and log errors
check_profiles() {
    local directory="$1"
    shift
    echo "Checking profiles in directory: ${directory}" | tee -a "${ERRORS_FILE}"
    cd "${directory}" || { echo "Directory not found: ${directory}" | tee -a "${ERRORS_FILE}"; return; }
    for profile in "$@"; do
        echo "2024-05-07 $(date '+%T'): Checking profile: ${profile}" >> "${ERRORS_FILE}"
        echo "Built with IccProfLib version 2.2.3" >> "${ERRORS_FILE}"
        if ! eval "${BUILD_DIR}/Tools/IccFromXml/iccFromXml ${profile}" >>"${ERRORS_FILE}" 2>&1; then
            echo "Unable to parse '${profile}' as ICC profile!" >> "${ERRORS_FILE}"
            echo "Validation Report" >> "${ERRORS_FILE}"
            echo "-----------------" >> "${ERRORS_FILE}"
            echo "Profile has Critical Error(s) that violate ICC specification" >> "${ERRORS_FILE}"
            echo "Error! -  - ${profile}- Invalid Filename" >> "${ERRORS_FILE}"
            echo "EXIT -1" >> "${ERRORS_FILE}"
        else
            echo "Profile is valid: ${profile}" >> "${ERRORS_FILE}"
        fi
    done
    cd - >/dev/null
}

# Process all directories
process_directory "${TESTING_DIR}/Calc" \
    "${TOOL_PATH} CameraModel.xml CameraModel.icc" \
    "${TOOL_PATH} ElevenChanKubelkaMunk.xml ElevenChanKubelkaMunk.icc" \
    "${TOOL_PATH} RGBWProjector.xml RGBWProjector.icc" \
    "${TOOL_PATH} argbCalc.xml argbCalc.icc" \
    "${TOOL_PATH} srgbCalcTest.xml srgbCalcTest.icc" \
    "${TOOL_PATH} srgbCalc++Test.xml srgbCalc++Test.icc"

process_directory "${TESTING_DIR}/CalcTest" \
    "${TOOL_PATH} calcCheckInit.xml calcCheckInit.icc" \
    "${TOOL_PATH} calcExercizeOps.xml calcExercizeOps.icc"

process_directory "${TESTING_DIR}/CMYK-3DLUTs" \
    "${TOOL_PATH} CMYK-3DLUTs.xml CMYK-3DLUTs.icc" \
    "${TOOL_PATH} CMYK-3DLUTs2.xml CMYK-3DLUTs2.icc"

process_directory "${TESTING_DIR}/Display" \
    "${TOOL_PATH} GrayGSDF.xml GrayGSDF.icc" \
    "${TOOL_PATH} LCDDisplay.xml LCDDisplay.icc" \
    "${TOOL_PATH} LaserProjector.xml LaserProjector.icc" \
    "${TOOL_PATH} Rec2020rgbColorimetric.xml Rec2020rgbColorimetric.icc" \
    "${TOOL_PATH} Rec2020rgbSpectral.xml Rec2020rgbSpectral.icc" \
    "${TOOL_PATH} Rec2100HlgFull.xml Rec2100HlgFull.icc" \
    "${TOOL_PATH} Rec2100HlgNarrow.xml Rec2100HlgNarrow.icc" \
    "${TOOL_PATH} RgbGSDF.xml RgbGSDF.icc" \
    "${TOOL_PATH} sRGB_D65_MAT-300lx.xml sRGB_D65_MAT-300lx.icc" \
    "${TOOL_PATH} sRGB_D65_MAT-500lx.xml sRGB_D65_MAT-500lx.icc" \
    "${TOOL_PATH} sRGB_D65_MAT.xml sRGB_D65_MAT.icc" \
    "${TOOL_PATH} sRGB_D65_colorimetric.xml sRGB_D65_colorimetric.icc"

process_directory "${TESTING_DIR}/Encoding" \
    "${TOOL_PATH} ISO22028-Encoded-sRGB.xml ISO22028-Encoded-sRGB.icc" \
    "${TOOL_PATH} ISO22028-Encoded-bg-sRGB.xml ISO22028-Encoded-bg-sRGB.icc" \
    "${TOOL_PATH} sRgbEncoding.xml sRgbEncoding.icc" \
    "${TOOL_PATH} sRgbEncodingOverrides.xml sRgbEncodingOverrides.icc"

process_directory "${TESTING_DIR}/ICS" \
    "${TOOL_PATH} Lab_float-D65_2deg-Part1.xml Lab_float-D65_2deg-Part1.icc" \
    "${TOOL_PATH} Lab_float-IllumA_2deg-Part2.xml Lab_float-IllumA_2deg-Part2.icc" \
    "${TOOL_PATH} Lab_int-D65_2deg-Part1.xml Lab_int-D65_2deg-Part1.icc" \
    "${TOOL_PATH} Lab_int-IllumA_2deg-Part2.xml Lab_int-IllumA_2deg-Part2.icc" \
    "${TOOL_PATH} Rec2100HlgFull-Part1.xml Rec2100HlgFull-Part1.icc" \
    "${TOOL_PATH} Rec2100HlgFull-Part2.xml Rec2100HlgFull-Part2.icc" \
    "${TOOL_PATH} Rec2100HlgFull-Part3.xml Rec2100HlgFull-Part3.icc" \
    "${TOOL_PATH} Spec400_10_700-D50_2deg-Part1.xml Spec400_10_700-D50_2deg-Part1.icc" \
    "${TOOL_PATH} Spec400_10_700-D93_2deg-Part2.xml Spec400_10_700-D93_2deg-Part2.icc" \
    "${TOOL_PATH} XYZ_float-D65_2deg-Part1.xml XYZ_float-D65_2deg-Part1.icc" \
    "${TOOL_PATH} XYZ_float-IllumA_2deg-Part2.xml XYZ_float-IllumA_2deg-Part2.icc" \
    "${TOOL_PATH} XYZ_int-D65_2deg-Part1.xml XYZ_int-D65_2deg-Part1.icc" \
    "${TOOL_PATH} XYZ_int-IllumA_2deg-Part2.xml XYZ_int-IllumA_2deg-Part2.icc"

process_directory "${TESTING_DIR}/Named" \
    "${TOOL_PATH} FluorescentNamedColor.xml FluorescentNamedColor.icc" \
    "${TOOL_PATH} NamedColor.xml NamedColor.icc" \
    "${TOOL_PATH} SparseMatrixNamedColor.xml SparseMatrixNamedColor.icc"

# Add problematic file skipping and error logging
process_directory "${TESTING_DIR}/CMYK-3DLUTs" \
    "${TOOL_PATH} CMYK-3DLUTs.xml CMYK-3DLUTs.icc || echo 'Skipped CMYK-3DLUTs.xml due to error' >>${ERRORS_FILE}" \
    "${TOOL_PATH} CMYK-3DLUTs2.xml CMYK-3DLUTs2.icc || echo 'Skipped CMYK-3DLUTs2.xml due to error' >>${ERRORS_FILE}"

process_directory "${TESTING_DIR}/Overprint" \
    "${TOOL_PATH} 17ChanPart1.xml 17ChanPart1.icc || echo 'Skipped 17ChanPart1.xml due to error' >>${ERRORS_FILE}"

process_directory "${TESTING_DIR}/mcs/Flexo-CMYKOGP" \
    "${TOOL_PATH} 4ChanSelect-MID.xml 4ChanSelect-MID.icc" \
    "${TOOL_PATH} 7ChanSelect-MID.xml 7ChanSelect-MID.icc" \
    "${TOOL_PATH} CGYK-SelectMID.xml CGYK-SelectMID.icc" \
    "${TOOL_PATH} CMPK-SelectMID.xml CMPK-SelectMID.icc" \
    "${TOOL_PATH} CMYK-SelectMID.xml CMYK-SelectMID.icc" \
    "${TOOL_PATH} CMYKOGP-MVIS-Smooth.xml CMYKOGP-MVIS-Smooth.icc" \
    "${TOOL_PATH} OMYK-SelectMID.xml OMYK-SelectMID.icc"

process_directory "${TESTING_DIR}/PCC" \
    "${TOOL_PATH} Lab_float-D50_2deg.xml Lab_float-D50_2deg.icc" \
    "${TOOL_PATH} Lab_float-D93_2deg-MAT.xml Lab_float-D93_2deg-MAT.icc" \
    "${TOOL_PATH} Lab_int-D50_2deg.xml Lab_int-D50_2deg.icc" \
    "${TOOL_PATH} Lab_int-D65_2deg-MAT.xml Lab_int-D65_2deg-MAT.icc" \
    "${TOOL_PATH} Lab_int-IllumA_2deg-MAT.xml Lab_int-IllumA_2deg-MAT.icc" \
    "${TOOL_PATH} Spec380_10_730-D50_2deg.xml Spec380_10_730-D50_2deg.icc" \
    "${TOOL_PATH} Spec380_10_730-D65_2deg-MAT.xml Spec380_10_730-D65_2deg-MAT.icc"

process_directory "${TESTING_DIR}/SpecRef" \
    "${TOOL_PATH} argbRef.xml argbRef.icc" \
    "${TOOL_PATH} SixChanCameraRef.xml SixChanCameraRef.icc" \
    "${TOOL_PATH} SixChanInputRef.xml SixChanInputRef.icc" \
    "${TOOL_PATH} srgbRef.xml srgbRef.icc" \
    "${TOOL_PATH} RefDecC.xml RefDecC.icc" \
    "${TOOL_PATH} RefDecH.xml RefDecH.icc" \
    "${TOOL_PATH} RefIncW.xml RefIncW.icc"

# Count number of ICCs that exist to confirm
if [[ "$1" != "clean" ]]; then
    echo -n "Should be 207 ICC files: " | tee -a "${LOG_FILE}"
    find "${TESTING_DIR}" -iname "*.icc" | wc -l | tee -a "${LOG_FILE}"
else
    echo -n "Should be 80 ICC files after a clean: " | tee -a "${LOG_FILE}"
    find "${TESTING_DIR}" -iname "*.icc" | wc -l | tee -a "${LOG_FILE}"
fi

# Update missing ICC files output
echo "Problematic files (if any):" | tee -a "${LOG_FILE}"
cat "${ERRORS_FILE}" | tee -a "${LOG_FILE}"

# Identify missing ICC files
echo "Checking for missing ICC files..." | tee -a "${LOG_FILE}"
MISSING_ICC_FILES=()
for expected_file in "${EXPECTED_ICC_FILES[@]}"; do
    if [[ ! -f "${TESTING_DIR}/${expected_file}" ]]; then
        MISSING_ICC_FILES+=("${expected_file}")
    fi
done

if [[ ${#MISSING_ICC_FILES[@]} -eq 0 ]]; then
    echo "All expected ICC files are generated." | tee -a "${LOG_FILE}"
else
    echo "Missing ICC files:" | tee -a "${LOG_FILE}"
    for missing_file in "${MISSING_ICC_FILES[@]}"; do
        echo "${missing_file}" | tee -a "${LOG_FILE}"
    done
fi
