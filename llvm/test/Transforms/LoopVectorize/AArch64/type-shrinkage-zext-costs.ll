; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; REQUIRES: asserts
; RUN: opt -S -passes=loop-vectorize,instsimplify -force-vector-interleave=1 \
; RUN:   -debug-only=loop-vectorize 2>%t < %s | FileCheck %s
; RUN: cat %t | FileCheck %s --check-prefix=CHECK-COST

target triple = "aarch64-unknown-linux-gnu"

define void @zext_i8_i16(ptr noalias nocapture readonly %p, ptr noalias nocapture %q, i32 %len) #0 {
; CHECK-COST-LABEL: LV: Checking a loop in 'zext_i8_i16'
; CHECK-COST: LV: Found an estimated cost of 0 for VF 1 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 2 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 4 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 8 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 2 for VF 16 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 1 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 2 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 4 For instruction:   %conv = zext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 0 for VF vscale x 8 For instruction:   %conv = zext i8 %0 to i32

; CHECK-LABEL: define void @zext_i8_i16
; CHECK-SAME: (ptr noalias nocapture readonly [[P:%.*]], ptr noalias nocapture [[Q:%.*]], i32 [[LEN:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[LEN]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[TMP0]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP4:%.*]] = mul i64 [[TMP3]], 8
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP2]], [[TMP4]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP5:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP6:%.*]] = mul i64 [[TMP5]], 8
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP2]], [[TMP6]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP2]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[INDEX]]
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = zext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i16>
; CHECK-NEXT:    [[TMP9:%.*]] = add <vscale x 8 x i16> [[TMP8]], trunc (<vscale x 8 x i32> shufflevector (<vscale x 8 x i32> insertelement (<vscale x 8 x i32> poison, i32 2, i64 0), <vscale x 8 x i32> poison, <vscale x 8 x i32> zeroinitializer) to <vscale x 8 x i16>)
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i16, ptr [[Q]], i64 [[INDEX]]
; CHECK-NEXT:    store <vscale x 8 x i16> [[TMP9]], ptr [[TMP10]], align 2
; CHECK-NEXT:    [[TMP11:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP12:%.*]] = mul i64 [[TMP11]], 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP12]]
; CHECK-NEXT:    [[TMP13:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP13]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[EXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP14:%.*]] = load i8, ptr [[ARRAYIDX]], align 1
; CHECK-NEXT:    [[CONV:%.*]] = zext i8 [[TMP14]] to i32
; CHECK-NEXT:    [[ADD:%.*]] = add nuw nsw i32 [[CONV]], 2
; CHECK-NEXT:    [[CONV1:%.*]] = trunc i32 [[ADD]] to i16
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i16, ptr [[Q]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i16 [[CONV1]], ptr [[ARRAYIDX3]], align 2
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], [[LEN]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[EXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP3:![0-9]+]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i8, ptr %p, i64 %indvars.iv
  %0 = load i8, ptr %arrayidx
  %conv = zext i8 %0 to i32
  %add = add nuw nsw i32 %conv, 2
  %conv1 = trunc i32 %add to i16
  %arrayidx3 = getelementptr inbounds i16, ptr %q, i64 %indvars.iv
  store i16 %conv1, ptr %arrayidx3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %len
  br i1 %exitcond, label %exit, label %for.body

exit:                                 ; preds = %for.body
  ret void
}

define void @sext_i8_i16(ptr noalias nocapture readonly %p, ptr noalias nocapture %q, i32 %len) #0 {
; CHECK-COST-LABEL: LV: Checking a loop in 'sext_i8_i16'
; CHECK-COST: LV: Found an estimated cost of 0 for VF 1 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 2 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 4 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF 8 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 2 for VF 16 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 1 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 2 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 1 for VF vscale x 4 For instruction:   %conv = sext i8 %0 to i32
; CHECK-COST: LV: Found an estimated cost of 0 for VF vscale x 8 For instruction:   %conv = sext i8 %0 to i32

; CHECK-LABEL: define void @sext_i8_i16
; CHECK-SAME: (ptr noalias nocapture readonly [[P:%.*]], ptr noalias nocapture [[Q:%.*]], i32 [[LEN:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[LEN]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = zext i32 [[TMP0]] to i64
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    [[TMP3:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP4:%.*]] = mul i64 [[TMP3]], 8
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP2]], [[TMP4]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP5:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP6:%.*]] = mul i64 [[TMP5]], 8
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP2]], [[TMP6]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP2]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[INDEX]]
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 8 x i8>, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[TMP8:%.*]] = sext <vscale x 8 x i8> [[WIDE_LOAD]] to <vscale x 8 x i16>
; CHECK-NEXT:    [[TMP9:%.*]] = add <vscale x 8 x i16> [[TMP8]], trunc (<vscale x 8 x i32> shufflevector (<vscale x 8 x i32> insertelement (<vscale x 8 x i32> poison, i32 2, i64 0), <vscale x 8 x i32> poison, <vscale x 8 x i32> zeroinitializer) to <vscale x 8 x i16>)
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i16, ptr [[Q]], i64 [[INDEX]]
; CHECK-NEXT:    store <vscale x 8 x i16> [[TMP9]], ptr [[TMP10]], align 2
; CHECK-NEXT:    [[TMP11:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP12:%.*]] = mul i64 [[TMP11]], 8
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP12]]
; CHECK-NEXT:    [[TMP13:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP13]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[EXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP14:%.*]] = load i8, ptr [[ARRAYIDX]], align 1
; CHECK-NEXT:    [[CONV:%.*]] = sext i8 [[TMP14]] to i32
; CHECK-NEXT:    [[ADD:%.*]] = add nuw nsw i32 [[CONV]], 2
; CHECK-NEXT:    [[CONV1:%.*]] = trunc i32 [[ADD]] to i16
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i16, ptr [[Q]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i16 [[CONV1]], ptr [[ARRAYIDX3]], align 2
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], [[LEN]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[EXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP5:![0-9]+]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds i8, ptr %p, i64 %indvars.iv
  %0 = load i8, ptr %arrayidx
  %conv = sext i8 %0 to i32
  %add = add nuw nsw i32 %conv, 2
  %conv1 = trunc i32 %add to i16
  %arrayidx3 = getelementptr inbounds i16, ptr %q, i64 %indvars.iv
  store i16 %conv1, ptr %arrayidx3
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, %len
  br i1 %exitcond, label %exit, label %for.body

exit:                                 ; preds = %for.body
  ret void
}

attributes #0 = { "target-features"="+sve" vscale_range(1,16) }
