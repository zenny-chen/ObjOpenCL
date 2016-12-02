//
//  main.swift
//  OpenCLSwiftDemo
//
//  Created by Zenny Chen on 2016/12/2.
//  Copyright © 2016年 GreenGames Studio. All rights reserved.
//

import Foundation

let OPENCL_KERNEL_PATH = "/Users/zennychen/Downloads/test.cl"

func MyEventHandler(event: cl_event?, status: cl_int, data: UnsafeMutableRawPointer?) {
    puts("The event is completed!");
}

guard let platforms = OCLCreateCurrentPlatformInfos(nil) else {
    print("Your current environment does not support OpenCL!")
    exit(-1)
}

let platform = platforms[0]

let devices = platform.newDevices()
if devices.count == 0 {
    print("No OpenCL devices!")
    exit(-1)
}

var device = devices[0]

for dev in devices {
    if dev.type == Int(CL_DEVICE_TYPE_GPU) {
        device = dev
        break
    }
}

guard let context = device.newContext(nil) else {
    print("Context cannot be created! Error code: \(device.clStatus)")
    exit(-1)
}

let maxWorkGroupSize = device.maxWorkGroupSize
let maxComputeUnits = device.maxComputeUnits
let options = "-D GROUP_NUMBER_OF_WORKITEMS=\(maxWorkGroupSize) -D MAX_COMPUTE_UNITS=\(maxComputeUnits)"
guard let program = context.newProgram([OPENCL_KERNEL_PATH], buildOptions: options, needToFetchSources: true) else {
    print("Failed to build the program!")
    exit(-1)
}

guard let commandQueue = context.newCommandQueue(nil) else {
    print("Failed to create command queue! Error code: \(context.clStatus)")
    exit(-1)
}

let contentLength = 4 * 16 * 1024 * 1024;
guard let memSrc1 = context.newMemoryBuffer(Int(CL_MEM_READ_ONLY), size: contentLength, hostPtr: nil) else {
    print("Failed to create memSrc1 buffer! Error code: \(context.clStatus)")
    exit(-1)
}

guard let memSrc2 = context.newMemoryBuffer(Int(CL_MEM_READ_WRITE), size: contentLength, hostPtr: nil) else {
    print("Failed to create memSrc2 buffer! Error code: \(context.clStatus)")
    exit(-1)
}

var hostBuffer = [Int32]()
for i in 0 ..< (contentLength / 4) {
    hostBuffer.append(i + 1)
}

var event = commandQueue.newEventAndEnqueueWrite(memSrc1, offset: 0, size: contentLength, hostPtr: hostBuffer, waiting: nil)

clSetEventCallback(event?.event, CL_COMPLETE, MyEventHandler, nil)

guard let memDst = context.newMemoryBuffer(Int(CL_MEM_READ_WRITE), size: 16, hostPtr: nil) else {
    print("Failed to create memDst buffer! Error code: \(context.clStatus)")
    exit(-1)
}

commandQueue.enqueueWrite(memDst, offset: 0, size: 8, hostPtr: [Int32(0), Int32(0)], waiting: [event!])

guard let kernel = program.newKernel(program.kernels[0]) else {
    print("Failed to create kernel!")
    exit(-1)
}

kernel.setKernelArgWithMemBuffer(memDst, at: 0)
kernel.setKernelArgWithMemBuffer(memSrc1, at: 1)
kernel.setKernelArgWithMemBuffer(memSrc2, at: 2)

event = commandQueue.newEventAndEnqueueExecute(kernel, workDimensions: 1, global_work_offset: nil, global_work_size: [contentLength], local_work_size: [maxWorkGroupSize], waiting: nil)

context.wait(for: [event!])

var deviceBuffer = [Float](repeating: 0, count: 16)
commandQueue.enqueueRead(memDst, offset: 0, size: 16, hostPtr: &deviceBuffer, waiting: nil)

print("s0 = \(deviceBuffer[0]), s1 = \(deviceBuffer[1]), s3 = \(deviceBuffer[2]), s4 = \(deviceBuffer[3])\n")

