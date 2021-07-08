cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(rikntp CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-rtti")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
add_definitions(-DBOOST_ERROR_CODE_HEADER_ONLY)
add_definitions(-DBOOST_SYSTEM_NO_DEPRECATED)
add_definitions(-DBOOST_ALL_NO_LIB)
add_definitions(-DBOOST_NO_RTTI)
add_definitions(-DBOOST_NO_TYPEID)
add_definitions(-DBOOST_ASIO_DISABLE_THREADS)

set(SRC_FILES src/mainapp.cpp src/rikntp.cpp)

# import sdbusplus
find_package(PkgConfig REQUIRED)
pkg_check_modules(SDBUSPLUSPLUS sdbusplus REQUIRED)
include_directories(${SDBUSPLUSPLUS_INCLUDE_DIRS})
link_directories(${SDBUSPLUSPLUS_LIBRARY_DIRS})
find_program(SDBUSPLUSPLUS sdbus++)

# phosphor-dbus-interfaces
find_package(PkgConfig REQUIRED)
pkg_check_modules(DBUSINTERFACE phosphor-dbus-interfaces REQUIRED)
include_directories(${DBUSINTERFACE_INCLUDE_DIRS})
link_directories(${DBUSINTERFACE_LIBRARY_DIRS})

# import phosphor-logging
find_package(PkgConfig REQUIRED)
pkg_check_modules(LOGGING phosphor-logging REQUIRED)
include_directories(${LOGGING_INCLUDE_DIRS})
link_directories(${LOGGING_LIBRARY_DIRS})

# import postfix
#find_package(PkgConfig REQUIRED)
#pkg_check_modules(POSTFIX postfix REQUIRED)
#include_directories(${POSTFIX_INCLUDE_DIRS})
#link_directories(${POSTFIX_LIBRARY_DIRS})

add_executable(${PROJECT_NAME} ${SRC_FILES})
#target_link_libraries(${PROJECT_NAME} ${POSTFIX_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${SDBUSPLUSPLUS_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${DBUSINTERFACE_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${Boost_LIBRARIES})
target_link_libraries(${PROJECT_NAME} phosphor_logging)

set(SERVICE_FILES
    ${PROJECT_SOURCE_DIR}/xyz.openbmc_project.rikntp.service
    )

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(FILES ${SERVICE_FILES} DESTINATION /lib/systemd/system/)
install(FILES ${PROJECT_SOURCE_DIR}/rikntp.conf DESTINATION /etc/rikntp COMPONENT config)
install(FILES ${PROJECT_SOURCE_DIR}/rikntp.service DESTINATION /etc/systemd/system)
install(FILES ${PROJECT_SOURCE_DIR}/rikntp.timer DESTINATION /etc/systemd/system)
install(PROGRAMS ${PROJECT_SOURCE_DIR}/ntp.sh DESTINATION /usr/sbin)
install(PROGRAMS ${PROJECT_SOURCE_DIR}/uptimer.sh DESTINATION /usr/sbin)

