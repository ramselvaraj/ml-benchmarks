; ModuleID = '/home/siyenga7/FPGA/hls_component/attention_int8_kernel/hls/.autopilot/db/a.g.ld.5.gdce.bc'
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
define void @apatb_attention_int8_kernel_ir(%"struct.ap_int<8>"* noalias nocapture nonnull readonly "maxi" %Q_in, %"struct.ap_int<8>"* noalias nocapture nonnull readonly "maxi" %K_in, %"struct.ap_int<8>"* noalias nocapture nonnull readonly "maxi" %V_in, %"struct.ap_uint<16>"* noalias nocapture nonnull "maxi" %O_out, float %q_scale, float %v_scale) local_unnamed_addr #0 {
entry:
  %malloccall = call i8* @malloc(i64 65536)
  %Q_in_copy = bitcast i8* %malloccall to [65536 x i8]*
  %malloccall1 = call i8* @malloc(i64 65536)
  %K_in_copy = bitcast i8* %malloccall1 to [65536 x i8]*
  %malloccall2 = call i8* @malloc(i64 65536)
  %V_in_copy = bitcast i8* %malloccall2 to [65536 x i8]*
  %malloccall3 = call i8* @malloc(i64 131072)
  %O_out_copy = bitcast i8* %malloccall3 to [65536 x i16]*
  %0 = bitcast %"struct.ap_int<8>"* %Q_in to [65536 x %"struct.ap_int<8>"]*
  %1 = bitcast %"struct.ap_int<8>"* %K_in to [65536 x %"struct.ap_int<8>"]*
  %2 = bitcast %"struct.ap_int<8>"* %V_in to [65536 x %"struct.ap_int<8>"]*
  %3 = bitcast %"struct.ap_uint<16>"* %O_out to [65536 x %"struct.ap_uint<16>"]*
  call fastcc void @copy_in([65536 x %"struct.ap_int<8>"]* nonnull %0, [65536 x i8]* %Q_in_copy, [65536 x %"struct.ap_int<8>"]* nonnull %1, [65536 x i8]* %K_in_copy, [65536 x %"struct.ap_int<8>"]* nonnull %2, [65536 x i8]* %V_in_copy, [65536 x %"struct.ap_uint<16>"]* nonnull %3, [65536 x i16]* %O_out_copy)
  call void @apatb_attention_int8_kernel_hw([65536 x i8]* %Q_in_copy, [65536 x i8]* %K_in_copy, [65536 x i8]* %V_in_copy, [65536 x i16]* %O_out_copy, float %q_scale, float %v_scale)
  call void @copy_back([65536 x %"struct.ap_int<8>"]* %0, [65536 x i8]* %Q_in_copy, [65536 x %"struct.ap_int<8>"]* %1, [65536 x i8]* %K_in_copy, [65536 x %"struct.ap_int<8>"]* %2, [65536 x i8]* %V_in_copy, [65536 x %"struct.ap_uint<16>"]* %3, [65536 x i16]* %O_out_copy)
  call void @free(i8* %malloccall)
  call void @free(i8* %malloccall1)
  call void @free(i8* %malloccall2)
  call void @free(i8* %malloccall3)
  ret void
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in([65536 x %"struct.ap_int<8>"]* noalias readonly "unpacked"="0", [65536 x i8]* noalias nocapture "unpacked"="1.0", [65536 x %"struct.ap_int<8>"]* noalias readonly "unpacked"="2", [65536 x i8]* noalias nocapture "unpacked"="3.0", [65536 x %"struct.ap_int<8>"]* noalias readonly "unpacked"="4", [65536 x i8]* noalias nocapture "unpacked"="5.0", [65536 x %"struct.ap_uint<16>"]* noalias readonly "unpacked"="6", [65536 x i16]* noalias nocapture "unpacked"="7.0") unnamed_addr #1 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>.45"([65536 x i8]* %1, [65536 x %"struct.ap_int<8>"]* %0)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>.45"([65536 x i8]* %3, [65536 x %"struct.ap_int<8>"]* %2)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>.45"([65536 x i8]* %5, [65536 x %"struct.ap_int<8>"]* %4)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_uint<16>"([65536 x i16]* %7, [65536 x %"struct.ap_uint<16>"]* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a65536struct.ap_uint<16>"([65536 x i16]* noalias nocapture "unpacked"="0.0" %dst, [65536 x %"struct.ap_uint<16>"]* noalias readonly "unpacked"="1" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_uint<16>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a65536struct.ap_uint<16>"([65536 x i16]* %dst, [65536 x %"struct.ap_uint<16>"]* nonnull %src, i64 65536)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a65536struct.ap_uint<16>"([65536 x i16]* nocapture "unpacked"="0.0" %dst, [65536 x %"struct.ap_uint<16>"]* readonly "unpacked"="1" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_uint<16>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [65536 x %"struct.ap_uint<16>"], [65536 x %"struct.ap_uint<16>"]* %src, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [65536 x i16], [65536 x i16]* %dst, i64 0, i64 %for.loop.idx2
  %1 = load i16, i16* %src.addr.0.0.05, align 2
  store i16 %1, i16* %dst.addr.0.0.06, align 2
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_out([65536 x %"struct.ap_int<8>"]* noalias "unpacked"="0", [65536 x i8]* noalias nocapture readonly "unpacked"="1.0", [65536 x %"struct.ap_int<8>"]* noalias "unpacked"="2", [65536 x i8]* noalias nocapture readonly "unpacked"="3.0", [65536 x %"struct.ap_int<8>"]* noalias "unpacked"="4", [65536 x i8]* noalias nocapture readonly "unpacked"="5.0", [65536 x %"struct.ap_uint<16>"]* noalias "unpacked"="6", [65536 x i16]* noalias nocapture readonly "unpacked"="7.0") unnamed_addr #4 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>"([65536 x %"struct.ap_int<8>"]* %0, [65536 x i8]* %1)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>"([65536 x %"struct.ap_int<8>"]* %2, [65536 x i8]* %3)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>"([65536 x %"struct.ap_int<8>"]* %4, [65536 x i8]* %5)
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_uint<16>.35"([65536 x %"struct.ap_uint<16>"]* %6, [65536 x i16]* %7)
  ret void
}

