def run(input)
  input = input.dup
  n = 0
  pc = 0
  while pc >= 0 && (offset = input[pc])
    n += 1
    input[pc] = yield offset
    pc += offset
  end
  n
end

input = (ARGV.empty? ? DATA : ARGF).each_line.map(&:to_i)

c_lib = File.join(__dir__, 'c', 'lib05.so')
if File.exist?(c_lib)
  require 'fiddle'

  lib = Fiddle.dlopen(c_lib)
  ['part1', 'part2'].map { |f| Fiddle::Function.new(
    lib[f], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T], Fiddle::TYPE_SIZE_T,
  )}.each { |f| puts f.call(Fiddle::Pointer[input.pack('i*')], input.size) }

  exit 0
end

puts run(input, &:succ)
puts run(input) { |n| n + (n >= 3 ? -1 : 1) }

__END__
0
1
0
1
0
-1
0
1
2
2
-8
-7
-3
1
0
-2
-6
-7
-11
2
-11
0
-18
0
-18
-1
1
-16
-3
-28
-10
-6
-11
-6
-17
-20
-15
-31
-37
-34
-14
-35
-34
-17
-28
-20
-12
-41
-29
-8
-1
-50
-46
-26
-41
-33
-17
0
-28
-52
-38
-28
-29
-60
-23
-60
-55
-28
-43
-57
-66
-35
-48
-71
-25
-6
-27
-47
-77
-68
-21
2
-39
-82
-2
-59
-61
-67
-26
-11
0
-68
-85
-10
-62
-49
-28
-15
-34
-55
-92
-92
-37
-82
-49
-86
-25
-24
-81
-86
-6
-48
-79
-22
-30
-1
-63
-77
-64
-70
-86
-118
-36
-44
-50
-70
-76
-5
-72
-72
-84
-1
-104
-116
-18
-69
-78
-23
-99
-69
-32
-26
-4
-134
-22
-18
-70
-95
-13
-136
-73
-131
-24
-101
-136
-29
-132
-154
-108
-127
-48
-134
-122
-162
-2
-61
-9
-4
-126
-146
-161
-157
-116
-95
-83
-36
-86
-57
-42
-103
-73
1
0
-28
-156
-67
-178
-36
-169
-46
-16
-97
-86
-112
-186
-111
-69
-158
-37
-75
-109
-186
-16
-84
-73
-83
-139
-54
-89
-191
-126
-15
-158
-19
-116
-73
-13
-184
-121
-14
-116
-167
-174
-103
-66
-128
-156
-5
-174
-220
-213
-96
-139
-22
-102
-33
-118
-163
-184
-17
-76
-72
-96
-106
-203
-55
-181
-207
-40
-235
-139
-5
-127
-21
-155
-183
-51
-54
-38
-247
-218
-56
-34
-173
-241
-187
-38
-13
-172
-2
-235
-167
-191
-250
-150
-34
-151
-183
-119
-90
-21
-93
-275
-168
-160
-97
-100
-25
-273
-245
-44
-223
-201
-156
-12
-55
-189
-181
-10
-92
-152
-90
-217
-68
-81
-76
-86
-48
-287
-281
-63
-83
-66
-50
-49
-310
-254
-121
-294
-132
-53
-30
-223
-85
-297
-264
-58
-51
-294
-283
-3
0
-262
-33
-136
-14
-238
-6
-312
-17
-328
-299
-245
-266
-6
-330
-117
-172
-260
-224
-139
-156
-165
-13
-243
-173
-42
-67
-7
-148
-1
-105
-205
-223
-122
-82
-221
-317
-330
-240
-189
-12
-268
-243
-177
-120
-320
-127
-351
-178
-219
-351
-128
-28
-227
-188
-195
-205
-204
-283
-316
-276
-319
-312
-337
-318
-136
-33
-307
-397
-387
-303
-12
-347
-112
-171
-222
-358
-215
-71
-99
-108
-24
-291
-344
-97
-99
-6
-270
-327
-32
-387
-402
-13
-175
-243
-374
-422
-382
-152
-420
-266
-326
-37
-215
-357
-423
-16
-272
-357
-87
-184
-21
-351
-300
-219
-390
-12
-15
-78
-69
-35
-308
-303
-300
-265
-440
-19
-117
-87
-218
-163
-317
-42
-55
-185
-245
-196
-183
-327
-467
-102
-432
-162
-202
-39
-179
-301
-237
-299
-33
-198
-127
-138
-454
-46
-87
-362
-448
-382
-42
-358
-475
-350
-50
-380
-316
-380
-463
-108
-405
-139
-480
-30
-212
-308
-239
-223
-306
-81
-89
-172
-304
-87
-380
-394
-507
-392
-98
-403
-155
-13
-197
-66
-244
-401
-278
-391
-64
-460
-368
-178
-145
-440
-49
-369
-418
-332
-200
-294
-495
-104
-5
-261
-168
-392
-230
-154
-472
-404
-472
-307
-256
-169
-330
-500
-365
-146
-133
-84
-336
-405
-555
-74
-68
-354
-552
-108
-80
-406
-164
-119
-487
-151
-113
-244
-471
-80
-312
-495
-556
-76
-24
-546
-493
-340
-464
-328
-7
-474
-246
-237
-40
-199
-346
-330
-139
-284
-435
-83
-210
-423
-361
-56
-271
-140
-162
-232
-391
-42
-99
-590
2
-271
-101
-114
-117
-310
-502
-287
-319
-323
-362
-551
-439
-533
-183
-404
-401
-343
-36
-89
-454
-128
-611
-6
-619
-110
-389
-290
-270
-375
-283
-472
-65
-195
-129
-61
-548
-151
-74
-612
-156
-371
-42
-447
-565
-394
-550
-476
-592
-262
-96
-529
-395
-204
-491
-167
-186
-527
-508
-245
-455
-552
-672
-338
-269
-104
-240
-77
-303
-227
-453
-126
-294
-572
-8
-527
-361
-438
-457
-513
-560
-442
-649
-321
-123
-52
-166
-320
-301
-570
-684
-325
-515
-547
-52
-221
-488
-182
-618
-109
-497
-167
-288
-358
-334
-313
-288
-102
-409
-143
-204
-216
-681
-512
-245
-301
-35
-262
-239
-405
-682
-715
-438
-314
-179
-611
-667
-622
-511
-463
-370
-338
-434
-580
-637
-201
-213
-357
-443
-382
-315
-483
-399
-624
-318
-226
-652
-638
-743
-330
-647
-146
-138
-698
-511
-173
-663
-333
-564
-160
-239
-243
-91
-65
-468
-256
-197
-210
-575
-420
-715
-681
-454
-226
-226
-339
-473
-737
-62
-149
-351
-770
-313
-216
-491
-511
-269
-628
-391
-429
-110
-199
-409
-516
-7
-433
-405
-792
-685
-615
-287
-385
-627
-527
-426
-626
-164
-767
-794
-115
-483
-323
-371
-679
-772
-808
-2
-16
-459
-749
-569
-139
-7
-555
-161
-613
-230
-771
-825
-241
-579
-710
-73
-790
-653
-655
-394
-218
-711
-467
-774
-694
-664
-357
-29
-121
-643
-742
-388
-633
-440
-755
-581
-661
-653
-536
-596
-10
-796
-230
-813
-125
-540
-584
-389
-144
-346
-213
-444
-205
-712
-651
-670
-139
-60
-620
-49
-284
-212
-452
-520
-243
-356
-348
-442
-585
-202
-207
-222
-47
-49
-408
-571
-154
-695
-802
-524
-523
-617
-615
-571
-92
-344
-675
-613
-759
-29
-833
-662
-223
-46
-156
-373
-412
-848
-93
-695
-250
-810
-477
-150
-282
-789
-193
-443
-193
-159
-840
-755
-508
-404
-307
-80
-320
-14
-245
-746
-610
-855
-552
-323
-366
-45
-16
-335
-852
-46
-459
-461
-537
-547
-180
-842
-213
-447
-712
-633
-362
-953
-407
-47
0
-466
-107
-648
-528
-413
-828
-217
-484
-969
-121
-858
-208
-618
-384
-16
-91
-662
-348
-675
-63
-713
-966
-678
-293
-827
-445
-387
-212
-763
-847
-756
-299
-443
-80
-286
-954
-521
-394
-357
-861
-530
-649
-671
-437
-884
-606
-73
-452
-354
-729
-927
-248
-2
-738
-521
-440
-435
-291
-104
-402
-375
-875
-686
-812
-539
-934
-536
-924
-924
-365
