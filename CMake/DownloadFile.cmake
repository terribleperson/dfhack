# Helper to download files as needed

function(file_md5_if_exists FILE VAR)
  if(EXISTS "${FILE}")
    file(MD5 "${FILE}" "${VAR}")
    set(${VAR} "${${VAR}}" PARENT_SCOPE)
  else()
    set(${VAR} "" PARENT_SCOPE)
  endif()
endfunction()

function(download_file URL DEST EXPECTED_MD5)
  get_filename_component(FILENAME "${URL}" NAME)
  file_md5_if_exists("${DEST}" CUR_MD5)

  if(NOT "${EXPECTED_MD5}" STREQUAL "${CUR_MD5}")
    message("* Downloading ${FILENAME}")
    file(DOWNLOAD "${URL}" "${DEST}" EXPECTED_MD5 "${EXPECTED_MD5}" SHOW_PROGRESS)
  endif()
endfunction()

# Download a file and uncompress it
function(download_file_unzip URL ZIP_TYPE ZIP_DEST ZIP_MD5 UNZIP_DEST UNZIP_MD5)
  get_filename_component(FILENAME "${URL}" NAME)
  file_md5_if_exists("${UNZIP_DEST}" CUR_UNZIP_MD5)

  # Redownload if the MD5 of the uncompressed file doesn't match
  if(NOT "${UNZIP_MD5}" STREQUAL "${CUR_UNZIP_MD5}")
    download_file("${URL}" "${ZIP_DEST}" "${ZIP_MD5}")

    if(EXISTS "${ZIP_DEST}")
      message("* Decompressing ${FILENAME}")
      if("${ZIP_TYPE}" STREQUAL "gz")
        execute_process(COMMAND gunzip --force "${ZIP_DEST}")
      else()
        message(SEND_ERROR "Unknown ZIP_TYPE: ${ZIP_TYPE}")
      endif()
      if(NOT EXISTS "${UNZIP_DEST}")
        message(SEND_ERROR "File failed to unzip to ${UNZIP_DEST}")
      else()
        file(MD5 "${UNZIP_DEST}" CUR_UNZIP_MD5)
        if(NOT "${UNZIP_MD5}" STREQUAL "${CUR_UNZIP_MD5}")
          message(SEND_ERROR "MD5 mismatch: ${UNZIP_DEST}: expected ${UNZIP_MD5}, got ${CUR_UNZIP_MD5}")
        endif()
      endif()
    endif()
  endif()
endfunction()