declare void @free(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a65536struct.ap_uint<16>.35"([65536 x %"struct.ap_uint<16>"]* noalias "unpacked"="0" %dst, [65536 x i16]* noalias nocapture readonly "unpacked"="1.0" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_uint<16>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a65536struct.ap_uint<16>.38"([65536 x %"struct.ap_uint<16>"]* nonnull %dst, [65536 x i16]* %src, i64 65536)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a65536struct.ap_uint<16>.38"([65536 x %"struct.ap_uint<16>"]* "unpacked"="0" %dst, [65536 x i16]* nocapture readonly "unpacked"="1.0" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_uint<16>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [65536 x i16], [65536 x i16]* %src, i64 0, i64 %for.loop.idx2
  %dst.addr.0.0.06 = getelementptr [65536 x %"struct.ap_uint<16>"], [65536 x %"struct.ap_uint<16>"]* %dst, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %1 = load i16, i16* %src.addr.0.0.05, align 2
  store i16 %1, i16* %dst.addr.0.0.06, align 2
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>.45"([65536 x i8]* noalias nocapture "unpacked"="0.0" %dst, [65536 x %"struct.ap_int<8>"]* noalias readonly "unpacked"="1" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_int<8>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a65536struct.ap_int<8>.48"([65536 x i8]* %dst, [65536 x %"struct.ap_int<8>"]* nonnull %src, i64 65536)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a65536struct.ap_int<8>.48"([65536 x i8]* nocapture "unpacked"="0.0" %dst, [65536 x %"struct.ap_int<8>"]* readonly "unpacked"="1" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_int<8>"]* %src, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [65536 x %"struct.ap_int<8>"], [65536 x %"struct.ap_int<8>"]* %src, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [65536 x i8], [65536 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %1 = load i8, i8* %src.addr.0.0.05, align 1
  store i8 %1, i8* %dst.addr.0.0.06, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @"onebyonecpy_hls.p0a65536struct.ap_int<8>"([65536 x %"struct.ap_int<8>"]* noalias "unpacked"="0" %dst, [65536 x i8]* noalias nocapture readonly "unpacked"="1.0" %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_int<8>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @"arraycpy_hls.p0a65536struct.ap_int<8>.55"([65536 x %"struct.ap_int<8>"]* nonnull %dst, [65536 x i8]* %src, i64 65536)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @"arraycpy_hls.p0a65536struct.ap_int<8>.55"([65536 x %"struct.ap_int<8>"]* "unpacked"="0" %dst, [65536 x i8]* nocapture readonly "unpacked"="1.0" %src, i64 "unpacked"="2" %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [65536 x %"struct.ap_int<8>"]* %dst, null
  br i1 %0, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %src.addr.0.0.05 = getelementptr [65536 x i8], [65536 x i8]* %src, i64 0, i64 %for.loop.idx2
  %dst.addr.0.0.06 = getelementptr [65536 x %"struct.ap_int<8>"], [65536 x %"struct.ap_int<8>"]* %dst, i64 0, i64 %for.loop.idx2, i32 0, i32 0, i32 0
  %1 = load i8, i8* %src.addr.0.0.05, align 1
  store i8 %1, i8* %dst.addr.0.0.06, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

declare void @apatb_attention_int8_kernel_hw([65536 x i8]*, [65536 x i8]*, [65536 x i8]*, [65536 x i16]*, float, float)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back([65536 x %"struct.ap_int<8>"]* noalias "unpacked"="0", [65536 x i8]* noalias nocapture readonly "unpacked"="1.0", [65536 x %"struct.ap_int<8>"]* noalias "unpacked"="2", [65536 x i8]* noalias nocapture readonly "unpacked"="3.0", [65536 x %"struct.ap_int<8>"]* noalias "unpacked"="4", [65536 x i8]* noalias nocapture readonly "unpacked"="5.0", [65536 x %"struct.ap_uint<16>"]* noalias "unpacked"="6", [65536 x i16]* noalias nocapture readonly "unpacked"="7.0") unnamed_addr #4 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a65536struct.ap_uint<16>.35"([65536 x %"struct.ap_uint<16>"]* %6, [65536 x i16]* %7)
  ret void
}

define void @attention_int8_kernel_hw_stub_wrapper([65536 x i8]*, [65536 x i8]*, [65536 x i8]*, [65536 x i16]*, float, float) #5 {
entry:
  %malloccall = tail call i8* @malloc(i64 65536)
  %6 = bitcast i8* %malloccall to [65536 x %"struct.ap_int<8>"]*
  %malloccall1 = tail call i8* @malloc(i64 65536)
  %7 = bitcast i8* %malloccall1 to [65536 x %"struct.ap_int<8>"]*
  %malloccall2 = tail call i8* @malloc(i64 65536)
  %8 = bitcast i8* %malloccall2 to [65536 x %"struct.ap_int<8>"]*
  %malloccall3 = tail call i8* @malloc(i64 131072)
  %9 = bitcast i8* %malloccall3 to [65536 x %"struct.ap_uint<16>"]*
  call void @copy_out([65536 x %"struct.ap_int<8>"]* %6, [65536 x i8]* %0, [65536 x %"struct.ap_int<8>"]* %7, [65536 x i8]* %1, [65536 x %"struct.ap_int<8>"]* %8, [65536 x i8]* %2, [65536 x %"struct.ap_uint<16>"]* %9, [65536 x i16]* %3)
  %10 = bitcast [65536 x %"struct.ap_int<8>"]* %6 to %"struct.ap_int<8>"*
  %11 = bitcast [65536 x %"struct.ap_int<8>"]* %7 to %"struct.ap_int<8>"*
  %12 = bitcast [65536 x %"struct.ap_int<8>"]* %8 to %"struct.ap_int<8>"*
  %13 = bitcast [65536 x %"struct.ap_uint<16>"]* %9 to %"struct.ap_uint<16>"*
  call void @attention_int8_kernel_hw_stub(%"struct.ap_int<8>"* %10, %"struct.ap_int<8>"* %11, %"struct.ap_int<8>"* %12, %"struct.ap_uint<16>"* %13, float %4, float %5)
  call void @copy_in([65536 x %"struct.ap_int<8>"]* %6, [65536 x i8]* %0, [65536 x %"struct.ap_int<8>"]* %7, [65536 x i8]* %1, [65536 x %"struct.ap_int<8>"]* %8, [65536 x i8]* %2, [65536 x %"struct.ap_uint<16>"]* %9, [65536 x i16]* %3)
  ret void
}

declare void @attention_int8_kernel_hw_stub(%"struct.ap_int<8>"*, %"struct.ap_int<8>"*, %"struct.ap_int<8>"*, %"struct.ap_uint<16>"*, float, float)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
