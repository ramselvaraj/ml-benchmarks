; ModuleID = '/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"struct.ap_int<8>" = type { %"struct.ap_int_base<8, true>" }
%"struct.ap_int_base<8, true>" = type { %"struct.ssdm_int<8, true>" }
%"struct.ssdm_int<8, true>" = type { i8 }
%"struct.ap_uint<16>" = type { %"struct.ap_int_base<16, false>" }
%"struct.ap_int_base<16, false>" = type { %"struct.ssdm_int<16, false>" }
%"struct.ssdm_int<16, false>" = type { i16 }

; Function Attrs: noinline
define void @apatb_attention_int8_kernel_ir(%"struct.ap_int<8>"* noalias nocapture nonnull readonly %Q_in, %"struct.ap_int<8>"* noalias nocapture nonnull readonly %K_in, %"struct.ap_int<8>"* noalias nocapture nonnull readonly %V_in, %"struct.ap_uint<16>"* noalias nocapture nonnull %O_out, float %q_scale, float %v_scale) local_unnamed_addr #0 {
entry:
  %malloccall = call i8* @malloc(i64 8192)
  %Q_in_copy = bitcast i8* %malloccall to [8192 x i8]*
  %malloccall1 = call i8* @malloc(i64 8192)
  %K_in_copy = bitcast i8* %malloccall1 to [8192 x i8]*
  %malloccall2 = call i8* @malloc(i64 8192)
  %V_in_copy = bitcast i8* %malloccall2 to [8192 x i8]*
  %malloccall3 = call i8* @malloc(i64 16384)
  %O_out_copy = bitcast i8* %malloccall3 to [8192 x i16]*
  %0 = bitcast %"struct.ap_int<8>"* %Q_in to [8192 x %"struct.ap_int<8>"]*
  %1 = bitcast %"struct.ap_int<8>"* %K_in to [8192 x %"struct.ap_int<8>"]*
  %2 = bitcast %"struct.ap_int<8>"* %V_in to [8192 x %"struct.ap_int<8>"]*
  %3 = bitcast %"struct.ap_uint<16>"* %O_out to [8192 x %"struct.ap_uint<16>"]*
  call fastcc void @copy_in([8192 x %"struct.ap_int<8>"]* nonnull %0, [8192 x i8]* %Q_in_copy, [8192 x %"struct.ap_int<8>"]* nonnull %1, [8192 x i8]* %K_in_copy, [8192 x %"struct.ap_int<8>"]* nonnull %2, [8192 x i8]* %V_in_copy, [8192 x %"struct.ap_uint<16>"]* nonnull %3, [8192 x i16]* %O_out_copy)
  %4 = getelementptr [8192 x i8], [8192 x i8]* %Q_in_copy, i32 0, i32 0
  %5 = getelementptr [8192 x i8], [8192 x i8]* %K_in_copy, i32 0, i32 0
  %6 = getelementptr [8192 x i8], [8192 x i8]* %V_in_copy, i32 0, i32 0
  %7 = getelementptr [8192 x i16], [8192 x i16]* %O_out_copy, i32 0, i32 0
  call void @apatb_attention_int8_kernel_hw(i8* %4, i8* %5, i8* %6, i16* %7, float %q_scale, float %v_scale)
  call void @copy_back([8192 x %"struct.ap_int<8>"]* %0, [8192 x i8]* %Q_in_copy, [8192 x %"struct.ap_int<8>"]* %1, [8192 x i8]* %K_in_copy, [8192 x %"struct.ap_int<8>"]* %2, [8192 x i8]* %V_in_copy, [8192 x %"struct.ap_uint<16>"]* %3, [8192 x i16]* %O_out_copy)
  call void @free(i8* %malloccall)
  call void @free(i8* %malloccall1)
  call void @free(i8* %malloccall2)
  call void @free(i8* %malloccall3)
  ret void
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_in([8192 x %"struct.ap_int<8>"]* noalias readonly, [8192 x i8]* noalias, [8192 x %"struct.ap_int<8>"]* noalias readonly, [8192 x i8]* noalias, [8192 x %"struct.ap_int<8>"]* noalias readonly, [8192 x i8]* noalias, [8192 x %"struct.ap_uint<16>"]* noalias readonly, [8192 x i16]* noalias) unnamed_addr #1 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>.84"([8192 x i8]* %1, [8192 x %"struct.ap_int<8>"]* %0)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>.84"([8192 x i8]* %3, [8192 x %"struct.ap_int<8>"]* %2)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>.84"([8192 x i8]* %5, [8192 x %"struct.ap_int<8>"]* %4)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_uint<16>"([8192 x i16]* %7, [8192 x %"struct.ap_uint<16>"]* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a8192struct.ap_uint<16>"([8192 x i16]* noalias, [8192 x %"struct.ap_uint<16>"]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [8192 x i16]* %0, null
  %3 = icmp eq [8192 x %"struct.ap_uint<16>"]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx7 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [8192 x %"struct.ap_uint<16>"], [8192 x %"struct.ap_uint<16>"]* %1, i64 0, i64 %for.loop.idx7, i32 0, i32 0, i32 0
  %5 = getelementptr [8192 x i16], [8192 x i16]* %0, i64 0, i64 %for.loop.idx7
  %6 = load i16, i16* %src.addr.0.0.05, align 2
  store i16 %6, i16* %5, align 2
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx7, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 8192
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_out([8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_uint<16>"]* noalias, [8192 x i16]* noalias readonly) unnamed_addr #3 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>"([8192 x %"struct.ap_int<8>"]* %0, [8192 x i8]* %1)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>"([8192 x %"struct.ap_int<8>"]* %2, [8192 x i8]* %3)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>"([8192 x %"struct.ap_int<8>"]* %4, [8192 x i8]* %5)
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_uint<16>.78"([8192 x %"struct.ap_uint<16>"]* %6, [8192 x i16]* %7)
  ret void
}

declare void @free(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a8192struct.ap_uint<16>.78"([8192 x %"struct.ap_uint<16>"]* noalias, [8192 x i16]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [8192 x %"struct.ap_uint<16>"]* %0, null
  %3 = icmp eq [8192 x i16]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx7 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %5 = getelementptr [8192 x i16], [8192 x i16]* %1, i64 0, i64 %for.loop.idx7
  %dst.addr.0.0.06 = getelementptr [8192 x %"struct.ap_uint<16>"], [8192 x %"struct.ap_uint<16>"]* %0, i64 0, i64 %for.loop.idx7, i32 0, i32 0, i32 0
  %6 = load i16, i16* %5, align 2
  store i16 %6, i16* %dst.addr.0.0.06, align 2
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx7, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 8192
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>.84"([8192 x i8]* noalias, [8192 x %"struct.ap_int<8>"]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [8192 x i8]* %0, null
  %3 = icmp eq [8192 x %"struct.ap_int<8>"]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx7 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [8192 x %"struct.ap_int<8>"], [8192 x %"struct.ap_int<8>"]* %1, i64 0, i64 %for.loop.idx7, i32 0, i32 0, i32 0
  %5 = getelementptr [8192 x i8], [8192 x i8]* %0, i64 0, i64 %for.loop.idx7
  %6 = load i8, i8* %src.addr.0.0.05, align 1
  store i8 %6, i8* %5, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx7, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 8192
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @"onebyonecpy_hls.p0a8192struct.ap_int<8>"([8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly) unnamed_addr #2 {
entry:
  %2 = icmp eq [8192 x %"struct.ap_int<8>"]* %0, null
  %3 = icmp eq [8192 x i8]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %copy
  %for.loop.idx7 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop ]
  %5 = getelementptr [8192 x i8], [8192 x i8]* %1, i64 0, i64 %for.loop.idx7
  %dst.addr.0.0.06 = getelementptr [8192 x %"struct.ap_int<8>"], [8192 x %"struct.ap_int<8>"]* %0, i64 0, i64 %for.loop.idx7, i32 0, i32 0, i32 0
  %6 = load i8, i8* %5, align 1
  store i8 %6, i8* %dst.addr.0.0.06, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx7, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 8192
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop, %entry
  ret void
}

declare void @apatb_attention_int8_kernel_hw(i8*, i8*, i8*, i16*, float, float)

; Function Attrs: argmemonly noinline norecurse
define internal fastcc void @copy_back([8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_int<8>"]* noalias, [8192 x i8]* noalias readonly, [8192 x %"struct.ap_uint<16>"]* noalias, [8192 x i16]* noalias readonly) unnamed_addr #3 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a8192struct.ap_uint<16>.78"([8192 x %"struct.ap_uint<16>"]* %6, [8192 x i16]* %7)
  ret void
}

define void @attention_int8_kernel_hw_stub_wrapper(i8*, i8*, i8*, i16*, float, float) #4 {
entry:
  %malloccall = tail call i8* @malloc(i64 8192)
  %6 = bitcast i8* %malloccall to [8192 x %"struct.ap_int<8>"]*
  %malloccall1 = tail call i8* @malloc(i64 8192)
  %7 = bitcast i8* %malloccall1 to [8192 x %"struct.ap_int<8>"]*
  %malloccall2 = tail call i8* @malloc(i64 8192)
  %8 = bitcast i8* %malloccall2 to [8192 x %"struct.ap_int<8>"]*
  %malloccall3 = tail call i8* @malloc(i64 16384)
  %9 = bitcast i8* %malloccall3 to [8192 x %"struct.ap_uint<16>"]*
  %10 = bitcast i8* %0 to [8192 x i8]*
  %11 = bitcast i8* %1 to [8192 x i8]*
  %12 = bitcast i8* %2 to [8192 x i8]*
  %13 = bitcast i16* %3 to [8192 x i16]*
  call void @copy_out([8192 x %"struct.ap_int<8>"]* %6, [8192 x i8]* %10, [8192 x %"struct.ap_int<8>"]* %7, [8192 x i8]* %11, [8192 x %"struct.ap_int<8>"]* %8, [8192 x i8]* %12, [8192 x %"struct.ap_uint<16>"]* %9, [8192 x i16]* %13)
  %14 = bitcast [8192 x %"struct.ap_int<8>"]* %6 to %"struct.ap_int<8>"*
  %15 = bitcast [8192 x %"struct.ap_int<8>"]* %7 to %"struct.ap_int<8>"*
  %16 = bitcast [8192 x %"struct.ap_int<8>"]* %8 to %"struct.ap_int<8>"*
  %17 = bitcast [8192 x %"struct.ap_uint<16>"]* %9 to %"struct.ap_uint<16>"*
  call void @attention_int8_kernel_hw_stub(%"struct.ap_int<8>"* %14, %"struct.ap_int<8>"* %15, %"struct.ap_int<8>"* %16, %"struct.ap_uint<16>"* %17, float %4, float %5)
  call void @copy_in([8192 x %"struct.ap_int<8>"]* %6, [8192 x i8]* %10, [8192 x %"struct.ap_int<8>"]* %7, [8192 x i8]* %11, [8192 x %"struct.ap_int<8>"]* %8, [8192 x i8]* %12, [8192 x %"struct.ap_uint<16>"]* %9, [8192 x i16]* %13)
  ret void
}

declare void @attention_int8_kernel_hw_stub(%"struct.ap_int<8>"*, %"struct.ap_int<8>"*, %"struct.ap_int<8>"*, %"struct.ap_uint<16>"*, float, float)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse "fpga.wrapper.func"="copyout" }
attributes #4 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
