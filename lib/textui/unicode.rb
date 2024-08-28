# frozen_string_literal: true

module Textui::Unicode
  CHUNK_LAST, CHUNK_WIDTH = [
    [160, 1], [161, -1], [163, 1], [164, -1], [166, 1], [168, -1], [169, 1], [170, -1],
    [172, 1], [174, -1], [175, 1], [180, -1], [181, 1], [186, -1], [187, 1], [191, -1],
    [197, 1], [198, -1], [207, 1], [208, -1], [214, 1], [216, -1], [221, 1], [225, -1],
    [229, 1], [230, -1], [231, 1], [234, -1], [235, 1], [237, -1], [239, 1], [240, -1],
    [241, 1], [243, -1], [246, 1], [250, -1], [251, 1], [252, -1], [253, 1], [254, -1],
    [256, 1], [257, -1], [272, 1], [273, -1], [274, 1], [275, -1], [282, 1], [283, -1],
    [293, 1], [295, -1], [298, 1], [299, -1], [304, 1], [307, -1], [311, 1], [312, -1],
    [318, 1], [322, -1], [323, 1], [324, -1], [327, 1], [331, -1], [332, 1], [333, -1],
    [337, 1], [339, -1], [357, 1], [359, -1], [362, 1], [363, -1], [461, 1], [462, -1],
    [463, 1], [464, -1], [465, 1], [466, -1], [467, 1], [468, -1], [469, 1], [470, -1],
    [471, 1], [472, -1], [473, 1], [474, -1], [475, 1], [476, -1], [592, 1], [593, -1],
    [608, 1], [609, -1], [707, 1], [708, -1], [710, 1], [711, -1], [712, 1], [715, -1],
    [716, 1], [717, -1], [719, 1], [720, -1], [727, 1], [731, -1], [732, 1], [733, -1],
    [734, 1], [735, -1], [767, 1], [879, 0], [912, 1], [929, -1], [930, 1], [937, -1],
    [944, 1], [961, -1], [962, 1], [969, -1], [1024, 1], [1025, -1], [1039, 1], [1103, -1],
    [1104, 1], [1105, -1], [1154, 1], [1159, 0], [1424, 1], [1469, 0], [1470, 1], [1471, 0],
    [1472, 1], [1474, 0], [1475, 1], [1477, 0], [1478, 1], [1479, 0], [1551, 1], [1562, 0],
    [1610, 1], [1631, 0], [1647, 1], [1648, 0], [1749, 1], [1756, 0], [1758, 1], [1764, 0],
    [1766, 1], [1768, 0], [1769, 1], [1773, 0], [1808, 1], [1809, 0], [1839, 1], [1866, 0],
    [1957, 1], [1968, 0], [2026, 1], [2035, 0], [2044, 1], [2045, 0], [2069, 1], [2073, 0],
    [2074, 1], [2083, 0], [2084, 1], [2087, 0], [2088, 1], [2093, 0], [2136, 1], [2139, 0],
    [2199, 1], [2207, 0], [2249, 1], [2273, 0], [2274, 1], [2306, 0], [2361, 1], [2362, 0],
    [2363, 1], [2364, 0], [2368, 1], [2376, 0], [2380, 1], [2381, 0], [2384, 1], [2391, 0],
    [2401, 1], [2403, 0], [2432, 1], [2433, 0], [2491, 1], [2492, 0], [2496, 1], [2500, 0],
    [2508, 1], [2509, 0], [2529, 1], [2531, 0], [2557, 1], [2558, 0], [2560, 1], [2562, 0],
    [2619, 1], [2620, 0], [2624, 1], [2626, 0], [2630, 1], [2632, 0], [2634, 1], [2637, 0],
    [2640, 1], [2641, 0], [2671, 1], [2673, 0], [2676, 1], [2677, 0], [2688, 1], [2690, 0],
    [2747, 1], [2748, 0], [2752, 1], [2757, 0], [2758, 1], [2760, 0], [2764, 1], [2765, 0],
    [2785, 1], [2787, 0], [2809, 1], [2815, 0], [2816, 1], [2817, 0], [2875, 1], [2876, 0],
    [2878, 1], [2879, 0], [2880, 1], [2884, 0], [2892, 1], [2893, 0], [2900, 1], [2902, 0],
    [2913, 1], [2915, 0], [2945, 1], [2946, 0], [3007, 1], [3008, 0], [3020, 1], [3021, 0],
    [3071, 1], [3072, 0], [3075, 1], [3076, 0], [3131, 1], [3132, 0], [3133, 1], [3136, 0],
    [3141, 1], [3144, 0], [3145, 1], [3149, 0], [3156, 1], [3158, 0], [3169, 1], [3171, 0],
    [3200, 1], [3201, 0], [3259, 1], [3260, 0], [3262, 1], [3263, 0], [3269, 1], [3270, 0],
    [3275, 1], [3277, 0], [3297, 1], [3299, 0], [3327, 1], [3329, 0], [3386, 1], [3388, 0],
    [3392, 1], [3396, 0], [3404, 1], [3405, 0], [3425, 1], [3427, 0], [3456, 1], [3457, 0],
    [3529, 1], [3530, 0], [3537, 1], [3540, 0], [3541, 1], [3542, 0], [3632, 1], [3633, 0],
    [3635, 1], [3642, 0], [3654, 1], [3662, 0], [3760, 1], [3761, 0], [3763, 1], [3772, 0],
    [3783, 1], [3790, 0], [3863, 1], [3865, 0], [3892, 1], [3893, 0], [3894, 1], [3895, 0],
    [3896, 1], [3897, 0], [3952, 1], [3966, 0], [3967, 1], [3972, 0], [3973, 1], [3975, 0],
    [3980, 1], [3991, 0], [3992, 1], [4028, 0], [4037, 1], [4038, 0], [4140, 1], [4144, 0],
    [4145, 1], [4151, 0], [4152, 1], [4154, 0], [4156, 1], [4158, 0], [4183, 1], [4185, 0],
    [4189, 1], [4192, 0], [4208, 1], [4212, 0], [4225, 1], [4226, 0], [4228, 1], [4230, 0],
    [4236, 1], [4237, 0], [4252, 1], [4253, 0], [4351, 1], [4447, 2], [4956, 1], [4959, 0],
    [5905, 1], [5908, 0], [5937, 1], [5939, 0], [5969, 1], [5971, 0], [6001, 1], [6003, 0],
    [6067, 1], [6069, 0], [6070, 1], [6077, 0], [6085, 1], [6086, 0], [6088, 1], [6099, 0],
    [6108, 1], [6109, 0], [6154, 1], [6157, 0], [6158, 1], [6159, 0], [6276, 1], [6278, 0],
    [6312, 1], [6313, 0], [6431, 1], [6434, 0], [6438, 1], [6440, 0], [6449, 1], [6450, 0],
    [6456, 1], [6459, 0], [6678, 1], [6680, 0], [6682, 1], [6683, 0], [6741, 1], [6742, 0],
    [6743, 1], [6750, 0], [6751, 1], [6752, 0], [6753, 1], [6754, 0], [6756, 1], [6764, 0],
    [6770, 1], [6780, 0], [6782, 1], [6783, 0], [6831, 1], [6845, 0], [6846, 1], [6862, 0],
    [6911, 1], [6915, 0], [6963, 1], [6964, 0], [6965, 1], [6970, 0], [6971, 1], [6972, 0],
    [6977, 1], [6978, 0], [7018, 1], [7027, 0], [7039, 1], [7041, 0], [7073, 1], [7077, 0],
    [7079, 1], [7081, 0], [7082, 1], [7085, 0], [7141, 1], [7142, 0], [7143, 1], [7145, 0],
    [7148, 1], [7149, 0], [7150, 1], [7153, 0], [7211, 1], [7219, 0], [7221, 1], [7223, 0],
    [7375, 1], [7378, 0], [7379, 1], [7392, 0], [7393, 1], [7400, 0], [7404, 1], [7405, 0],
    [7411, 1], [7412, 0], [7415, 1], [7417, 0], [7615, 1], [7679, 0], [8207, 1], [8208, -1],
    [8210, 1], [8214, -1], [8215, 1], [8217, -1], [8219, 1], [8221, -1], [8223, 1], [8226, -1],
    [8227, 1], [8231, -1], [8239, 1], [8240, -1], [8241, 1], [8243, -1], [8244, 1], [8245, -1],
    [8250, 1], [8251, -1], [8253, 1], [8254, -1], [8307, 1], [8308, -1], [8318, 1], [8319, -1],
    [8320, 1], [8324, -1], [8363, 1], [8364, -1], [8399, 1], [8412, 0], [8416, 1], [8417, 0],
    [8420, 1], [8432, 0], [8450, 1], [8451, -1], [8452, 1], [8453, -1], [8456, 1], [8457, -1],
    [8466, 1], [8467, -1], [8469, 1], [8470, -1], [8480, 1], [8482, -1], [8485, 1], [8486, -1],
    [8490, 1], [8491, -1], [8530, 1], [8532, -1], [8538, 1], [8542, -1], [8543, 1], [8555, -1],
    [8559, 1], [8569, -1], [8584, 1], [8585, -1], [8591, 1], [8601, -1], [8631, 1], [8633, -1],
    [8657, 1], [8658, -1], [8659, 1], [8660, -1], [8678, 1], [8679, -1], [8703, 1], [8704, -1],
    [8705, 1], [8707, -1], [8710, 1], [8712, -1], [8714, 1], [8715, -1], [8718, 1], [8719, -1],
    [8720, 1], [8721, -1], [8724, 1], [8725, -1], [8729, 1], [8730, -1], [8732, 1], [8736, -1],
    [8738, 1], [8739, -1], [8740, 1], [8741, -1], [8742, 1], [8748, -1], [8749, 1], [8750, -1],
    [8755, 1], [8759, -1], [8763, 1], [8765, -1], [8775, 1], [8776, -1], [8779, 1], [8780, -1],
    [8785, 1], [8786, -1], [8799, 1], [8801, -1], [8803, 1], [8807, -1], [8809, 1], [8811, -1],
    [8813, 1], [8815, -1], [8833, 1], [8835, -1], [8837, 1], [8839, -1], [8852, 1], [8853, -1],
    [8856, 1], [8857, -1], [8868, 1], [8869, -1], [8894, 1], [8895, -1], [8977, 1], [8978, -1],
    [8985, 1], [8987, 2], [9000, 1], [9002, 2], [9192, 1], [9196, 2], [9199, 1], [9200, 2],
    [9202, 1], [9203, 2], [9311, 1], [9449, -1], [9450, 1], [9547, -1], [9551, 1], [9587, -1],
    [9599, 1], [9615, -1], [9617, 1], [9621, -1], [9631, 1], [9633, -1], [9634, 1], [9641, -1],
    [9649, 1], [9651, -1], [9653, 1], [9655, -1], [9659, 1], [9661, -1], [9663, 1], [9665, -1],
    [9669, 1], [9672, -1], [9674, 1], [9675, -1], [9677, 1], [9681, -1], [9697, 1], [9701, -1],
    [9710, 1], [9711, -1], [9724, 1], [9726, 2], [9732, 1], [9734, -1], [9736, 1], [9737, -1],
    [9741, 1], [9743, -1], [9747, 1], [9749, 2], [9755, 1], [9756, -1], [9757, 1], [9758, -1],
    [9791, 1], [9792, -1], [9793, 1], [9794, -1], [9799, 1], [9811, 2], [9823, 1], [9825, -1],
    [9826, 1], [9829, -1], [9830, 1], [9834, -1], [9835, 1], [9837, -1], [9838, 1], [9839, -1],
    [9854, 1], [9855, 2], [9874, 1], [9875, 2], [9885, 1], [9887, -1], [9888, 1], [9889, 2],
    [9897, 1], [9899, 2], [9916, 1], [9918, 2], [9919, -1], [9923, 1], [9925, 2], [9933, -1],
    [9934, 2], [9939, -1], [9940, 2], [9953, -1], [9954, 1], [9955, -1], [9959, 1], [9961, -1],
    [9962, 2], [9969, -1], [9971, 2], [9972, -1], [9973, 2], [9977, -1], [9978, 2], [9980, -1],
    [9981, 2], [9983, -1], [9988, 1], [9989, 2], [9993, 1], [9995, 2], [10023, 1], [10024, 2],
    [10044, 1], [10045, -1], [10059, 1], [10060, 2], [10061, 1], [10062, 2], [10066, 1], [10069, 2],
    [10070, 1], [10071, 2], [10101, 1], [10111, -1], [10132, 1], [10135, 2], [10159, 1], [10160, 2],
    [10174, 1], [10175, 2], [11034, 1], [11036, 2], [11087, 1], [11088, 2], [11092, 1], [11093, 2],
    [11097, -1], [11502, 1], [11505, 0], [11646, 1], [11647, 0], [11743, 1], [11775, 0], [11903, 1],
    [11929, 2], [11930, 1], [12019, 2], [12031, 1], [12245, 2], [12271, 1], [12329, 2], [12333, 0],
    [12350, 2], [12352, 1], [12438, 2], [12440, 1], [12442, 0], [12543, 2], [12548, 1], [12591, 2],
    [12592, 1], [12686, 2], [12687, 1], [12771, 2], [12782, 1], [12830, 2], [12831, 1], [12871, 2],
    [12879, -1], [19903, 2], [19967, 1], [42124, 2], [42127, 1], [42182, 2], [42606, 1], [42607, 0],
    [42611, 1], [42621, 0], [42653, 1], [42655, 0], [42735, 1], [42737, 0], [43009, 1], [43010, 0],
    [43013, 1], [43014, 0], [43018, 1], [43019, 0], [43044, 1], [43046, 0], [43051, 1], [43052, 0],
    [43203, 1], [43205, 0], [43231, 1], [43249, 0], [43262, 1], [43263, 0], [43301, 1], [43309, 0],
    [43334, 1], [43345, 0], [43359, 1], [43388, 2], [43391, 1], [43394, 0], [43442, 1], [43443, 0],
    [43445, 1], [43449, 0], [43451, 1], [43453, 0], [43492, 1], [43493, 0], [43560, 1], [43566, 0],
    [43568, 1], [43570, 0], [43572, 1], [43574, 0], [43586, 1], [43587, 0], [43595, 1], [43596, 0],
    [43643, 1], [43644, 0], [43695, 1], [43696, 0], [43697, 1], [43700, 0], [43702, 1], [43704, 0],
    [43709, 1], [43711, 0], [43712, 1], [43713, 0], [43755, 1], [43757, 0], [43765, 1], [43766, 0],
    [44004, 1], [44005, 0], [44007, 1], [44008, 0], [44012, 1], [44013, 0], [44031, 1], [55203, 2],
    [57343, 1], [63743, -1], [64255, 2], [64285, 1], [64286, 0], [65023, 1], [65039, 0], [65049, 2],
    [65055, 1], [65071, 0], [65106, 2], [65107, 1], [65126, 2], [65127, 1], [65131, 2], [65280, 1],
    [65376, 2], [65503, 1], [65510, 2], [65532, 1], [65533, -1], [66044, 1], [66045, 0], [66271, 1],
    [66272, 0], [66421, 1], [66426, 0], [68096, 1], [68099, 0], [68100, 1], [68102, 0], [68107, 1],
    [68111, 0], [68151, 1], [68154, 0], [68158, 1], [68159, 0], [68324, 1], [68326, 0], [68899, 1],
    [68903, 0], [69290, 1], [69292, 0], [69372, 1], [69375, 0], [69445, 1], [69456, 0], [69505, 1],
    [69509, 0], [69632, 1], [69633, 0], [69687, 1], [69702, 0], [69743, 1], [69744, 0], [69746, 1],
    [69748, 0], [69758, 1], [69761, 0], [69810, 1], [69814, 0], [69816, 1], [69818, 0], [69825, 1],
    [69826, 0], [69887, 1], [69890, 0], [69926, 1], [69931, 0], [69932, 1], [69940, 0], [70002, 1],
    [70003, 0], [70015, 1], [70017, 0], [70069, 1], [70078, 0], [70088, 1], [70092, 0], [70094, 1],
    [70095, 0], [70190, 1], [70193, 0], [70195, 1], [70196, 0], [70197, 1], [70199, 0], [70205, 1],
    [70206, 0], [70208, 1], [70209, 0], [70366, 1], [70367, 0], [70370, 1], [70378, 0], [70399, 1],
    [70401, 0], [70458, 1], [70460, 0], [70463, 1], [70464, 0], [70501, 1], [70508, 0], [70511, 1],
    [70516, 0], [70711, 1], [70719, 0], [70721, 1], [70724, 0], [70725, 1], [70726, 0], [70749, 1],
    [70750, 0], [70834, 1], [70840, 0], [70841, 1], [70842, 0], [70846, 1], [70848, 0], [70849, 1],
    [70851, 0], [71089, 1], [71093, 0], [71099, 1], [71101, 0], [71102, 1], [71104, 0], [71131, 1],
    [71133, 0], [71218, 1], [71226, 0], [71228, 1], [71229, 0], [71230, 1], [71232, 0], [71338, 1],
    [71339, 0], [71340, 1], [71341, 0], [71343, 1], [71349, 0], [71350, 1], [71351, 0], [71452, 1],
    [71455, 0], [71457, 1], [71461, 0], [71462, 1], [71467, 0], [71726, 1], [71735, 0], [71736, 1],
    [71738, 0], [71994, 1], [71996, 0], [71997, 1], [71998, 0], [72002, 1], [72003, 0], [72147, 1],
    [72151, 0], [72153, 1], [72155, 0], [72159, 1], [72160, 0], [72192, 1], [72202, 0], [72242, 1],
    [72248, 0], [72250, 1], [72254, 0], [72262, 1], [72263, 0], [72272, 1], [72278, 0], [72280, 1],
    [72283, 0], [72329, 1], [72342, 0], [72343, 1], [72345, 0], [72751, 1], [72758, 0], [72759, 1],
    [72765, 0], [72766, 1], [72767, 0], [72849, 1], [72871, 0], [72873, 1], [72880, 0], [72881, 1],
    [72883, 0], [72884, 1], [72886, 0], [73008, 1], [73014, 0], [73017, 1], [73018, 0], [73019, 1],
    [73021, 0], [73022, 1], [73029, 0], [73030, 1], [73031, 0], [73103, 1], [73105, 0], [73108, 1],
    [73109, 0], [73110, 1], [73111, 0], [73458, 1], [73460, 0], [73471, 1], [73473, 0], [73525, 1],
    [73530, 0], [73535, 1], [73536, 0], [73537, 1], [73538, 0], [78911, 1], [78912, 0], [78918, 1],
    [78933, 0], [92911, 1], [92916, 0], [92975, 1], [92982, 0], [94030, 1], [94031, 0], [94094, 1],
    [94098, 0], [94175, 1], [94179, 2], [94180, 0], [94191, 1], [94193, 2], [94207, 1], [100343, 2],
    [100351, 1], [101589, 2], [101631, 1], [101640, 2], [110575, 1], [110579, 2], [110580, 1], [110587, 2],
    [110588, 1], [110590, 2], [110591, 1], [110882, 2], [110897, 1], [110898, 2], [110927, 1], [110930, 2],
    [110932, 1], [110933, 2], [110947, 1], [110951, 2], [110959, 1], [111355, 2], [113820, 1], [113822, 0],
    [118527, 1], [118573, 0], [118575, 1], [118598, 0], [119142, 1], [119145, 0], [119162, 1], [119170, 0],
    [119172, 1], [119179, 0], [119209, 1], [119213, 0], [119361, 1], [119364, 0], [121343, 1], [121398, 0],
    [121402, 1], [121452, 0], [121460, 1], [121461, 0], [121475, 1], [121476, 0], [121498, 1], [121503, 0],
    [121504, 1], [121519, 0], [122879, 1], [122886, 0], [122887, 1], [122904, 0], [122906, 1], [122913, 0],
    [122914, 1], [122916, 0], [122917, 1], [122922, 0], [123022, 1], [123023, 0], [123183, 1], [123190, 0],
    [123565, 1], [123566, 0], [123627, 1], [123631, 0], [124139, 1], [124143, 0], [125135, 1], [125142, 0],
    [125251, 1], [125258, 0], [126979, 1], [126980, 2], [127182, 1], [127183, 2], [127231, 1], [127242, -1],
    [127247, 1], [127277, -1], [127279, 1], [127337, -1], [127343, 1], [127373, -1], [127374, 2], [127376, -1],
    [127386, 2], [127404, -1], [127487, 1], [127490, 2], [127503, 1], [127547, 2], [127551, 1], [127560, 2],
    [127567, 1], [127569, 2], [127583, 1], [127589, 2], [127743, 1], [127776, 2], [127788, 1], [127797, 2],
    [127798, 1], [127868, 2], [127869, 1], [127891, 2], [127903, 1], [127946, 2], [127950, 1], [127955, 2],
    [127967, 1], [127984, 2], [127987, 1], [127988, 2], [127991, 1], [128062, 2], [128063, 1], [128064, 2],
    [128065, 1], [128252, 2], [128254, 1], [128317, 2], [128330, 1], [128334, 2], [128335, 1], [128359, 2],
    [128377, 1], [128378, 2], [128404, 1], [128406, 2], [128419, 1], [128420, 2], [128506, 1], [128591, 2],
    [128639, 1], [128709, 2], [128715, 1], [128716, 2], [128719, 1], [128722, 2], [128724, 1], [128727, 2],
    [128731, 1], [128735, 2], [128746, 1], [128748, 2], [128755, 1], [128764, 2], [128991, 1], [129003, 2],
    [129007, 1], [129008, 2], [129291, 1], [129338, 2], [129339, 1], [129349, 2], [129350, 1], [129535, 2],
    [129647, 1], [129660, 2], [129663, 1], [129672, 2], [129679, 1], [129725, 2], [129726, 1], [129733, 2],
    [129741, 1], [129755, 2], [129759, 1], [129768, 2], [129775, 1], [129784, 2], [131071, 1], [196605, 2],
    [196607, 1], [262141, 2], [917759, 1], [917999, 0], [983039, 1], [1048573, -1], [1048575, 1], [1114109, -1],
  ].transpose

  @ambiguous_width = 1
  @flag_emoji_width = 2
  @variation_selector_16_emoji_width = 1
  @standalone_nonspacing_mark_width = 0

  def self.measure_widths
    @ambiguous_width = measure_char_width("\u{25bd}", 1..2) || 1
    @flag_emoji_width = measure_char_width("\u{1f1ef}\u{1f1f5}", 1..2) || 2
    @variation_selector_16_emoji_width = measure_char_width("\u{26f4}\u{fe0f}", 1..2) || 1
    @standalone_nonspacing_mark_width = measure_char_width("\u{0300}", 0..1) || 0
  end

  def self.measure_char_width(char, range)
    $stdin.raw do
      print "\r#{char}\e[6n\r\e[K"
      if $stdin.wait_readable(0.1) && /\e\[\d+;(?<col>\d+)R/ =~ $stdin.readpartial(1024)
        w = col.to_i - 1
        w if range.cover?(w)
      end
    end
  end

  # TODO: multibyte
  def self.substr(text, col, width)
    total_width = 0
    output = +''
    seq = +''
    text.scan(/(\e\[0?m)|(\e\[[\d;]*m)|(\X)/).each do |(reset, csi, gc)|
      if total_width >= col
        if seq
          output << seq
          seq = nil
        end
        if reset || csi
          output << (reset || csi)
        else
          output << gc
          total_width += char_width(gc)
          break if total_width >= col + width
        end
      elsif gc
        total_width += char_width(gc)
      elsif reset
        seq.clear
      elsif csi
        seq << csi
      end
    end
    return output
  end

  def self.char_width(grapheme_cluster)
    ord = grapheme_cluster.ord
    return 1 if ord <= 0x7f
    chunk_index = CHUNK_LAST.bsearch_index { |o| ord <= o }
    size = CHUNK_WIDTH[chunk_index]
    case size
    when 0
      @standalone_nonspacing_mark_width
    when -1
      @ambiguous_width
    when 1
      if grapheme_cluster.size >= 2
        case grapheme_cluster
        when /\A[\u{1f1e6}-\u{1f1ff}]{2}/
          return @flag_emoji_width
        when /\A\p{emoji}\u{fe0f}/
          return @variation_selector_16_emoji_width
        when /\A.[\u{ff9e}\u{ff9f}]/
          return 2
        end
      end
      1
    when 2
      2
    end
  end

  def self.colored_text_width(text)
    text.scan(/\e\[[\d;]*m|(\X)/).sum do |(gc)|
      gc ? char_width(gc) : 0
    end
  end

  def self.wrap_text(text, width, offset: 0)
    lines = [+'']
    x = offset
    text.grapheme_clusters.each do |gc|
      w = char_width(gc)
      if gc == "\n"
        lines << +''
        x = 0
      elsif x == 0 || x + w <= width
        lines.last << gc
        x += w
      else
        lines << gc
        x = w
      end
    end
    [lines, x]
  end

  def self.text_width(text)
    text.grapheme_clusters.sum { char_width(_1) }
  end
end
